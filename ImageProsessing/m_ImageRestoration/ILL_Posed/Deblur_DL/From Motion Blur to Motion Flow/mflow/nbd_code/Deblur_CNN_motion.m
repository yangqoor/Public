function [mlhmag, mlhori, res] = Deblur_CNN_motion(im, net, kernels, kernel_labels, topNN, params)
% load blurry patches: multiple orientation for extending the learned model
% to more fine-grained orientation estimation
ointe = 6;
thetas = [0 : ointe : 30 - ointe];
nos = length(thetas);
nsc = 1;
ps = 34;
[gridX, gridY]=meshgrid(1 : ps, 1 : ps);
weightMap = ((exp(-((gridX - ps / 2) .^2 + (gridY - ps / 2) .^2) * 0.005)));

tic
% extending the kernel labels
kernel_labels_orig = kernel_labels;
num_labs = size(kernel_labels,2);
kernel_labels_ext = [];
kernelSet_ext = [];
ncls_orig = size(kernel_labels_orig, 2);
for s = 0 : 0
    sc = 2 ^ s;
    for k = 1 : nos
       oris = kernel_labels_orig(1, :) + thetas(k);
       magnitudes = kernel_labels_orig(2, :) / sc;
       labels = kernel_labels_orig(3, :) + ((s) * nos + k - 1) * ncls_orig;
       
       kernelSet_now = generateKernels(oris, magnitudes);
       kernelSet_ext = [kernelSet_ext, kernelSet_now];
       kernel_labels_ext = [kernel_labels_ext, [oris; magnitudes; labels]];
    end
end

% re-order the kernels:  
ids = find(kernel_labels_ext(2, :) > 1);
kernel_labels_ext_sele = kernel_labels_ext(1, ids) * 25 + kernel_labels_ext(1, ids);
[v, o] = sort(kernel_labels_ext_sele);
reorder = ids(o);
reorder = [1, reorder];
kernelSet_ext = kernelSet_ext(reorder);
kernel_labels_ext = kernel_labels_ext(:, reorder);

% generate the grids on original resolution
[r,c,d] = size(im);
Xs = [1 : r];
Ys = [1 : c];
[grids_Y, grids_X] = meshgrid(Xs, Ys);
grids_X = grids_X';
grids_Y = grids_Y';

% compute the maximum width of oriented patches
if(1)
    Wids = [];
    for k = 1 : nos    
        o = -thetas(k) / 180 * pi;
        Wids = [Wids; ps / 2 * [cos(o) - sin(o), sin(o) + cos(o)]];
    end
    wid_ex = ceil(max(Wids(:)));

    % extract multi-oriented patches 
    inte = round(ps / 6);
    r_grid = length([wid_ex + 1 : inte : r-wid_ex]);
    c_grid = length([wid_ex + 1 : inte : c - wid_ex]);
end
est_map = single(zeros( size(kernel_labels, 2) * nos * nsc, r,c));
est_map_co = double(zeros( size(kernel_labels, 2) * nos * nsc, r,c));

wei = reshape((repmat(weightMap(:)', [num_labs, 1])), [], ps, ps);
nps_batch = 128;

fprintf('Step 1: estimate per-pixel probability distribution of different motions \n');
if(1)
    co2 = 1;
    for s = 0 : 0
        %s
      sc = 2 ^ s;
        im_rs = imresize(im, sc);
        for k = 1 : nos 
            theta = thetas(k);
            
            fprintf('Step 1: estimate over image with ratation %f \n', theta);
       
            
            imo = imrotate(im_rs, theta, 'bilinear');
            o = -theta / 180 * pi;

            grids_X_tf = (grids_X - (c+1) / 2) * cos(o) - (grids_Y - (r+1) / 2) * sin(o);
            grids_Y_tf = (grids_X - (c+1) / 2) * sin(o) + (grids_Y - (r+1) / 2) * cos(o);
            sx = max(grids_X_tf(:)) - min(grids_X_tf(:));
            sy = max(grids_Y_tf(:)) - min(grids_Y_tf(:));

            grids_X_tf1 = round(grids_X_tf + sx/2) + 1;
            grids_Y_tf1 = round(grids_Y_tf + sy/2) + 1;
            
            % collect patches at the current scale
            if(1)
                co = 1;
                batches = [];
                pos_batches =[];
                bc = 1;
                patches = zeros(ps, ps, 3, nps_batch);
                pos = [];
                for p = wid_ex + 1 : inte : r-wid_ex
                     for q = wid_ex + 1 : inte : c - wid_ex
                        cq = round(grids_X_tf1(p, q) * sc);
                        cp = round(grids_Y_tf1(p, q) * sc);
                        if cp - ps / 2 > 0 && cp + ps/2 - 1 <= size(imo, 1) & cq - ps/2 > 0 & cq + ps / 2 - 1 <= size(imo, 2)
                            patches(:,:,:,co) = imo(cp - ps/2 : cp + ps/2 - 1, cq - ps/2 : cq + ps/2 - 1, :);
                            pos(:, co) = [p, q]';%[(p - wid_ex - 1), q - wid_ex - 1] / inte' + 1;

                            %if p == 225 && q == 315
                            %    tmp(:,:,:,co2) = patches(:,:,:,co);
                            %    co2 = co2 + 1;
                            %end
                            %if pos(1, co)  == 6 & pos(2, co)  == 6
                            %     p, q,
                            %end

                            if rem(co, nps_batch) == 0
                               batches{bc} = single(patches);
                               pos_batches{bc} = pos;
                               patches = zeros(ps, ps, 3, nps_batch);
                                 pos = [];
                               bc = bc + 1;
                               co = 0;
                            end
                            co = co + 1;
                        end
                     end     
                end

                % do inference at the current rotation
                if co <= nps_batch
                    batches{bc} = single(patches);
                    pos_batches{bc} = pos;
                end
                fs = [];
                for i = 1 : bc    
                    %fs{i} = caffe('forward', batches(i));
                    %i
                    if params.useGPU
                        res = vl_simplenn(net, gpuArray(batches{i}), [], [], ...                             
                                'conserveMemory', 1, ...                                    
                                'cudnn', 1) ; 
                    else
                        res = vl_simplenn(net, batches{i}, [], [], ...                             
                                'conserveMemory', 1, ...                                    
                                'cudnn', 1) ; 
                    end
                    fs{i} = gather(res(end).x);   
                end
            end
           

            % cumulate estimate confidence
             for i = 1 : bc
                 est = fs{i};
                 %est(find(isnan(est))) = 1./num_labs;
                 pos =  pos_batches{i};
                 for p = 1 : size(pos,2)
                    if i == 32 && p == 48
                        i;
                    end
                     
                    [v, id] = max(squeeze(est(:,:,:,p)));
                    est_map([1 : ncls_orig] + ncls_orig * (k - 1) ,pos(1, p) - ps/2 : pos(1, p) + ps/2 - 1, pos(2, p) - ps/2 :  pos(2, p) + ps/2 - 1) = est_map([1 : ncls_orig] + ncls_orig * (k - 1),pos(1, p) - ps/2 : pos(1, p) + ps/2 - 1, pos(2, p) - ps/2 :  pos(2, p) + ps/2 - 1) + repmat(squeeze(est(:,:,:,p)), [1, ps, ps]) .* wei;         
                    est_map_co([1 : ncls_orig] + ncls_orig * (k - 1) ,pos(1, p) - ps/2 : pos(1, p) + ps/2 - 1, pos(2, p) - ps/2 :  pos(2, p) + ps/2 - 1) = est_map_co([1 : ncls_orig] + ncls_orig * (k - 1) ,pos(1, p) - ps/2 : pos(1, p) + ps/2 - 1, pos(2, p) - ps/2 :  pos(2, p) + ps/2 - 1) + wei;
                    
                    
                    %try
                    %    est_map([1 : ncls_orig] + (s * nos + k - 1) * ncls_orig, pos(1, p), pos(2, p)) = est{1}(:,:,:,p);          %((s + 2) * nos + k - 1) * ncls_orig
                    %catch
                    %    %i
                    %end
                 end
             end
             
            % if length(find(isnan(est_map)) > 0)
            %        1;
            %        end
        end
    end
else
    [PATH,NAME,EXT]  = fileparts(fname);
    savingfolder = ['/home/jian/Projects/BlurMotionEsti_NN/saving/'];
    load([savingfolder, NAME, EXT, '.mat']);
    %est_map_co = est_map_co(reorder,:,:);
    %est_map = est_map(reorder,:,:);
end
valid_mask = squeeze(sum(est_map_co, 1) > 0);
y_s = min(find(valid_mask(round(r/2), :) > 0));
y_e = max(find(valid_mask(round(r/2), :) > 0));
x_s = min(find(valid_mask(:, round(c/2)) > 0));
x_e = max(find(valid_mask(:, round(c/2)) > 0));

est_map(find(isnan(est_map))) = 0;

fprintf('Step 2: Infer the motion blur kernel for each pixel using MRF (optimized by belief propagation)\n');

% 
est_map_co(find(est_map_co == 0)) = 1;
est_map = est_map ./ single(est_map_co);
est_map_co = est_map_co(reorder,:,:);
est_map = est_map(reorder,:,:);
est_map_ori = est_map;
if(0)
    tt = reshape(est_map_ori, 361, []);
    [v, idimg] = max(tt);
    mlhmag = reshape(kernel_labels_ext(2, idimg), [r, c]);
    mlhori = reshape(kernel_labels_ext(1, idimg), [r, c]);
    ids = find(mlhmag == 1);
    mlhori(ids) = 0;
    figure, imagesc(mlhmag);
    figure, imagesc(mlhori);
    
    immotion_noMRF = drawMotionField(double(im) / 255, mlhmag, mlhori);
    figure, imshow(uint8(immotion_noMRF * 255));
    
    [MSE_noMRF, PSNR_noMRF] = compError(mlhmag, mlhori, mlhmag_gt, mlhori_gt)
    
    % show the distribution mas of selected patches
    kernels_samples_mag = [1 : 2 : 25];
    kernels_samples_ori = [0 : 6 : 174];
    x0 = 100; y0 = 150;
    probs = est_map_ori(:, x0, y0);
    map = zeros(25, 180);
    len = size(est_map_ori, 1);
    for kk = 1 : 25
        for qq = 1 : 180
            dist = sum(abs(repmat([kk, qq]', 1,len) - kernel_labels_ext([2, 1], :)));
            [v, id] = min(dist);
            map(kk,qq) = probs(id); 
        end
    end
    
    figure, imagesc(map);      
    patch = im(x0 - 15 : x0 + 14, y0 - 15 : y0 + 14, :);
    
    % output patches
    save(['./Examples/Figs/probMap_', num2str(x0), '_', num2str(y0), '.mat'], 'map', 'patch', 'im');
    
end
% save the data related to DEEP FEATURES
%savefile = ['./saving/', fname, '.mat']
%save(savefile, 'est_map_co', 'est_map');

%% Do MRF optimization of the per-patch kernel estimation
if(1)
    topNN = 50;
    intep = (361 - 20) / 30;
    labelSet = round([1 : 20, 21 : intep : 361]);
    samplingRate = 3;
    est_map_full = est_map;
    est_map_valid = est_map(:, x_s : x_e, y_s : y_e);
    est_map = est_map_valid(:, 2: samplingRate : end, 2 : samplingRate : end);
    
    [d, r,c] = size(est_map);
    idx = find(sum(est_map, 1) == -size(est_map, 1));
    est_map2 = reshape(est_map, d, []);
    [vals,ords]=sort(est_map2, 1, 'descend');
    est_map_top = reshape(vals(labelSet, :), [topNN, r, c]); %1 : topNN
    ords_map_top = reshape(ords(labelSet, :), [topNN, r, c]); %1 : topNN
    %clear est_map est_map_co;

    fprintf('step 2: Constructin spatial compatibility...');
    T = kernel_labels_ext(1 : 2, :);
    X = [T(2,:) .* cos(T(1, :) / 180 * pi); T(2,:) .* sin(T(1, :) / 180 * pi)];
    lambda = 100 * diag([1, 1]); X = lambda * X;
    n1sq = sum(X.^2,1);
    n1 = size(X,2);
    D = ((ones(n1,1)*n1sq)' + ones(n1,1)*n1sq -2*X'*X);
    idxSet = find(D > 0); 
    %D(idxSet) = 10;

    % compute CM_h
    CM_h = single(zeros([topNN, topNN, r, c-1]));
    for i=1:r
        for j=1:c - 1
            foo1 = ords_map_top(:, i, j); %  reshape(candidates(i,j).patchesFull',[patchDim,patchDim,NN]);
            foo2 = ords_map_top(:, i, j + 1);%reshape(candidates(i,j+1).patchesFull',[patchDim,patchDim,NN]);
            %[X, Y]=meshgrid(foo1, foo2);
            %X = X';Y=Y';
            D1 = (D(foo1, :));
            CM_h(:,:,i,j) = D1(:, foo2);%reshape(sum(reshape((foo1-foo2).^2,[patchDim*overlapSize,NN^2]),1),[NN,NN]);
        end
    end

    % compute CM_v
    CM_v = single(zeros([topNN, topNN, r-1, c]));
    for i=1:r-1
        for j=1:c
            foo1 = ords_map_top(:, i, j); %  reshape(candidates(i,j).patchesFull',[patchDim,patchDim,NN]);
            foo2 = ords_map_top(:, i + 1, j);%reshape(candidates(i,j+1).patchesFull',[patchDim,patchDim,NN]);

            D1 = (D(foo1, :));
            CM_v(:,:,i,j) =  D1(:, foo2); %reshape(sum(reshape((foo1-foo2).^2,[patchDim*overlapSize,NN^2]),1),[NN,NN]);
        end
    end
    fprintf('done!\n');

    fprintf('Step 2: start BP: \n')
    alpha = 0.5; nIterations = 15;
    [IDX,En]=immaxproduct(-est_map_top,CM_h, CM_v,nIterations,alpha);
    idimg = zeros(r,c);
    for i=1:r
        for j=1:c
           idimg(i,j) = ords_map_top((IDX(i, j)), i, j);      
        end
    end
    mlhmag = reshape(kernel_labels_ext(2, idimg), size(idimg));
    mlhori = reshape(kernel_labels_ext(1, idimg), size(idimg));
    ids = find(mlhmag == 1);
    mlhori(ids) = 0;
    %figure, imagesc(mlhmag);
    %figure, imagesc(mlhori);
else
    mlhmag=0;
    mlhori = 0;
    conf = 0;
end

%% interpolate the motion field (bilinear)
[imr, imc, d] = size(im);
mlhmag_full = zeros(imr, imc);
mlhori_full = zeros(imr, imc);
mlhmag_full(x_s : x_e, y_s : y_e) = imresize(mlhmag, [x_e - x_s + 1, y_e - y_s + 1], 'nearest');
mlhori_full(x_s : x_e, y_s : y_e)  = imresize(mlhori, [x_e - x_s + 1, y_e - y_s + 1], 'nearest');

%% jointly estimate the blur kernel and the sharp images
yout0 = im;
yin = im;
kernelsParm.kernels_samples_mag = [1 : 2 : 25];
kernelsParm.kernels_samples_ori = [0 : 6 : 174];
kernelsParm.kernels_prob = double(est_map_full);
kernelsParm.motionkernels = kernelSet_ext;
kernelsParm.motionkernelID = kernel_labels_ext;

%% set the initial estimated kernels
kernelInit.mlhmag = mlhmag_full;
kernelInit.mlhori = mlhori_full;


%[MSE_MRF, PSNR_MRF] = compError(mlhmag_full, mlhori_full, mlhmag_gt, mlhori_gt)


immotion = drawMotionField(double(yin), mlhmag_full, mlhori_full);
figure, imshow(uint8(immotion * 255));
%save(savefile, 'immotion', 'immotion_noMRF', 'immotion_gt' , 'kernelInit', 'im', 'MSE_MRF', 'PSNR_MRF', 'MSE_noMRF', 'PSNR_noMRF');

%% 

fprintf('Step 3: perform the non-uniform motion deconvolution using the estimated blur kernels \n');

%[yout] = fast_deconv_nonUniform_nonblind(double(yin)/255, double(yout0)/255, kernelsParm, params, kernelInit);
[res] = fast_deconv_nonUniform_gmmprior(double(yin)/255, double(yout0)/255, kernelsParm, params, kernelInit);
%[yout] = fast_deconv_nonUniform_directional(double(yin)/255, double(yout0)/255, kernelsParm, params, kernelInit);

%immotion = drawMotionField(double(yin), mlhmag_full, mlhori_full);
%figure, imshow(uint8(immotion * 255));
figure, imshow(uint8(res * 255));
