% test for farthest point sampling

n = 300;
rep = 'images/farthest_sampling/';
if exist(rep)~=7
    mkdir(rep);
end
rep_eps = [rep 'eps/'];
if exist(rep_eps)~=7
    mkdir(rep_eps);
end

name = 'bump';
name = 'map';
name = 'stephanodiscusniagarae';
name = 'cavern';
name = 'constant';
name = 'gaussian';
name = 'road2';
name = 'mountain';

[M,W] = load_potential_map(name, n);

save_images = 0;

% plot sampling location
i = 0;
landmark = [];
for nbr_landmarks = 50:50:300
    i = i+1;
    disp('Perform farthest point sampling');
    landmark = farthest_point_sampling( W, [], nbr_landmarks );
    if ~save_images
        subplot(2,3,min(i,6));
    end
    
    % compute the associated triangulation
    [D,Z,Q] = perform_fast_marching_2d(W, landmark);

    faces = compute_voronoi_triangulation(Q);

    % display
    hold on;
    imagesc(M'); axis image; axis off;
    plot(landmark(1,:), landmark(2,:), 'b.', 'MarkerSize', 20);
    plot_edges(compute_edges(faces), landmark, 'k');
    hold off;
    axis tight; axis image; axis off;
    colormap gray(256);
    
    if save_images
        num_str = num2str(nbr_landmarks);
        if nbr_landmarks<10
            num_str = ['0' num_str];
        end
        if nbr_landmarks<100
            num_str = ['0' num_str];
        end
        str = [name '_sampling_' ];
        saveas(gcf, [rep str '.png'], 'png');
        saveas(gcf, [rep_eps str '.eps'], 'eps');
    end
end