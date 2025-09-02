clear
data = readtable('feature_SOH_SNL_NMC_3.6_3.7.csv');
data = table2array(data);
correlations_v = zeros(1, 9);
for k = 1:9
    correlations_v(k) = corr(data(:, k), data(:,10));
end

disp('corr:');
disp(correlations_v);