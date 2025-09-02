
warning off;            
close all;               
clear;                   
clc;                     

rng(44); 


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


num_samples = size(data, 1);
num_train = round(0.4 * num_samples); 


P_test = data(:, 1:end-1);  
T_test = data(:, end);       
shuffled_idx = randperm(num_samples);  
train_idx = shuffled_idx(1:num_train);
test_idx = 1:num_samples;  

P_train = data(train_idx, 1:end-1);
T_train = data(train_idx, end);



[p_train, ps_input] = mapminmax(P_train', 0, 1);
p_test = mapminmax('apply', P_test', ps_input);  

[t_train, ps_output] = mapminmax(T_train', 0, 1);
t_test = mapminmax('apply', T_test', ps_output);


p_train = p_train'; p_test = p_test';
t_train = t_train'; t_test = t_test';


template = templateTree('MaxNumSplits', 30);
model = fitrensemble(p_train, t_train, ...
    'Method', 'LSBoost', ...
    'NumLearningCycles', 30, ...
    'LearnRate', 0.1, ...
    'Learners', template);


t_sim_train = predict(model, p_train);  
t_sim_test = predict(model, p_test);   


T_sim_train = mapminmax('reverse', t_sim_train', ps_output);
T_sim_test = mapminmax('reverse', t_sim_test', ps_output);


error_train = sqrt(mean((T_sim_train' - T_train).^2));
error_test = sqrt(mean((T_sim_test' - T_test).^2));

R_train = corr(T_train, T_sim_train')^2;
R_test = corr(T_test, T_sim_test')^2;


figure;
plot(T_train, 'r-*', 'LineWidth', 1);
hold on;
plot(T_sim_train, 'b-o', 'LineWidth', 1);
legend('real', 'predict');
title('Training set result');
grid on;



T_sim2_filtered = sgolayfilt(T_sim_test, 2, 39); 
fig_test=figure;
plot( T_sim2_filtered, 'g-')
legend('error')
xlabel('sample')
ylabel('result')
string = {'Test set result'};
title(string)
grid

fig_error=figure;
test_Error = T_sim_test' - T_test;
test_Error_filtered=sgolayfilt(test_Error, 4, 9);
plot(1: num_samples, test_Error_filtered, 'g-','LineWidth', 1)
legend('error')
xlabel('sample')
ylabel('error')
string = {'Test set error'};
title(string)
grid
S=[T_sim2_filtered;test_Error_filtered'];
save('LG.mat', 'S')

[mae,mse,rmse,mape,error,errorPercent,R,r_2]=calc_error(T_test,T_sim_test');
r_2_col = r_2 * ones(size(T_test));
NMCDR2=[T_test';T_sim_test;r_2_col'];
save('LGR2.mat', 'NMCDR2')