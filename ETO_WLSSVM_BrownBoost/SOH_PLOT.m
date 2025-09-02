
clear all
close all
clc

res1 = readtable('second_CY25-025_1-#1.csv');
res2 = readtable('second_CY35-05_1-#1.csv');
res3 = readtable('second_CY45-05_1-#1.csv');
res1 = table2array(res1);
res2 = table2array(res2);
res3 = table2array(res3);
SOH1 = res1(:, 4);
SOH2 = res2(:, 4);
SOH3 = res3(:, 4);

figure
% plot(1:length(SOH1),SOH1,'LineWidth',1.5,'Color',[0, 0,0])
plot(1:length(SOH1),SOH1,'LineWidth',1.5)
hold on
plot(1:length(SOH2),SOH2,'LineWidth',1.5)
plot(1:length(SOH3),SOH3,'LineWidth',1.5)
grid on;
xlabel("Cycle Number",'FontSize',18,'fontname','Times New Roman','fontweight','bold');
set(gca,'FontSize',18,'fontname','Times New Roman');
ylabel('SOH','FontSize',18,'fontname','Times New Roman','fontweight','bold');
set(gca,'FontSize',18,'fontname','Times New Roman');
% SouthWest  NorthEast
legend('ZHU1','ZHU2','ZHU3', 'Location','NorthEast');
axis([0 800 0.7 1.05]);
set (gcf,'Position',[100,100,600,370])
% zoom plot  SouthWest
% subAxesPosition = [50, 0.87, 27, 0.164];
% zoomAreaPosition = [60, 0.74, 5, 0.044];
% zp = BaseZoom(subAxesPosition, zoomAreaPosition);
% zp.run;
set(gca,'FontSize',18,'fontname','Times New Roman');