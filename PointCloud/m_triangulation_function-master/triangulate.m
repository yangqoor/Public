function [final_lat,final_lon] = triangulate(node,num,database)
% function triangulate(node,num,database)
 for i = 1:num
     nodes = str2double(node(i));
     fprintf('%d ',nodes); 
     lat(i) = database.data(nodes,1);
     long(i)= database.data(nodes,2);
 end
 fprintf('\n');
 final_lat = mean(lat);
 final_lon = mean(long);
end