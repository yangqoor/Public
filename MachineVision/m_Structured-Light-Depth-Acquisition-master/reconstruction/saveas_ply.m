% function used to save point cloud as PLY file
function saveas_ply(point_cloud, file_name)
    [N, ~] = size(point_cloud);
    
    file_id = fopen([file_name,'.txt'], 'w');
    fprintf(file_id, ['ply','\n']);
    fprintf(file_id, ['format ascii 1.0\n']);
    fprintf(file_id, ['element vertex ', num2str(N), '\n']);
    fprintf(file_id, ['property float x', '\n']);
    fprintf(file_id, ['property float y', '\n']);
    fprintf(file_id, ['property float z', '\n']);
    fprintf(file_id, ['end_header', '\n']);
    
%     for i=1:height
%         for j=1:width
%             if d(i,j)>0
%                 fprintf(file_id, '%f %f %f\n', point_cloud(i,j,1), point_cloud(i,j,2), point_cloud(i,j,3));
%             end
%         end
%     end
    
    for n=1:N
        fprintf(file_id, '%f %f %f\n', point_cloud(n,1), point_cloud(n,2),point_cloud(n,3));
    end
    
    fclose('all');
end