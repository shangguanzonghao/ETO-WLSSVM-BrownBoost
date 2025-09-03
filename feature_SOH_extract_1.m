clear

filename_feature = 'I:\response_exp\uofm\12_cycling_wExpansion';
filename_save = 'second_12_cycling_wExpansion';

data2 = readmatrix([filename_feature,'.csv']);

cycle2 = data2(:, 1);
voltage = data2(:, 3);
current = data2(:, 4);
time = data2(:, 2);
capacity = data2(:, 5);

unique_cycles2 = unique(cycle2);

max_DC_per_cycle = zeros(size(unique_cycles2));
for i = 1:length(unique_cycles2)
    cycle_indices = (cycle2 == unique_cycles2(i));
    max_DC_per_cycle(i) = max(capacity(cycle_indices));
end


SOH = max_DC_per_cycle / max_DC_per_cycle(1);

for i = 1:length(SOH)
    if SOH(i) > 1 || SOH(i) == 0
        if i == 1
            
            SOH(i) = SOH(i + 1);
        elseif i == length(SOH)
            
            SOH(i) = SOH(i - 1);
        else
            
            SOH(i) = (SOH(i - 1) + SOH(i + 1)) / 2;
        end
    end
end
feature_SOH = [];
feature_SOH(:,4) = SOH;

set_end = length(unique_cycles2);


temp = [];
count = 0;
for voltage_start = 3.6
for voltage_end = voltage_start + 0.1
  
for j = 1:set_end
     cycle_indices2 = (cycle2 == unique_cycles2(j));
     voltage_cycle = voltage(cycle_indices2);
     time_cycle = time(cycle_indices2);
     

     voltage_in_range_indices = find(voltage_cycle >= voltage_start & voltage_cycle <= voltage_end);
     
     if ~isempty(voltage_in_range_indices)
    
    first_4_1_index = find(voltage_cycle >= voltage_end, 1);
    
    
  
        voltage_in_range_indices = voltage_in_range_indices(1:first_4_1_index-voltage_in_range_indices(1));
  
     end
    
  
    voltage_in_range = voltage_cycle(voltage_in_range_indices);
    plot(time_cycle(voltage_in_range_indices),voltage_in_range,'Color', [0 0 1] * (j / length(unique_cycles2)));
    hold on;
    
     

    
    featureNamesCell = {'psdE','svdpE','eeE','ApEn', 'SpEn','FuzzyEn','PeEn','enveEn','DE'}; 

option.svdpEn = 20; 


option.Apdim  = 2;
option.Apr   = 0.15;


option.Spdim  = 2;
option.Spr   = 0.15;


option.Fuzdim = 2;
option.Fuzr   = 0.15;
option.Fuzn   = 2;


option.Pedim = 6;
option.Pet   = 1;


option.fs   = 1000;



option.DEm = 2; 
option.DEc = 6; 
option.DEd = 1; 

if length(voltage_in_range)<=2
featuresv(j, :) = 0;
continue
end
fea = genFeatureEn(voltage_in_range,featureNamesCell,option); 

feature_SOH( j , 1 ) = fea(1);
feature_SOH( j , 2 ) = fea(2);
feature_SOH( j , 3 ) = fea(3);

temp = voltage_in_range;
end

end
end
result_table = array2table(feature_SOH, 'VariableNames', {'PSDE', 'FuzzyEn', 'DE', 'SOH'});
writetable(result_table, [filename_save, '.csv']);
