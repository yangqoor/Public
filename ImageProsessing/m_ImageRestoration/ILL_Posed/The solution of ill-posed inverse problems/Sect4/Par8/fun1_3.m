function [F,G]=fun1_3(z,A,u,ze,rE,DLL,h)
% Для Auxil1
F=-norm(z-ze)^2*h-norm(diff(z)-diff(ze))^2/h;G=-2*(z-ze)*h;

