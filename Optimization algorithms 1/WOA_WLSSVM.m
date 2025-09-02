
warning off             
close all               
clc                    
%clear                   
clearvars -except x; 
addpath 'LSSVMlabv1_8_R2009b_R2011a'
for x=1
rng(41);

res1 = readtable('feature_SOH_Oxford_11.csv');
res2 = readtable('feature_SOH_Oxford_22.csv');
res3 = readtable('feature_SOH_Oxford_33.csv');
res4 = readtable('feature_SOH_Oxford_44.csv');
% res1 = readtable('feature_SOH_SNL_18650_NMC_25C_0-100_0.5-1C_a_timeseries.csv');
% res2 = readtable('feature_SOH_SNL_18650_NMC_25C_0-100_0.5-1C_b_timeseries.csv');
% res3 = readtable('feature_SOH_SNL_18650_NMC_25C_0-100_0.5-1C_c_timeseries.csv');
% res4 = readtable('feature_SOH_SNL_18650_NMC_25C_0-100_0.5-1C_d_timeseries.csv');
res1 = table2array(res1);
res2 = table2array(res2);
res3 = table2array(res3);
res4 = table2array(res4);
%data = [res1(:,[1,3,4]) ; res2(:,[1,3,4]) ; res3(:,[1,3,4])];
data=res1(:,[1,3,4]);

P_test = data(:,1:end-1)';
T_test = data(:,end)';

num_samples = size(data, 1);                  
data =data(randperm(num_samples), :);         
input=data(:,1:end-1);
output=data(:,end);

L=length(output);  
num=round(0.4*L);         
P_train = input(1:num,:)';
T_train = output(1:num,:)';

N = size(P_test, 2);          
M = size(P_train, 2);         

[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);



p_train = p_train'; p_test = p_test';
t_train = t_train'; t_test = t_test';

    
    SearchAgents_no=4; 
    Max_iter=4;
    dim=2; 
    lb=[1e-3,1e-3];
    ub=[80,80];
    type = 'function estimation';
    kernel='RBF_kernel';
    C = 10;
    [gam,sig2]=WOA(SearchAgents_no,Max_iter,lb,ub,dim,type,p_train,t_train,p_test,t_test);
    

    [alpha, b] = trainlssvm({p_train, t_train, type, gam, sig2, 'RBF_kernel'});
    e = alpha/C;
    v1 = weights(e,2.5,3);
    unit = ones(M, 1);
    zero = zeros(1, 1);
    upmat = [zero, unit'];
    K = kernelTrans(p_train, sig2);
    downmat = [unit, K + v1 / C];
    completemat = [upmat; downmat];
    rightmat = [zero; t_train];
    b_alpha = completemat \ rightmat;
    b1 = b_alpha(1);
    alphas1 = b_alpha(2:end);
    t_sim1 = K' * alphas1 + b1;
    for j = 1:size(p_test, 1)
    Kx = exp(-pdist2(p_test(j, :), p_train).^2 / (2 * sig2^2)); 
    t_sim2(j) = Kx * alphas1 + b1; 
    end
  
    Error = t_sim1' - t_train;
    

T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);


figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('real', 'predict')
xlabel('sample')
ylabel('result')
string = {'Training set result'};
title(string)
grid


T_sim2_filtered = sgolayfilt(T_sim2, 2, 13); 
fig_test=figure;
plot(1: N, T_test, 'r-', 1: N, T_sim2_filtered, 'b-', 'LineWidth', 1)
legend('real', 'woa-wlssvm predict')
xlabel('sample')
ylabel('result')
string = {'Test set result'};
title(string)
grid


fig_error=figure;
test_Error = T_sim2 - T_test;
test_Error_filtered=sgolayfilt(test_Error, 4, 9);
plot(1: N, test_Error_filtered, 'b-','LineWidth', 1)
legend('woa-wlssvm error')
xlabel('sample')
ylabel('error')
string = {'Test set error'};
title(string)
grid
WOA=[T_test;T_sim2_filtered;test_Error_filtered];
save('WOA.mat', 'WOA')

sz = 25;
c = 'b';
figure
scatter(T_test, T_sim2, sz, c, 'filled');
hold on


xlim([0.8, 0.98]);
ylim([0.8, 0.98]);


plot([0, 1], [0, 1], '-r')

xlabel('Real SOH');
ylabel('Estimated SOH');
title('Test set predict vs. Test set real');

[mae,mse,rmse,mape,error,errorPercent,R,r_2]=calc_error(T_test,T_sim2);
%save('lssvm_model_ncaa.mat', 'alpha', 'b', 'p_train', 't_train', 'type', 'gam', 'sig2');
str = ['R^2 = ' num2str(r_2, '%.5f')];  


xLimits = xlim;
yLimits = ylim;


text(0.2 * (xLimits(2) - xLimits(1)) + xLimits(1), ...  
     0.9 * (yLimits(2) - yLimits(1)) + yLimits(1), ...  
     str, 'FontSize', 16, 'Color', 'black', ...
     'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
     'FontName', 'Times New Roman');
r_2_col = r_2 * ones(size(T_test));
WOAR2=[T_test;T_sim2;r_2_col];
save('WOAR2.mat', 'WOAR2')
end