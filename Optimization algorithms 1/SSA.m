
function [sig2, gamma,Best_score,curve]=SSA(pop,Max_iter,lb,ub,dim,type,pn_train,tn_train,pn_test,tn_test)
fobj=@(x)fun(x,pn_train,tn_train,pn_test,tn_test,type);
ST = 0.6;
PD = 0.7;
SD = 0.2;

PDNumber = round(pop*PD); 
SDNumber = round(pop*SD);
if(max(size(ub)) == 1)
   ub = ub.*ones(1,dim);
   lb = lb.*ones(1,dim);  
end


X0=initialization(pop,dim,ub,lb);
X = X0;

fitness = zeros(1,pop);
for i = 1:pop
   fitness(i) =  fobj(X(i,:));
end
 [fitness, index]= sort(fitness);
BestF = fitness(1);
WorstF = fitness(end);
GBestF = fitness(1);
for i = 1:pop
    X(i,:) = X0(index(i),:);
end
curve=zeros(1,Max_iter);
GBestX = X(1,:);
X_new = X;
for i = 1: Max_iter
    disp(['the',num2str(i),'th'])
    BestF = fitness(1);
    WorstF = fitness(end);

    
    R2 = rand(1);
   for j = 1:PDNumber
      if(R2<ST)
          X_new(j,:) = X(j,:).*exp(-j/(rand(1)*Max_iter));
      else
          X_new(j,:) = X(j,:) + randn()*ones(1,dim);
      end     
   end
   for j = PDNumber+1:pop

        if(j>(pop - PDNumber)/2 + PDNumber)
          X_new(j,:)= randn().*exp((X(end,:) - X(j,:))/j^2);
       else
          
          A = ones(1,dim);
          for a = 1:dim
            if(rand()>0.5)
                A(a) = -1;
            end
          end 
          AA = A'*inv(A*A');     
          X_new(j,:)= X(1,:) + abs(X(j,:) - X(1,:)).*AA';
       end
   end
   Temp = randperm(pop);
   SDchooseIndex = Temp(1:SDNumber); 
   for j = 1:SDNumber
       if(fitness(SDchooseIndex(j))>BestF)
           X_new(SDchooseIndex(j),:) = X(1,:) + randn().*abs(X(SDchooseIndex(j),:) - X(1,:));
       elseif(fitness(SDchooseIndex(j))== BestF)
           K = 2*rand() -1;
           X_new(SDchooseIndex(j),:) = X(SDchooseIndex(j),:) + K.*(abs( X(SDchooseIndex(j),:) - X(end,:))./(fitness(SDchooseIndex(j)) - fitness(end) + 10^-8));
       end
   end
  
   for j = 1:pop
       for a = 1: dim
           if(X_new(j,a)>ub)
               X_new(j,a) =ub(a);
           end
           if(X_new(j,a)<lb)
               X_new(j,a) =lb(a);
           end
       end
   end 
   
   for j=1:pop
    fitness_new(j) = fobj(X_new(j,:));
   end
   for j = 1:pop
    if(fitness_new(j) < GBestF)
       GBestF = fitness_new(j);
        GBestX = X_new(j,:);   
    end
   end
   X = X_new;
   fitness = fitness_new;
   
   [fitness, index]= sort(fitness);
   BestF = fitness(1);
   WorstF = fitness(end);
   for j = 1:pop
      X(j,:) = X(index(j),:);
   end
   curve(i) = GBestF;
end
Best_pos =GBestX;
Best_score = curve(end);
    sig2 = Best_pos(1);
    gamma = Best_pos(2);
end



