function Data=SStats(Cr,Cf)
% Copyright (c) 2023, Zhaoxu Liu / slandarer
% Zhaoxu Liu / slandarer (2023). taylor diagram class 
% (https://www.mathworks.com/matlabcentral/fileexchange/130889-taylor-diagram-class), 
% MATLAB Central File Exchange.
Cr = Cr(:); 
Cf = Cf(:);
nanInd = isnan(Cr)|isnan(Cf);
Cr(nanInd) = [];
Cf(nanInd) = [];

% N  = length(Cf);
MEAN = mean(Cf);
STD  = std(Cf,1);
RMSD = std(Cf-Cr,1);
COR  = corrcoef(Cf,Cr);
Data = [MEAN, STD, RMSD, COR(1,2)].';

%% calculation formula of STD RMSD and COR
% N = length(Cf);
%
% 		    /  sum[ {C-mean(C)} .^2]  \
% STD = sqrt|  ---------------------  |
% 		    \          N              /
%
% Equivalent calculation formula:
% STD = sqrt(sum((Cf-mean(Cf)).^2)./N);
% STD = norm(Cf-mean(Cf))./sqrt(N);
% STD = rms(Cf-mean(Cf));
% STD = sqrt(var(Cf,1));
% STD = std(Cf,1);
  

% 		     /  sum[  { [C-mean(C)] - [Cr-mean(Cr)] }.^2  ]  \
% RMSD = sqrt|  -------------------------------------------  |
% 		     \                      N                        /
% 
% Equivalent calculation formula:
% RMSD = sqrt(sum((Cf-mean(Cf)-(Cr-mean(Cr))).^2)./N);
% RMSD = norm(Cf-mean(Cf)-Cr+mean(Cr))./sqrt(N);
% RMSD = rmse(Cr-mean(Cr),Cf-mean(Cf));
% RMSD = rms(Cf-mean(Cf)-Cr+mean(Cr));
% RMSD = sqrt(var(Cf-Cr,1));
% RMSD = std(Cf-Cr,1);


% 		sum( [C-mean(C)].*[Cr-mean(Cr)] ) 
% COR = --------------------------------- 
% 		         N*STD(C)*STD(Cr)
%
% Equivalent calculation formula:
% COR = sum((Cf-mean(Cf)).*(Cr-mean(Cr)))./N./std(Cf,1)./std(Cr,1);
% COR = (Cf-mean(Cf)).'*(Cr-mean(Cr))./N./std(Cf,1)./std(Cr,1);
% COR = [1,0]*cov(Cf,Cr,1)./std(Cf,1)./std(Cr,1)*[0;1];
% COR = [1,0]*corrcoef(Cf,Cr)*[0;1];
end