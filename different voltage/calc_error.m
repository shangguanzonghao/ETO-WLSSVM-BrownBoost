function [mae,mse,rmse,mape,error,errorPercent,R,r_2]=calc_error(x1,x2)

if nargin==2
    if size(x1,2)==1
        x1=x1';  
    end
    
    if size(x2,2)==1
        x2=x2';  
    end
    
    num=size(x1,2);
    error=x2-x1;
    errorPercent=abs(error)./x1; 
    
    mae=sum(abs(error))/num; 
    mse=sum(error.*error)/num;  
    rmse=sqrt(mse);     
    mape=mean(errorPercent); 
    r=corrcoef(x1,x2);
    R=r(1,2);
    y_mean = mean(x1);
    SS_tot = sum((x1 - y_mean).^2);
    SS_res = sum((x1 - x2).^2);
    r_2 = 1 - (SS_res / SS_tot);
    
    disp(['mae：              ',num2str(mae)])
    disp(['mse：                    ',num2str(mse)])
    disp(['rmse：                ',num2str(rmse)])
    disp(['mape：   ',num2str(mape*100),' %'])
    disp(['R：           ',num2str(R)])
    disp(['R²：                      ',num2str(r_2)])
else
    disp('error')
end

end


