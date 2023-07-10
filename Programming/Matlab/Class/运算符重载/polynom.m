classdef polynom
    properties
        coe
    end
    methods
        function obj=polynom(coe)
            obj.coe=coe;
        end
% =========================================================================
% 输出 --------------------------------------------------------------------
        function disp(obj)
            if all(obj.coe==0)
            disp('0')
            else
            baseStr=char(32.*ones([1,length(obj.coe)*10]));
            for i=1:length(obj.coe)
                tStr='';
                if obj.coe(i)~=0
                    if obj.coe(i)>0
                        oStr='+';
                    else
                        oStr='';
                    end
                    nStr=num2str(obj.coe(i));
                    if i~=length(obj.coe)
                    if str2double(nStr)==1,nStr='';end
                    if str2double(nStr)==-1,nStr='-';end
                    end
                    if i==(length(obj.coe)-1)
                        tStr=[oStr,nStr,'x'];
                    else
                        tStr=[oStr,nStr,'x^',num2str(length(obj.coe)-i)];
                    end
                end
                ind=find(abs(baseStr)==32,1);
                baseStr(ind:ind+length(tStr)-1)=tStr;
            end
            baseStr(abs(baseStr)==32)=[];
            if strcmp(baseStr(end-2:end),'x^0'),baseStr(end-2:end)=[];end
            if strcmp(baseStr(1),'+'),baseStr(1)=[];end
            disp(baseStr)
            end
        end
% 加法 --------------------------------------------------------------------
        function obj=plus(obj,arg)
            if isa(arg,'double')
                tcoe=arg;
            else
                tcoe=arg.coe;
            end
            L1=length(obj.coe);
            L2=length(tcoe);
            baseCoe=zeros([1,max(L1,L2)+1]);
            baseCoe(end+1-L1:end)=baseCoe(end+1-L1:end)+obj.coe;
            baseCoe(end+1-L2:end)=baseCoe(end+1-L2:end)+tcoe;
            obj.coe=baseCoe(find(baseCoe~=0,1):end);
        end
% 减法 --------------------------------------------------------------------
        function obj=minus(obj,arg)
            if isa(arg,'double')
                tcoe=arg;
            else
                tcoe=arg.coe;
            end
            L1=length(obj.coe);
            L2=length(tcoe);
            baseCoe=zeros([1,max(L1,L2)+1]);
            baseCoe(end+1-L1:end)=baseCoe(end+1-L1:end)+obj.coe;
            baseCoe(end+1-L2:end)=baseCoe(end+1-L2:end)-tcoe;
            obj.coe=baseCoe(find(baseCoe~=0,1):end);
        end
        function obj=uminus(obj)
            obj.coe=-obj.coe;
        end
% 乘法 --------------------------------------------------------------------
        function obj=mtimes(obj,arg)
            L1=length(obj.coe);
            L2=length(arg.coe);
            tmat=zeros(L2,L1+L2-1);
            for i=1:L2
                tmat(i,i:(i+L1-1))=arg.coe(i).*obj.coe;
            end
            obj.coe=sum(tmat);
        end
% 带余除法 -----------------------------------------------------------------
        function [obj1,obj2]=mrdivide(obj,arg)
            L1=length(obj.coe);
            L2=length(arg.coe);

            tCoe=obj.coe;
            obj1=polynom(0);
            for i=1:(L1+1-L2)
                obj1.coe(i)=1./(arg.coe(1)).*(tCoe(1));
                tCoe(1:L2)=tCoe(1:L2)-arg.coe.*obj1.coe(i);
                tCoe(1)=[];
            end
            obj2=polynom(tCoe);
        end

% 数值计算 -----------------------------------------------------------------
        function value=val(obj,x)
            value=x.^(length(obj.coe)-1:-1:0)*(obj.coe.');
        end
% 积分 --------------------------------------------------------------------
        function output=int(obj,a,b)
            if nargin<2
                output=polynom([obj.coe./(length(obj.coe):-1:1),0]);
            else
                tcoe=[obj.coe./(length(obj.coe):-1:1),0];
                output=b.^(length(tcoe)-1:-1:0)*(tcoe.')-...
                       a.^(length(tcoe)-1:-1:0)*(tcoe.');
            end
        end
% 求导 --------------------------------------------------------------------
        function obj=diff(obj)
            obj.coe=obj.coe.*(length(obj.coe)-1:-1:0);
            obj.coe(end)=[];
        end
% 比较 --------------------------------------------------------------------
        function bool=eq(obj,arg)
            if length(obj.coe)~=length(arg.coe)
                bool=false;
            else
                bool=all(obj.coe==arg.coe);
            end
        end
        function bool=ne(obj,arg)
            if length(obj.coe)~=length(arg.coe)
                bool=true;
            else
                bool=~all(obj.coe==arg.coe);
            end
        end
    end
end