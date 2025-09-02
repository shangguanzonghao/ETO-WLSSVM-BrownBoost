
warning off             
close all             
clc                   
%clear                  
clearvars -except x; 
addpath 'LSSVMlabv1_8_R2009b_R2011a'
for x=1
rng(83);

res1 = readtable('feature_SOH_SNL_NMC_3.5_3.6.csv');
res2 = readtable('feature_SOH_SNL_NMC_3.6_3.7.csv');
res3 = readtable('feature_SOH_SNL_NMC_3.7_3.8.csv');
res4 = readtable('feature_SOH_SNL_NMC_3.8_3.9.csv');
res5 = readtable('feature_SOH_SNL_NMC_3.9_4.0.csv');
res6 = readtable('feature_SOH_SNL_NMC_4.0_4.1.csv');
res7 = readtable('feature_SOH_SNL_NMC_4.1_4.2.csv');

res1 = table2array(res1);
res2 = table2array(res2);
res3 = table2array(res3);
res4 = table2array(res4);
res5 = table2array(res5);
res6 = table2array(res6);
res7 = table2array(res7);
%data = [res1(:,[1,3,4]) ; res2(:,[1,3,4]) ; res3(:,[1,3,4])];
data=res7(:,[1,9,10]);
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






c = 30; 
s = 0.01; 
max_iter = 100; 


D = zeros(max_iter+1, M);  
D(1, :) = ones(1, M) / M; 
weight = zeros(1, max_iter);
remaining_time = c; 
i = 0; 


while remaining_time > s && i < max_iter
    i = i + 1;
    
    
    SearchAgents_no=10; 
    Max_iter=5;
    dim=2; 
    lb=[1e-4,1e-4];
    ub=[30,30];
    type = 'function estimation';
    kernel='RBF_kernel';
    C = 10;
    [gam,sig2]=ETO(SearchAgents_no,Max_iter,lb,ub,dim,type,p_train,t_train,p_test,t_test);
    
    
    [alpha, b] = trainlssvm({p_train, t_train, type, gam, sig2, 'RBF_kernel', D(i, :)});
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
    t_sim1(i, :) = K' * alphas1 + b1;
    for j = 1:size(p_test, 1)
    Kx = exp(-pdist2(p_test(j, :), p_train).^2 / (2 * sig2^2)); 
    t_sim2(i, j) = Kx * alphas1 + b1; 
    end
    
    Error(i, :) = t_sim1(i, :)' - t_train;
    
  
    
    r = 1 ./ (1 + abs(Error(i, :)'));
    
    
    v = D(i, :) .* exp(-r.^2 / remaining_time);
    
 
    total_v = sum(v);
   

    max_newton_iter = 20;
    tol = 1e-3;           
    delta_t = remaining_time * (1 - total_v) / (2 * total_v); 
    
    for newton_iter = 1:max_newton_iter
        
        residual = remaining_time - delta_t;
        if residual <= 0
            delta_t = remaining_time - s; 
            break;
        end
        f_val = sum(D(i, :) .* exp(-r.^2 / residual)) - total_v;
        
        
        if abs(f_val) < tol
            break;
        end
        
       
        df_val = sum(D(i, :) .* exp(-r.^2 / residual) .* (r.^2) / (residual^2));
        
        
        delta_t = delta_t - f_val / df_val;
        
       
        if remaining_time - delta_t < s
            delta_t = remaining_time - s;
            break;
        end
    end
  
    remaining_time = remaining_time - delta_t;
    
   
    D(i+1, :) = D(i, :) .* exp(-r.^2 / (remaining_time+ delta_t) )';
    D(i+1, :) = D(i+1, :) / sum(D(i+1, :));
    
    
    weight(i) = delta_t; 
    
 
    if remaining_time <= s
        break;
    end
end


weight = weight(1:i);          
weight = weight / sum(weight);


T_sim1 = zeros(1, M);
T_sim2 = zeros(1, N);


for j = 1:i
    T_sim1 = T_sim1 + weight(j) * t_sim1(j, :);
    T_sim2 = T_sim2 + weight(j) * t_sim2(j, :);
end

T_sim1 = mapminmax('reverse', T_sim1, ps_output);
T_sim2 = mapminmax('reverse', T_sim2, ps_output);


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
legend('real', 'ETO-wlssvm-brownboost predict')
xlabel('sample')
ylabel('result')
string = {'Test set result'};
title(string)
grid


fig_error=figure;
test_Error = T_sim2 - T_test;
test_Error_filtered=sgolayfilt(test_Error, 4, 9);
plot(1: N, test_Error_filtered, 'b-','LineWidth', 1)
legend('ETO-wlssvm-brownboost error')
xlabel('sample')
ylabel('error')
string = {'Test set error'};
title(string)
grid
CWB=[T_test;T_sim2_filtered;test_Error_filtered];
%save('zhu03.mat', 'CWB')

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
NMCDR2=[T_test;T_sim2;r_2_col];
%save('zhu03R2.mat', 'NMCDR2')
end