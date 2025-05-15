function [youtx, youty]=compDeri_1ord(yout)
youtx = [diff(yout, 1, 2), yout(:,1) - yout(:,n)]; 
youty = [diff(yout, 1, 1); yout(1,:) - yout(m,:)]; 