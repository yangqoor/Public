% test for farthest point sampling on 3D meshes

n = 300;
repimg = 'results/farthest-sampling-mesh/';
if exist(repimg)~=7
    mkdir(repimg);
end


path(path, '../toolbox_graph/off');
rep = '../toolbox_graph/off/';
name = 'nefertiti.off';
name = 'beetle.off';
name = 'fandisk.off';
name = 'david50kf.off';
[vertex,faces] = read_mesh([rep name]);

if size(vertex,1)>size(vertex,2)
    vertex = vertex';
end
if size(faces,1)>size(faces,2)
    faces = faces';
end


save_images = 1;

% plot sampling location
i = 0;
landmark = [];
for nbr_landmarks = 100:50:500
    i = i+1;
    
    disp('Perform farthest point sampling.');
    landmark = farthest_point_sampling_mesh( vertex,faces, [], nbr_landmarks );

    if ~save_images
        subplot(2,3,min(i,6));
    end
    
    % compute the associated triangulation
    [D,Z,Q] = perform_fast_marching_mesh(vertex, faces, landmark);
    [vertex_voronoi,faces_voronoi] = compute_voronoi_triangulation_mesh(Q,vertex,faces);

    
    % display
    col = D; col(col==Inf) = 0;
    options.face_vertex_color = col;
    clf;
    hold on;
    plot_mesh(vertex, faces, options);
    h = plot3(vertex_voronoi(1,:),vertex_voronoi(2,:),vertex_voronoi(3,:), 'k.');
    set(h, 'MarkerSize', 25);
    hold off;
    colormap jet(256);
    shading interp;
    lighting gouraud
    view(185,-70);
    camlight;
    
    if save_images
        str = [name '_sampling_' num2string_fixeddigit(nbr_landmarks,3)];
        saveas(gcf, [repimg str '.png'], 'png');
    end
    
       
    clf;
    plot_mesh(vertex_voronoi,faces_voronoi)
    shading faceted;
    lighting flat;
    view(185,-70);
    camlight;
    
    if save_images
        str = [name '_remeshing_' num2string_fixeddigit(nbr_landmarks,3)];
        saveas(gcf, [repimg str '.png'], 'png');
    end
end