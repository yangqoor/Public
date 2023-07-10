clear all;

load_database;

%% Triangulation Main---------------------------------
num = input('How many nodes would you like to use in this triangulation?\n','s');
num = str2double(num);
fprintf('Which node ID numbers would you like to use?\n');

for i = 1:num
    prompt = 'Node ID: ';
    node_sel(i) = input(prompt,'s');
%     nodes_in_use = [s1,node_sel(i)];
end
% num = 2;
% nodes_in_use = '12';
% triangulate(nodes_in_use,num,database)
fprintf('Using nodes:'); 
[lat,lon] = triangulate(node_sel,num,database);
fprintf('Approximate tag location: %f°, %f° \n',lat,lon);

