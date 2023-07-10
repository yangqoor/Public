% test for heat diffusion on meshes

% load mesh
name = 'mushroom';
name = 'nefertiti';
name = 'fandisk';
name = 'lion-head';
name = 'bunny';
name = 'skull';
name = 'horse';
name = 'elephant-50kv';
[vertex,face] = read_off([name '.off']);

rep = 'results/mesh-smoothing/';
if not(exist(rep))
    mkdir(rep);
end

nvert = size(vertex,2);
nface = size(face,2);

laplacian_type = 'distance';
laplacian_type = 'conformal';
laplacian_type = 'combinatorial';

%% symmetric laplacian
if not(strcmp(laplacian_type,'conformal'))
    options.symmetrize = 1;
    options.normalize = 0;
    L0 = compute_mesh_laplacian(vertex,face,laplacian_type,options);
    G0 = compute_mesh_gradient(vertex,face,laplacian_type,options);
    disp(['Error (should be 0): ' num2str(norm(L0-G0'*G0, 'fro')) '.']);
    options.normalize = 1;
    L1 = compute_mesh_laplacian(vertex,face,laplacian_type,options);
    G1 = compute_mesh_gradient(vertex,face,laplacian_type,options);
    disp(['Error (should be 0): ' num2str(norm(L1-G1'*G1, 'fro')) '.']);
end

%% un-symmetric laplacian
options.symmetrize = 0;
options.normalize = 1;
L = compute_mesh_laplacian(vertex,face,laplacian_type,options);

%% heat diffusion flow
Tlist = [0 10 40 200];
options.dt = 0.3;
clf;
for i=1:length(Tlist)
    options.Tmax = Tlist(i);
    vertex1 = perform_mesh_heat_diffusion(vertex,face,L,options);
    % display
    subplot(1,length(Tlist),i);
    plot_mesh(vertex1,face);
    view(2); 
    if strcmp(name, 'horse')
         view(134,-61);
    elseif strcmp(name, 'skull')
        view(21.5,-12);
    end
    shading interp; camlight; axis tight;
end
saveas(gcf, [rep name '-smoothing-' laplacian_type '.png'], 'png');

%% quadratic regularization
clf;
for i=1:length(Tlist)
    At = speye(nvert) + Tlist(i)*L;
    vertex1 = (At\vertex');
    % display
    subplot(1,length(Tlist),i);
    plot_mesh(vertex1,face);
    view(2); 
    if strcmp(name, 'horse')
         view(134,-61);
    elseif strcmp(name, 'skull')
        view(21.5,-12);
    end
    shading interp; camlight; axis tight;
end
rep = 'results/mesh-smoothing/';
if not(exist(rep))
    mkdir(rep);
end
saveas(gcf, [rep name '-quadreg-' laplacian_type '.png'], 'png');