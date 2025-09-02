
warning off             
close all               
clear                   
clc                     
rng(44)

res1 = readtable('feature_SOH_SNL_18650_NCA_25C_0-100_0.5-1C_a_timeseries.csv');
res2 = readtable('feature_SOH_SNL_18650_NCA_25C_0-100_0.5-1C_b_timeseries.csv');
res3 = readtable('feature_SOH_SNL_18650_NCA_25C_0-100_0.5-1C_c_timeseries.csv');
res4 = readtable('feature_SOH_SNL_18650_NCA_25C_0-100_0.5-1C_d_timeseries.csv');
res1 = table2array(res1);
res2 = table2array(res2);
res3 = table2array(res3);
res4 = table2array(res4);
%data = [res1(:,[1,3,4]) ; res2(:,[1,3,4]) ; res3(:,[1,3,4])];
data=res4(:,[1,3,4]);

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


[P_train, ps_input] = mapminmax(P_train, 0, 1);
P_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);


P_train =  double(reshape(P_train, 2, 1, 1, M));
P_test  =  double(reshape(P_test , 2, 1, 1, N));

t_train = t_train';
t_test  = t_test' ;


for i = 1 : M
    p_train{i, 1} = P_train(:, :, 1, i);
end

for i = 1 : N
    p_test{i, 1}  = P_test( :, :, 1, i);
end


layers = [
    sequenceInputLayer(2)               
    
    lstmLayer(3, 'OutputMode', 'last')  
 
    reluLayer                           
    fullyConnectedLayer(1)              
    regressionLayer];                   
 

options = trainingOptions('adam', ...      
    'MiniBatchSize', 100,...
    'MaxEpochs', 400, ...                 
    'InitialLearnRate', 0.01, ...          
    'LearnRateSchedule', 'piecewise', ...  
    'LearnRateDropFactor', 0.99, ...       
    'LearnRateDropPeriod', 20, ...       
    'Plots', 'training-progress', ...      
    'Verbose', false);


net = trainNetwork(p_train, t_train, layers, options);


t_sim1 = predict(net, p_train);
t_sim2 = predict(net, p_test );

T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);


error1 = sqrt(sum((T_sim1' - T_train).^2) ./ M);
error2 = sqrt(sum((T_sim2' - T_test ).^2) ./ N);


analyzeNetwork(net)


figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('real', 'predict')
xlabel('sample')
ylabel('result')
string = {'Training set result'};
title(string)
grid

T_sim2 = double(T_sim2);

T_sim2_filtered = sgolayfilt(T_sim2, 2, 39); 
fig_test=figure;
plot( T_sim2_filtered, 'c-')
legend('real', 'lstm predict')
xlabel('sample')
ylabel('result')
string = {'Test set result'};
title(string)
grid


fig_error=figure;
test_Error = T_sim2' - T_test;
test_Error_filtered=sgolayfilt(test_Error, 4, 9);
plot(1: N, test_Error_filtered, 'c-','LineWidth', 1)
legend('lstm error')
xlabel('sample')
ylabel('error')
string = {'Test set error'};
title(string)
grid
L=[T_sim2_filtered';test_Error_filtered];
save('LS.mat', 'L')

[mae,mse,rmse,mape,error,errorPercent,R,r_2]=calc_error(T_test,T_sim2');
r_2_col = r_2 * ones(size(T_test));
NMCDR2=[T_test;T_sim2';r_2_col];
save('LSR2.mat', 'NMCDR2')

