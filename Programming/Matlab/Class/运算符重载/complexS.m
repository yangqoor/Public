classdef complexS
    properties
        real,imag
    end
    methods
        function obj=complexS(real,imag)
            obj.real=real;
            obj.imag=imag;
        end
        % 显示
        function disp(obj)
            if obj.real==0
                switch true
                    case obj.imag==0,fprintf('%s','0');
                    case obj.imag>0,fprintf('%s',[num2str(obj.imag),'i']);
                    case obj.imag<0,fprintf('%s',[num2str(obj.imag),'i']);
                end
            else
                fprintf('%s',num2str(obj.real))
                switch true
                    case obj.imag==0
                    case obj.imag>0,fprintf('%s',['+',num2str(obj.imag),'i']);
                    case obj.imag<0,fprintf('%s',[num2str(obj.imag),'i']);
                end
            end
            fprintf('\n');
        end
        % 加法
        function obj=plus(obj,arg)
            if isa(arg,'double')
                obj.real=obj.real+arg;
            else
                obj.real=obj.real+arg.real;
                obj.imag=obj.imag+arg.imag;
            end
        end
        % 减法
        function obj=minus(obj,arg)
            if isa(arg,'double')
                obj.real=obj.real-arg;
            else
                obj.real=obj.real-arg.real;
                obj.imag=obj.imag-arg.imag;
            end
        end
        % 一元减法
        function obj=uminus(obj)
            obj.real=-obj.real;
            obj.imag=-obj.imag;
        end
        % 乘法
        function obj=mtimes(obj,arg)
            if isa(arg,'double')
                obj.real=obj.real.*arg;
                obj.imag=obj.imag.*arg;
            else
                [obj.real,obj.imag]=...
                    deal(obj.real*arg.real-obj.imag*arg.imag,...
                         obj.real*arg.imag+obj.imag*arg.real);
            end
        end

        % 除法
        function obj=mrdivide(obj,arg)
            if isa(arg,'double')
                obj.real=obj.real./arg;
                obj.imag=obj.imag./arg;
            else
                [obj.real,obj.imag]=...
                    deal(obj.real*arg.real+obj.imag*arg.imag,...
                        -obj.real*arg.imag+obj.imag*arg.real);
                obj.real=obj.real./(arg.real.^2+arg.imag.^2);
                obj.imag=obj.imag./(arg.real.^2+arg.imag.^2);
            end
        end
        % 共轭
        function obj=conj(obj)
            obj.imag=-obj.imag;
        end
        % 模长
        function normval=norm(obj)
            normval=norm([obj.real,obj.imag]);
        end
    end
end