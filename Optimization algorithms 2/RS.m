function [sig2, gamma, Destination_fitness, Convergence_curve] = RS(N, Max_Iter, LB, UB, Dim, type, pn_train, tn_train, pn_test, tn_test)
    Fobj = @(x) fun(x, pn_train, tn_train, pn_test, tn_test, type);
    Destination_position = zeros(1, Dim);
    Destination_fitness = inf;
    Convergence_curve = zeros(1, Max_Iter);
    
 
    X = initialization(N, Dim, UB, LB);
    

    for i = 1:N
        fitness = Fobj(X(i, :));
        if fitness < Destination_fitness
            Destination_position = X(i, :);
            Destination_fitness = fitness;
        end
    end
    Convergence_curve(1) = Destination_fitness;
    
  
    for t = 2:Max_Iter
       
        X = initialization(N, Dim, UB, LB);
        
    
        for i = 1:N
           
            Flag4ub = X(i, :) > UB;
            Flag4lb = X(i, :) < LB;
            X(i, :) = (X(i, :) .* (~(Flag4ub + Flag4lb))) + UB .* Flag4ub + LB .* Flag4lb;
            
          
            fitness = Fobj(X(i, :));
            
      
            if fitness < Destination_fitness
                Destination_position = X(i, :);
                Destination_fitness = fitness;
            end
        end
        
   
        Convergence_curve(t) = Destination_fitness;
    end
    

    sig2 = Destination_position(1);
    gamma = Destination_position(2);
end