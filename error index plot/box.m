
clear;
clc;
close all;

 
data = load('NCAAR2.mat'); EWB = data.NCAAR2; clear data;
data = load('SR2.mat'); S = data.NMCDR2; clear data;
data = load('RFR2.mat'); R = data.NMCDR2; clear data;  
data = load('LSR2.mat');LS = data.NMCDR2; clear data;   
data = load('LGR2.mat'); LG = data.NMCDR2; clear data; 


all_data = {EWB, R, S, LS, LG};

dataset_names = {'      ETO-\newline WLSSVM-\newline BrownBoost', 'RF', 'SVM', 'LSTM', 'LGBM'};
num_datasets = length(all_data);


all_percentage_errors = [];


for i = 1:num_datasets
    current_data = all_data{i};
    true_values = current_data(1,:);
    predicted_values = current_data(2,:);
    
    
    absolute_error = abs(true_values - predicted_values);
    percentage_error = absolute_error ./ abs(true_values) * 100;
    
   
    all_percentage_errors = [all_percentage_errors, percentage_error'];
    
   
    MAE = mean(absolute_error);
    RMSE = sqrt(mean(absolute_error.^2));
    mean_percentage_error = mean(percentage_error);
    std_percentage_error = std(percentage_error);
    variance_percentage_error = var(percentage_error);
    [max_error, max_idx] = max(percentage_error);
    worst_cycle = max_idx;
    
  
    median_error = median(percentage_error);
    Q1 = quantile(percentage_error, 0.25);
    Q3 = quantile(percentage_error, 0.75);
    IQR = Q3 - Q1;
    min_val = min(percentage_error);
    max_val = max(percentage_error);
    

    fprintf('\n=== data set %d (%s) ===\n', i, dataset_names{i});
    fprintf('MAE: %.6f\n', MAE);
    fprintf('RMSE: %.6f\n', RMSE);
    fprintf('Variance: %.4f (%%²)\n', variance_percentage_error);
    fprintf('Standard deviation: %.4f%%\n', std_percentage_error);
    fprintf('Maximum error: %.4f%% (Cycle %d)\n', max_error, worst_cycle);
    
   
    SE = std_percentage_error/sqrt(length(percentage_error));
    t_critical = tinv(0.975, length(percentage_error)-1);
    CI_lower = mean_percentage_error - t_critical*SE;
    CI_upper = mean_percentage_error + t_critical*SE;
    
    fprintf('Average error 95% confidence interval: [%.4f%%, %.4f%%]\n', CI_lower, CI_upper);
end


figure('Color', 'white');

set(gcf, 'Position', [100, 100, 700, 500]); 
hold on;


boxHandles = boxplot(all_percentage_errors, ...
        'Orientation', 'vertical', ...
        'Widths', 0.65, ...  
        'Symbol', '.', ...    
        'Whisker', 1.5, ...
        'OutlierSize', 10, ... 
        'Colors', 'k', ...    
        'MedianStyle', 'line');


mycolor = [0.4660, 0.6740, 0.1880;    
          0.4940, 0.1840, 0.5560;    
           0.9290, 0.6940, 0.1250;    
           0.8500, 0.3250, 0.0980;   
          0, 0.4470, 0.7410]; 



hBox = findobj(gca, 'Tag', 'Box');
for i = 1:num_datasets
    
    patch(get(hBox(i), 'XData'), get(hBox(i), 'YData'), ...
          mycolor(i,:), 'FaceAlpha', 0.85, ...
          'EdgeColor', 'k', 'LineWidth', 1.8);
end

hMed = findobj(gca, 'Tag', 'Median');
set(hMed, 'Color', [0, 0, 0], 'LineWidth', 3.5);  



hWhiskers = findobj(gca, 'Tag', 'Whisker');
set(hWhiskers, 'Color', [0.3 0.3 0.3], 'LineStyle', '-', 'LineWidth', 1.5);


hOutliers = findobj(gca, 'Tag', 'Outliers');
set(hOutliers, 'Marker', 'x', 'MarkerEdgeColor', [0.5 0.5 0.5], ...
    'MarkerSize', 8, 'LineWidth', 1.2);


set(gca, 'XTick', 1:num_datasets, ...
         'XTickLabel', dataset_names, ...
         'TickLabelInterpreter', 'tex', ...  
         'FontSize', 16, ...                
         'FontWeight', 'bold', ...
         'FontName', 'Times New Roman');



ylabel('Percentage Error (%)', 'FontSize', 22, 'FontName', 'Arial', 'FontWeight', 'bold');


set(gca, 'FontSize', 20, 'FontName', 'Times New Roman', ...
    'FontWeight', 'bold', 'LineWidth', 1.8, ...
    'TickDir', 'out', 'TickLength', [0.015 0.015]);


grid on;
set(gca, 'GridLineStyle', '-', 'GridAlpha', 0.12, 'GridColor', [0.2 0.2 0.2]);


ax = gca;
ax.Position(2) = ax.Position(2) ;  
ax.Position(4) = ax.Position(4) - 0.1;  


title('Prediction Error Comparison', 'FontSize', 24, ...
    'FontName', 'Times New Roman', 'FontWeight', 'bold');


set(gcf, 'Color', 'white');
set(gca, 'Color', 'white');
set(gcf, 'Renderer', 'painters');
set(gca, 'XTickLabelRotation', 0); 
hold off;