function [F,G]=fun1_1(x,H,y,r,DEL)
% Для IST_OMN1
F=norm(H*x-y)^2;G=2*(H'*H*x-H'*y);

