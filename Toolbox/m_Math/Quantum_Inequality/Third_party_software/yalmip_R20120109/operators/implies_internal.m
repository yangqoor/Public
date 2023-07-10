function varargout = implies_internal(varargin)

% % Call recursicely on X -> (A,B,...)
% if isa(varargin{1},'sdpvar') & isa(varargin{2},'lmi')
%     if length(varargin{1})==1 & length(varargin{2}) >1
%         F = set([]);
%         for i = 1:length(varargin{2})
%             F = F + implies_internal(varargin{1},varargin{2}(i));
%         end
%         varargout{1} = F;
%         return
%     end
% end

X = varargin{1};
Y = varargin{2};

switch class(X)

    case 'sdpvar'

        switch class(Y)

            case 'sdpvar'              % X --> Y
                varargout{1} = set(Y >= X);

            case {'lmi','constraint'}
                if isa(Y,'constraint')
                    Y = set(Y,[],[],1);
                end
                switch settype(Y)

                    case 'elementwise' % X --> (Y(:)>=0)
                        Y = sdpvar(Y);
                        Y = Y(:);
                        [M,m,infbound]=derivebounds(Y);
                        if infbound
                            warning('You have unbounded variables in IMPLIES leading to a lousy big-M relaxation.');
                        end
                        varargout{1} = set(Y >= (1-X(:)).*m);

                    case 'equality'    % X --> (Y(:)==0)
                        Y = sdpvar(Y);
                        Y = Y(:);
                        [M,m,infbound]=derivebounds(Y);                                          
                        if infbound
                            warning('You have unbounded variables in IMPLIES leading to a lousy big-M relaxation.');
                        end                       
                        varargout{1} = set((1-X).*M >= Y) + set(Y >= (1-X).*m);

                    case 'sdp'         % X --> (Y>=0)
                        if length(X)>1
                            error('IMPLIES not implemented for this case.');
                        end
                        Y = sdpvar(Y);                    
                        % Elements in matrix
                        y = Y(find(triu(ones(length(Y)))));
                        % Derive bounds on all elements
                        [M,m,infbound]=derivebounds(y);
                        if infbound
                            warning('You have unbounded variables in IMPLIES leading to a lousy big-M relaxation.');
                        end
                        % Crude lower bound eig(Y) > -max(abs(Y(:))*n*I
                        m=-max(abs([M;m]))*length(Y);
                        % Big-M relaxation...
                        varargout{1} = set(Y >= (1-X)*m*eye(length(Y)));

                    otherwise
                        error('IMPLIES not implemented for this case');
                end
            otherwise
                error('IMPLIES not implemented for this case');
        end

    case {'lmi','constraint'} % X [>,=,<] 0   ->   Y
        if isa(X,'constraint')
            X = set(X,[],[],1);
        end
        if isa(Y,'constraint')
            Y = set(Y,[],[],1);
        end
     
            if isa(Y,'sdpvar') | isequal(settype(Y),'elementwise') | isequal(settype(Y),'equality') 
               
                switch settype(X)
                    case 'elementwise'
                        X = sdpvar(X);X=X(:);
                        [Mx,mx,infbound]=derivebounds(X);
                        if infbound
                            warning('You have unbounded variables in IMPLIES leading to a lousy big-M relaxation.');
                        end
                        di = binvar(length(X),1);
                        tol = min(abs(Mx - mx)*1e-4,1e-6);
                        % Xi>=0 implies di
                        Guard = [X <= tol + Mx.*di];
                    otherwise
                        error('IMPLIES not implemented for this case');
                end
                
                if all(size(Y)==size(X))
                    % This is a vectorized expression Xi implies Yi
                    d = di;                   
                else                    
                    d = binvar(1);
                    Guard = [Guard, d<=di, d>=(sum(di)-length(di))+1];
                end
                 
                if isa(Y,'sdpvar')
                    if all(size(X)==size(Y))
                        varargout{1} = [Guard, Y>=di];
                    else
                        varargout{1} = [Guard, Y>=0.5*(sum(di)-length(di)+1)];
                    end
                elseif isequal(settype(Y),'elementwise')
                     Y = sdpvar(Y);
                     [My,my]=derivebounds(Y);                                           
                     varargout{1} = [Guard, Y>=my*d];
                elseif isequal(settype(Y),'equality')
                     Y = sdpvar(Y);
                     [My,my]=derivebounds(Y);                            
                     Guard = [Guard, Y>=my*(1-d)];
                     [My,my]=derivebounds(-Y);                            
                     varargout{1} = [Guard, -Y>=my*(1-d)];
                end

            else
                error('IMPLIES not implemented for this case');
            end
    
    otherwise
        error('IMPLIES not implemented for this case');
end

