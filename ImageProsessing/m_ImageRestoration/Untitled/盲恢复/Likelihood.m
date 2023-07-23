function [fllike]=Likelihood(varargin)
%-----计算似然函数---------------------------------------------
% 确定正确的参数输入
error(nargchk(3,5,nargin))
g=varargin{1};
estg=varargin{2};
liketype=varargin{3};

temp1=0;
for i=1:size(g,1)
    for j=1:size(g,2)
        flg=g(i,j)+1;
        fleb=estg(i,j)+1;
        temp1=temp1+flg*log(fleb)-fleb-LogNatFac(flg);
    end
end
fllike=temp1;
switch liketype
    case 'ML'

    case 'MAP'
        temp1=0;
        if length(varargin)==5
            f=varargin{4};
            p=varargin{5};
        else 
            error('不正确的输入参数数');
        end
        for i=1:size(f,1)
            for j=1:size(f,2)
                flf=f(i,j)+1;
                flp=p(i,j)+1;
                temp1=temp1+flf*log(flp)-flp-LogNatFac(flf);
            end
        end
        fllike=fllike+temp1;
    otherwise
        error('不知的方法');
end
        fllike=fllike/(numel(g));
