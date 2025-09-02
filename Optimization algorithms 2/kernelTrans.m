function K = kernelTrans(X,  sigma)
    n = size(X, 1); 
    K = zeros(n, n); 

    for i = 1:n
        for j = 1:n
            delta = X(i, :) - X(j, :); 
            K(i, j) = exp(-norm(delta)^2 / (2 * sigma^2)); 
        end
    end
end