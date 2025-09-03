function fea = genFeatureEn(data,featureNamesCell,options)

rng('default')
data = data';
[len,num] = size(data); 
if len == 1  
    data = data';
    [len,num] = size(data); 
end
allFeaNames = {'psdE','svdpE','eeE','ApEn', 'SpEn','FuzzyEn','PeEn','enveEn','DE'}; 



psdE=zeros(1,num);
if sum(contains(featureNamesCell,{'psdE'}))
    psdE = kPowerSpectrumEntropy(data);
end

svdpE =zeros(1,num);
if sum(contains(featureNamesCell,{'svdpE'}))
    if ~exist('options.svdpEn') 
        options.svdpEn = round(0.5*(len));
    end
    svdpE = kSingularSpectrumEntropy(data,options.svdpEn);
end

eE = zeros(1,num);
if sum(contains(featureNamesCell,{'eeE'}))
    eE = kEnergyEntropy(data);
end
allTimeFea = [psdE;svdpE;eE];

ApEn = zeros(1,num);
if sum(contains(featureNamesCell,{'ApEn'}))
     if num == 1
         ApEn = kApproximateEntropy(data, options.Apdim, options.Apr);  
    else
        for i = 1:num
            ApEn(i) = kApproximateEntropy(data(:,i), options.Apdim, options.Apr);  
        end
    end

end
allTimeFea = [allTimeFea;ApEn];


SpEn = zeros(1,num);
if sum(contains(featureNamesCell,{'SpEn'}))
     if num == 1
         SpEn = kSampleEn(data, options.Spdim, options.Spr); 
    else
        for i = 1:num
            SpEn(i) = kSampleEn(data(:,i), options.Spdim, options.Spr);   
        end
    end

end
allTimeFea = [allTimeFea;SpEn];


FuzzyEn = zeros(1,num);
if sum(contains(featureNamesCell,{'FuzzyEn'}))
    if num == 1
        FuzzyEn = kFuzzyEntropy(data,options.Fuzdim,options.Fuzr,options.Fuzn); 
    else
        for i = 1:num
            FuzzyEn(i) = kFuzzyEntropy(data(:,i),options.Fuzdim,options.Fuzr,options.Fuzn);  
        end
    end
end
allTimeFea = [allTimeFea;FuzzyEn];


PeEn = zeros(1,num);
if sum(contains(featureNamesCell,{'PeEn'}))
     if num == 1
         PeEn = kPermutationEntropy(data, options.Pedim, options.Pet);  
     else
        for i = 1:num
            PeEn(i) = kPermutationEntropy(data(:,i), options.Pedim, options.Pet);  
        end
     end
end
allTimeFea = [allTimeFea;PeEn];

enveEn = zeros(1,num);
if sum(contains(featureNamesCell,{'enveEn'}))
     if num == 1
         enveEn = kEnvelopeEntropy(data,options.fs);  
     else
        for i = 1:num
            enveEn(i) = kEnvelopeEntropy(data(:,i),options.fs);  
        end
     end
end
allTimeFea = [allTimeFea;enveEn];

DE = zeros(1,num);
if sum(contains(featureNamesCell,{'DE'}))
     if num == 1
         DE = kDispersionEn(data, options.DEm, options.DEc, options.DEd);  
     else
        for i = 1:num
            DE(i) = kDispersionEn(data(:,i), options.DEm, options.DEc, options.DEd);  
        end
     end
end
allFea = [allTimeFea;DE];

fea = [];
for i = 1:length(featureNamesCell)
    
    try
    if find(contains(allFeaNames,featureNamesCell{i})) 
        fea = [fea;allFea(find(strcmp(allFeaNames,featureNamesCell{i})),:)];
    end
    catch ME 
    end
end

fea = fea';


 end

function ie = kInformationEntopy(sig,SegmentNum)

[len,num] = size(sig);
if num >= 2
    SigLen = len;  
    if nargin == 1
        SegmentNum = round(1.87*(SigLen-1)^(2/5));  
    end
    CutLen = SigLen/SegmentNum; 
    Ent = [];
    for i = 1:SegmentNum
        Ent = [Ent;sum(sig(round(CutLen*(i-1)+1):round(CutLen*i),:),1)]; 
    end
    pk = Ent./sum(Ent,2); 
    ie = -sum(pk.*log(pk));
end 
if num == 1
    
    [SigLen,~] = size(sig);  
    if nargin == 1
        SegmentNum = round(1.87*(SigLen-1)^(2/5)); 
    end
    CutLen = SigLen/SegmentNum; 
    for i = 1:SegmentNum
        Ent(i) = sum(sig(round(CutLen*(i-1)+1):round(CutLen*i))); 
    end
    pk = Ent/sum(Ent); 
    ie = -sum(pk.*log(pk));
end
end
function svdpE = kSingularSpectrumEntropy(data,n)

[len,num] = size(data);
m = len - n - 1; 
svdpE = []; 
for j = 1:num
    A = []; 
    for i = 1:m
        A = [A;data(i:i+len-m,j)'];
    end

    svdVal = svd(A); 
    
    svdpE(j) = kInformationEntopy(svdVal,length(svdVal))/log2(nnz(svdVal));  
end
end
function psdE = kPowerSpectrumEntropy(data)

[len,num] = size(data);
psdE = []; 
for j = 1:num
    [pxx] = periodogram(data(:,j)); 
    [len,~] = size(pxx);
    psdE(j) = kInformationEntopy( pxx,len)/log2(length(data));
end


end
function eE = kEnergyEntropy(data)

[len,num] = size(data);
for i = 1:num
    imf = emd(data(:,i));
    imfE = sum(imf.^2,2);
    eE(i) = kInformationEntopy(imfE,length(imfE));  
end
end


function ApEn = kApproximateEntropy(data, dim, r)


data = data(:);  
N = length(data); 
phi = zeros(1,2); 
r = r*std(data);

for j = 1:2
    m = dim+j-1;  
    C = zeros(1,N-m+1);    
    dataMat = zeros(m,N-m+1);    
    for i = 1:m
        dataMat(i,:) = data(i:N-m+i); 
    end    
    % counting similar patterns using distance calculation
    for i = 1:N-m+1
        tempMat = abs(dataMat - repmat(dataMat(:,i),1,N-m+1));  
        boolMat = any( (tempMat > r),1);  
        C(i) = sum(~boolMat)/(N-m+1);   
    end
    % summing over the counts
    phi(j) = sum(log(C))/(N-m+1);  
end
ApEn = phi(1)-phi(2);    
end

function kSampleEnValue = kSampleEn(data, dim, r)


data = data(:);  
N = length(data); 
phi = zeros(1,2); 
r = r*std(data);

for j = 1:2
    m = dim+j-1;  
    B = zeros(1,N-m+1);   
    dataMat = zeros(m,N-m+1);    
    for i = 1:m
        dataMat(i,:) = data(i:N-m+i); 
    end    
    for i = 1:N-m
        tempMat = abs(dataMat - repmat(dataMat(:,i),1,N-m+1));  
        boolMat = any( (tempMat > r),1); 
        B(i) = (sum(~boolMat)-1)/(N-m-1);   
    end
    phi(j) = sum(B)/(N-m);  
end
kSampleEnValue = log(phi(1))-log(phi(2));    
end

function FuzEn = kFuzzyEntropy(data,dim,r,n)


data = data(:)';  
N = length(data); 
phi = zeros(1,2); 
r = r*std(data); 

for m = dim:dim+1
    count = zeros(N-m+1,1);    
    dataMat = zeros(N-m+1,m); 
    
    
    for i = 1:N-m+1
        dataMat(i,:) = data(1,i:i+m-1)-mean(data(1,i:i+m-1));  
    end
    
    for j = 1:N-m+1
        
        tempmat=repmat(dataMat(j,:),N-m+1,1);
        dist = max(abs(dataMat - tempmat),[],2); 
        D=exp(-(dist.^n)/r);                     
        count(j) = (sum(D)-1)/(N-m-1);          
    end
    phi(m-dim+1) = sum(count)/(N-m);            
end
    
    FuzEn = log(phi(1)/phi(2));                  
end

function DE = kDispersionEn(x, m, c, d)

N = length(x);


y = normcdf(x, mean(x), std(x));


z = round(c*y+0.5);



dp = zeros(1,N-(m-1)*d);
for i = 1:N-(m-1)*d
    
    z_emb = z(i:d:i+(m-1)*d);
    
    
    dp(i) = 0;
    for j = 1:m
        dp(i) = dp(i) + (z_emb(j)-1) * c^(m-j);
    end
end


classes = 0:c^m-1;

count = histc(dp, classes);

p = count / sum(count);


p(p == 0) = []; 

DE = -sum(p .* log(p))/log(c^m);
end

function pe = kPermutationEntropy(data,m,t)


data = data(:);  
N = length(data);  
permlist = perms(1:m);  
[h,~]=size(permlist);   
c(1:length(permlist))=0;  

 for j=1:N-t*(m-1)  
     [~,iv(j,:)]=sort(data(j:t:j+t*(m-1))); 
     for jj=1:h
         if (abs(permlist(jj,:)-iv(j,:)))==0  
             c(jj) = c(jj) + 1 ; 
         end
     end
 end
c=c(c~=0);  
p = c/sum(c); 
pe = -sum(p .* log2(p));

pe=pe/log2(factorial(m));
end

function enveEn = kEnvelopeEntropy(data,fs)

data = data(:);
ba = [fs*1/4,fs*3/8];  
b = fir1(50,[ba(1) ba(2)]/(fs/2));  
data = bsxfun(@minus,data,mean(data,1));  
xBandPass = conv2(data,b(:),'same');  


xAn = hilbert(xBandPass); 
xEnv = abs(xAn);           


pj = xEnv./sum(xEnv); 
enveEn = -sum(pj.*log(pj));
end