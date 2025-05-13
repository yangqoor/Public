function [zx, zy]=compDeri_mirror_1ord(z)
zx = [z(:,2) - z(:, 1), -diff(z,1,2)]; 
zy = [z(2,:) - z(1, :); -diff(z,1,1)]; 