function [sig2, gamma, Destination_fitness, Convergence_curve] = GS(N, Max_Iter, LB, UB, Dim, type, pn_train, tn_train, pn_test, tn_test)
    Fobj = @(x) fun(x, pn_train, tn_train, pn_test, tn_test, type);
    
  
    if Dim ~= 2
        error('ERROR');
    end
    
    
    sig2_values = linspace(LB(1), UB(1), N);  
    gamma_values = linspace(LB(2), UB(2), N); 
    [SIG2, GAMMA] = meshgrid(sig2_values, gamma_values);
    param_combinations = [SIG2(:), GAMMA(:)]; 
    
  
    Destination_fitness = inf;
    Destination_position = zeros(1, Dim);
    
    
    for i = 1:size(param_combinations, 1)
        current_param = param_combinations(i, :);
        fitness = Fobj(current_param);
        
        
        if fitness < Destination_fitness
            Destination_fitness = fitness;
            Destination_position = current_param;
        end
    end
    

    sig2 = Destination_position(1);
    gamma = Destination_position(2);
    
    
    Convergence_curve = ones(1, Max_Iter) * Destination_fitness;
end