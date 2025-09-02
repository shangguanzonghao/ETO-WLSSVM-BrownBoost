clear
close all
clc


data = load('CWB.mat'); CWB = data.CWB; clear data;
data = load('S.mat'); S = data.S; clear data;
data = load('R.mat'); R = data.S; clear data;  
data = load('LS.mat');LS = data.L; clear data;   
data = load('LG.mat'); LG = data.S; clear data; 


colors = struct(...
    'Reference', [0,0,0],...       
    'ETO', [0, 0.4470, 0.7410],...  
    'RF', [0.8500, 0.3250, 0.0980],... 
    'SVM', [0.9290, 0.6940, 0.1250],... 
    'LSTM', [0.4940, 0.1840, 0.5560],... 
    'LGBM', [0.4660, 0.6740, 0.1880]... 
);


figure
h(1) = plot(CWB(1,:), 'LineWidth', 1.5, 'Color', colors.Reference, 'DisplayName', 'Reference');
hold on
h(2) = plot(CWB(2,:), 'LineWidth', 1.5, 'Color', colors.ETO, 'DisplayName', 'ETO-WLSSVM-BrownBoost');
h(3) = plot(R(1,:), 'LineWidth', 1.5, 'Color', colors.RF, 'DisplayName', 'RF'); 
h(4) = plot(S(1,:), 'LineWidth', 1.5, 'Color', colors.SVM, 'DisplayName', 'SVM');
h(5) = plot(LS(1,:), 'LineWidth', 1.5, 'Color', colors.LSTM, 'DisplayName', 'LSTM'); 
h(6) = plot(LG(1,:), 'LineWidth', 1.5, 'Color', colors.LGBM, 'DisplayName', 'LGBM'); 

grid on;
xlabel("Cycle Number", 'FontSize', 18, 'fontname', 'Times New Roman', 'fontweight', 'bold');
ylabel('SOH', 'FontSize', 18, 'fontname', 'Times New Roman', 'fontweight', 'bold');
axis([0 700 0.71 1.05]);

ax1 = gca;
leg1 = legend(ax1, h(1:2), {'Reference','ETO-WLSSVM-BrownBoost'},...
    'Location', 'northeast',...
    'FontSize', 18,...
    'FontName', 'Times New Roman');

ax2 = axes('Position', ax1.Position, 'Visible', 'off');
leg2 = legend(ax2, h(3:6), {'RF','SVM','LSTM','LGBM'},...
    'Location', 'southwest',...
    'NumColumns', 2,...  
    'FontSize', 18,...
    'FontName', 'Times New Roman');

set([leg1, leg2],...
    'Color', 'none',...
    'ItemTokenSize', [15,15]);

set(gcf, 'Position', [100,100,600,370]);
set(gca, 'FontSize', 18, 'fontname', 'Times New Roman');

set(ax1, 'FontSize', 18, 'FontName', 'Times New Roman', ...
    'XColor', 'k', 'YColor', 'k');  

figure
k(1) = plot(CWB(3,:), 'LineWidth', 1.5, 'Color', colors.ETO, 'DisplayName', 'ETO-WLSSVM-BrownBoost');
hold on
k(2) = plot(R(2,:), 'LineWidth', 1.5, 'Color', colors.RF, 'DisplayName', 'RF'); 
k(3) = plot(S(2,:), 'LineWidth', 1.5, 'Color', colors.SVM, 'DisplayName', 'SVM');
k(4) = plot(LS(2,:), 'LineWidth', 1.5, 'Color', colors.LSTM, 'DisplayName', 'LSTM'); 
k(5) = plot(LG(2,:), 'LineWidth', 1.5, 'Color', colors.LGBM, 'DisplayName', 'LGBM'); 

grid on;
xlabel("Cycle Number", 'FontSize', 18, 'fontname', 'Times New Roman', 'fontweight', 'bold');
ylabel('Error', 'FontSize', 18, 'fontname', 'Times New Roman', 'fontweight', 'bold');

axis([0 650 -0.14 0.1]);

ax1 = gca;
leg1 = legend(ax1, k(1), {'ETO-WLSSVM-BrownBoost'},...
    'Location', 'northeast',...
    'FontSize', 18,...
    'FontName', 'Times New Roman');

ax2 = axes('Position', ax1.Position, 'Visible', 'off');
leg2 = legend(ax2, k(2:5), {'RF','SVM','LSTM','LGBM'},...
    'Location', 'southeast',...
    'NumColumns', 2,...  
    'FontSize', 18,...
    'FontName', 'Times New Roman');

set([leg1, leg2], 'Color', 'none', 'ItemTokenSize', [15,15]);
set(ax1, 'YLim', [-0.1 0.1]);

set(gcf, 'Position', [100,100,600,370]);
set(gca, 'FontSize', 18, 'fontname', 'Times New Roman');

set(ax1, 'FontSize', 18, 'FontName', 'Times New Roman', ...
    'XColor', 'k', 'YColor', 'k');  