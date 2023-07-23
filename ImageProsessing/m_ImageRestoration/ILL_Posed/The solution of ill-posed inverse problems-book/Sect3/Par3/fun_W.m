function [F,G]=fun_W(x,H,y,r,h)
F=norm(H*x-y)^2;G=2*(H'*H*x-H'*y);
