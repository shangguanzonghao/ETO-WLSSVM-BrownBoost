function [sig2, gamma, Destination_fitness, Convergence_curve] = BO(N, Max_Iter, LB, UB, Dim, type, pn_train, tn_train, pn_test, tn_test)

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


for iter = (num_initial + 1):num_iterations
   
    gpr_model = fitrgp(X, Y, 'Basis', 'linear', ...
                      'KernelFunction', 'ardsquaredexponential', ...
                      'Standardize', true);
    
    
    num_candidates = 1000;
    candidates = bsxfun(@plus, ...
                       bsxfun(@times, rand(num_candidates, Dim), (UB - LB)), ...
                       LB);
    
    
    [y_pred, y_sd] = predict(gpr_model, candidates);
    f_min = min(Y);
    z = (f_min - y_pred) ./ max(y_sd, 1e-6);
    EI = (f_min - y_pred) .* normcdf(z) + y_sd .* normpdf(z);
    
    
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