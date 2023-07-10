function yaw = rotate_yd(theta)
yaw = [cosd(theta) 0 sind(theta);0 1 0;-sind(theta) 0 cosd(theta)];
end