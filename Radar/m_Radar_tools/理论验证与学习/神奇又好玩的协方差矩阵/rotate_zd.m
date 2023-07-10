function yaw = rotate_zd(theta)
yaw = [cosd(theta) -sind(theta) 0;sind(theta) cosd(theta) 0;0 0 1];
end