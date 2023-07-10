% test for triangulation parameterization
% (i.e. parameterization of an disk-shaped 3D model)
%
%   Copyright (c) 2005 Gabriel Peyre


filename = 'mannequin.off';
filename = 'nefertiti.off';
[vertex,face] = read_off(filename);
A = triangulation2adjacency(face);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute 1-ring

boundary_types = {'circle','square','triangle'};
nbound = length(boundary_types);
lap_types = {'combinatorial','conformal'};
nlap = length(lap_types);
options.method = 'parameterization';

clf;
kk = 0;
for l = lap_types
    k = 0;
    for b = boundary_types
        kk = kk+1;
        k = k+1;

        % parameters for the parameterization
        options.boundary = cell2mat(b);
        options.laplacian = cell2mat(l);

        k = k+1;
        str = sprintf('%s, %s', options.laplacian, options.boundary);
        disp(['Computing parameterization : ', str, '.']);
        xy = compute_parameterization(vertex,face,options);

        subplot(nlap,nbound,kk);
        plot_graph(A,xy,'k.-');
        title(str);
    end
end
