function [yout_mot, yout_ori, youtx, youty]=compDircDeri_1ord(yout, bmu, bmv)  
youtx = [diff(yout, 1, 2), yout(:,end-1) - yout(:,end)]; 
youty = [diff(yout, 1, 1); yout(end-1,:) - yout(end,:)]; 
yout_mot = youtx .* bmu + youty .* bmv;
yout_ori = - youtx .* bmv + youty .* bmu;