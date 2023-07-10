function [F,G]=fun4(x,H,y,r)
F=norm(H*x-y)^2;G=2*(H'*H*x-H'*y);
