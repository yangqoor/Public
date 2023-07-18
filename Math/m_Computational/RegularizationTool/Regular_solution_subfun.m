function [roots_degree] = Regular_solution_subfun(func,flag)
% Regular_solution_sub-function
% Description:
%    The [regsolution] is a symbolic expression on general maple's [solve.m] 
%    function. "R" symbolic-variant have selected as symbolic variable for 
%    [regsolution]. This solution sub-function-output are returned the 
%    regular solution technique with solution's roots order-degree.
%
% Syntax:
%    Sytax.input : func         =  differential equation's symbolic function f(R).
%                  flag=true than visible all solution else flag=false than
%                                  not-visible.
%    Sytax.output: rootsdegree  =  differential equation's regular roots. 
%
%
% Example:
%    regsolution((R^10-4)*(R^2+1)^4*sin(R),1);   <--|
%
% *** Equation's roots && order-degree 
%        0             1.0000          
%        0 + 1.0000i   4.0000          
%        0 - 1.0000i   4.0000          
%   1.1487             1.0000          
%  -1.1487             1.0000          
%  -0.9293 - 0.6752i   1.0000          
%   0.9293 + 0.6752i   1.0000          
%  -0.3550 - 1.0925i   1.0000          
%   0.3550 + 1.0925i   1.0000          
%  -0.3550 + 1.0925i   1.0000          
%   0.3550 - 1.0925i   1.0000          
%  -0.9293 + 0.6752i   1.0000          
%   0.9293 - 0.6752i   1.0000    %
%
%  *** Generaly solution with maple solve function's output
%  solution = solve((R^10-4)*(R^2+1)^4*sin(R),R)
%
%                                                                   sqrt(-1)
%                                                                   sqrt(-1)
%                                                                   sqrt(-1)
%                                                                   sqrt(-1)
%                                                                  -sqrt(-1)
%                                                                  -sqrt(-1)
%                                                                  -sqrt(-1)
%                                                                  -sqrt(-1)
%                                                                    2^(1/5)
%                                                                   -2^(1/5)
%  -((1/4*5^(1/2)-1/4+1/4*sqrt(-1)*2^(1/2)*(5+5^(1/2))^(1/2))*2^(2/5))^(1/2)
%   ((1/4*5^(1/2)-1/4+1/4*sqrt(-1)*2^(1/2)*(5+5^(1/2))^(1/2))*2^(2/5))^(1/2)
% -((-1/4*5^(1/2)-1/4+1/4*sqrt(-1)*2^(1/2)*(5-5^(1/2))^(1/2))*2^(2/5))^(1/2)
%  ((-1/4*5^(1/2)-1/4+1/4*sqrt(-1)*2^(1/2)*(5-5^(1/2))^(1/2))*2^(2/5))^(1/2)
% -((-1/4*5^(1/2)-1/4-1/4*sqrt(-1)*2^(1/2)*(5-5^(1/2))^(1/2))*2^(2/5))^(1/2)
%  ((-1/4*5^(1/2)-1/4-1/4*sqrt(-1)*2^(1/2)*(5-5^(1/2))^(1/2))*2^(2/5))^(1/2)
%  -((1/4*5^(1/2)-1/4-1/4*sqrt(-1)*2^(1/2)*(5+5^(1/2))^(1/2))*2^(2/5))^(1/2)
%   ((1/4*5^(1/2)-1/4-1/4*sqrt(-1)*2^(1/2)*(5+5^(1/2))^(1/2))*2^(2/5))^(1/2)


syms R real

if  nargin==false || isempty(func) 
    error('Solving equation is not selected')
end

%% Regular solution matrix components
solution_general  = solve(func,R);
solution_equation = sort(solution_general);




solution_degree           = 0;
solution_activeroot_value = 1;
solution_value            = [] ;
solution_base_matrix_row  = 1;

%% Finding per unit root value solution's order-degree
while solution_activeroot_value <= size(solution_equation,1)
   for i=1:size(solution_equation,1)        % total root value
        if  isempty(solution_value) == 1 || solution_value ~= solution_equation(solution_activeroot_value) 
            if  solution_equation(solution_activeroot_value) == solution_equation(i)
                         solution_degree = solution_degree+1;
%                        roots_degree(solution_activeroot_value,:) = [solution(solution_activeroot_value),solution_degree];   

            end
        end
   end

            solution_value                           = solution_equation(solution_activeroot_value);
            roots_degree(solution_base_matrix_row,:) = [solution_equation(solution_activeroot_value),solution_degree];   
            solution_base_matrix_row                 = solution_base_matrix_row + 1;
            solution_activeroot_value                = solution_activeroot_value+solution_degree;
            solution_degree                          = 0;
end

%Conversion  symbolic matrix to double matrix
roots_degree=double(roots_degree);

%all solution visible for flag==true or false
if flag==true
    solution_general
    solution_equation
    roots_degree
end