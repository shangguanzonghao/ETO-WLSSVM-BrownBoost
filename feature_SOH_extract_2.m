clear
filename_SOH = 'I:\wenzhou\Wenzhou_Cell_#04\Wenzhou_Cell_#04_Cycle';
filename_feature = 'I:\response_exp\wenzhou\second_Wenzhou_Cell_#04';
filename_save = 'feature_SOH_wenzhou_#04';

data1 = readmatrix([filename_SOH,'.xlsx']);
data2 = readmatrix([filename_feature,'.csv']);

cycle1 = data1(:,1) ;
for i = 100:length(cycle1) 
    if cycle1(i) == 1
        
        cycle1(i:end) = cycle1(i-1) + cycle1(i:end); 
        break; 
    end
end


data1(:,1) = cycle1;

cycle2 = data2(:, 1);
voltage = data2(:, 3);
current = data2(:, 4);
time = data2(:, 2);

unique_cycles2 = unique(cycle2);

set_end = 613;
matching_rows = ismember(data1(:, 1), unique_cycles2);
B_matched = data1(matching_rows, [1,3]);
SOH = B_matched( :, 2)/B_matched(1,2);
feature_SOH = [];
feature_SOH(:,4) = SOH(1:set_end);
temp = [];
count = 0;
for voltage_start = 3.8
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
    
     

    
    featureNamesCell = {'psdE','FuzzyEn','DE'}; 


option.Fuzdim = 2;
option.Fuzr   = 0.15;
option.Fuzn   = 2;

option.DEm = 2; 
option.DEc = 6; 
option.DEd = 1; 


if isscalar(voltage_in_range) || isempty(voltage_in_range)
    voltage_in_range = temp;
    count = count+1;
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
