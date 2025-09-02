clear

filename_SOH = 'C:\Users\Administrator\Desktop\data\new_SNL_18650_NMC_25C_0-100_0.5-1C_a_timeseries';
filename_feature = 'C:\Users\Administrator\Desktop\data\second_new_SNL_18650_NMC_25C_0-100_0.5-1C_a_timeseries';
filename_save = 'feature_SOH_SNL_NMC_3.5_3.6';

data1 = readmatrix([filename_SOH,'.csv']);
V_S=3.5;
DC = data1(:, 7);
cycle = data1(:, 3);

begin=1;


unique_cycles = unique(cycle);
max_DC_per_cycle = zeros(size(unique_cycles));
for i = begin:length(unique_cycles)
    cycle_indices = (cycle == unique_cycles(i));
    max_DC_per_cycle(i) = max(DC(cycle_indices));
end


SOH = max_DC_per_cycle / max_DC_per_cycle(begin);


for i = begin:length(SOH)
    if SOH(i) > 1 || SOH(i) == 0
        if i == begin
            
            SOH(i) = SOH(i + 1);
        elseif i == length(SOH)
            
            SOH(i) = SOH(i - 1);
        else
            
            SOH(i) = (SOH(i - 1) + SOH(i + 1)) / 2;
        end
    end
end
feature_SOH = [];
feature_SOH(:,10) = SOH;


data2 = readmatrix([filename_feature,'.csv']);

cycle2 = data2(:, 1);
voltage = data2(:, 3);
current = data2(:, 4);
time = data2(:, 2);

unique_cycles2 = unique(cycle2);

for voltage_start = V_S
for voltage_end = voltage_start + 0.1
  
for j = begin:length(unique_cycles2)
     cycle_indices2 = (cycle2 == unique_cycles2(j));
     voltage_cycle = voltage(cycle_indices2);
     time_cycle = time(cycle_indices2);
     

     voltage_in_range_indices = find(voltage_cycle >= voltage_start & voltage_cycle <= voltage_end);
     
     if ~isempty(voltage_in_range_indices)
    
    first_4_1_index = find(voltage_cycle >= voltage_end, 1);
    
    
  
        voltage_in_range_indices = voltage_in_range_indices(1:first_4_1_index-voltage_in_range_indices(1));
  
     end
    

    voltage_in_range = voltage_cycle(voltage_in_range_indices);
    plot(time_cycle(voltage_in_range_indices),voltage_in_range,'Color', [0 0 1] * (j / length(unique_cycles)));
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



fea = genFeatureEn(voltage_in_range,featureNamesCell,option);
fea(isnan(fea)) = 0;

feature_SOH( j , 1 ) = fea(1);
feature_SOH( j , 2 ) = fea(2);
feature_SOH( j , 3 ) = fea(3);
feature_SOH( j , 4 ) = fea(4);
feature_SOH( j , 5 ) = fea(5);
feature_SOH( j , 6 ) = fea(6);
feature_SOH( j , 7 ) = fea(7);
feature_SOH( j , 8 ) = fea(8);
feature_SOH( j , 9 ) = fea(9);

end

end
end
result_table = array2table(feature_SOH, 'VariableNames', {'psdE','svdpE','eeE','ApEn', 'SpEn','FuzzyEn','PeEn','enveEn','DE', 'SOH'});
writetable(result_table, [filename_save, '.csv']);
