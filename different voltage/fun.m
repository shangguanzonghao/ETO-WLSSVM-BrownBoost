function fitness=fun(Position,pn_train,tn_train,pn_test,tn_test,type)
        sig2=Position(2);
        gamma=Position(1);
        [alpha,b] = trainlssvm({pn_train,tn_train,type,gamma,sig2,'RBF_kernel'});
        C= 10;
        M = length(pn_train);
        e = alpha/C;
 v1 = weights(e,2.5,3);
 unit = ones(M, 1);
 zero = zeros(1, 1);
 upmat = [zero, unit']; 
 K = kernelTrans(pn_train,  sig2);
 downmat = [unit, K + v1 / C];
 completemat = [upmat; downmat];
 rightmat = [zero; tn_train];
 b_alpha = completemat \ rightmat;
 b1 = b_alpha(1);
 alphas1 = b_alpha(2:end);  
 
 for j = 1:size(pn_test, 1)
    Kx = exp(-pdist2(pn_test(j, :), pn_train).^2 / (2 * sig2^2)); 
    predict_test(:, j) = Kx * alphas1 + b1; 
 end
        predict_test = predict_test';
        fitness= sqrt(sum((tn_test-predict_test).^2)/size(tn_test,1));
end
