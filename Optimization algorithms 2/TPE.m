function [sig2, gamma, Destination_fitness, Convergence_curve] = TPE(N, Max_Iter, LB, UB, Dim, type, pn_train, tn_train, pn_test, tn_test)

Fobj = @(x) fun(x, pn_train, tn_train, pn_test, tn_test, type);


Destination_position = zeros(1, Dim);
Destination_fitness = inf;
Convergence_curve = inf(1, Max_Iter);  


num_initial = N;                  
num_iterations = Max_Iter;        
search_space = [LB; UB];          


initial_samples = lhsdesign(num_initial, Dim);
X = bsxfun(@plus, ...
           bsxfun(@times, initial_samples, (UB - LB)), ...
           LB);
Y = zeros(num_initial, 1);


for i = 1:num_initial
    Y(i) = Fobj(X(i, :));
    if Y(i) < Destination_fitness
        Destination_fitness = Y(i);
        Destination_position = X(i, :);
    end
    Convergence_curve(i) = Destination_fitness;
end


gamma = 0.25;  
for iter = (num_initial + 1):num_iterations
 
    threshold = quantile(Y, gamma);  
    good_samples = X(Y <= threshold, :);  
    bad_samples = X(Y > threshold, :);   
    
  
    num_candidates = 1000;  
    candidates = bsxfun(@plus, ...
                       bsxfun(@times, rand(num_candidates, Dim), (UB - LB)), ...
                       LB);
    

    l = ones(num_candidates, 1);  
    g = ones(num_candidates, 1);  
    
 
    for d = 1:Dim
        if size(good_samples, 1) > 1
            l_d = ksdensity(good_samples(:, d), candidates(:, d), 'Function', 'pdf');
            l = l .* l_d';
        end
        
        if size(bad_samples, 1) > 1
            g_d = ksdensity(bad_samples(:, d), candidates(:, d), 'Function', 'pdf');
            g = g .* g_d';
        end
    end
    
 
    EI = l ./ g;
    EI(isnan(EI)) = 0;  
    
  
    [~, idx] = max(EI);
    new_point = candidates(idx, :);
    
   
    new_value = Fobj(new_point);
    
   
    X = [X; new_point];
    Y = [Y; new_value];
    
  
    if new_value < Destination_fitness
        Destination_fitness = new_value;
        Destination_position = new_point;
    end
    

    Convergence_curve(iter) = Destination_fitness;
end


sig2 = Destination_position(1);
gamma = Destination_position(2);
end