function colorList=nclCM(type,num)
% % @author : slandarer
% -----------------------
% type : type of colorbar
% num  : number of colors
if nargin<2
    num=-1;
end
if nargin<1
    type=73;
end
try
    nclCM_Data=load('nclCM_Data.mat');
catch
    nclCM_Data=load('nclCM\nclCM_Data.mat');
end
CList_Data=nclCM_Data.Colors;
disp(nclCM_Data.author);

if isnumeric(type)
    Cmap=CList_Data{type};
else
    Cpos=strcmpi(type,nclCM_Data.Names);
    Cmap=CList_Data{find(Cpos,1)};
end
if num>0
Ci=1:size(Cmap,1);Cq=linspace(1,size(Cmap,1),num);
colorList=[interp1(Ci,Cmap(:,1),Cq,'linear')',...
           interp1(Ci,Cmap(:,2),Cq,'linear')',...
           interp1(Ci,Cmap(:,3),Cq,'linear')'];
else
colorList=Cmap;
end
% Zhaoxu Liu / slandarer (2022). ncl colormaps 
% (https://www.mathworks.com/matlabcentral/fileexchange/120848-ncl-colormaps), 
% MATLAB Central File Exchange. 检索来源 2022/11/19.
end