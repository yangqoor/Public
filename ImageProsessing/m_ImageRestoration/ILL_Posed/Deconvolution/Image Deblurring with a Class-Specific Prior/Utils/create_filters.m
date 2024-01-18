opts.h=320;
opts.w=240;

% bandPass cut-offs
 opts.lowf  = [0.01, 0.05, 0.1, 0.15, 0.2,  .25, .3, .35, .4 , .45] ;
 opts.highf = [0.05,  0.1, 0.15, 0.2, 0.25 , .3, .35, .4, .45, .5];

% opts.n  = [1, 5, 15, 20, 25, 30 , 35, 40, 45, 50, 55];  % n is the order of the filter, the higher n is the sharper
opts.n  = [ 60 ,55, 50, 45, 40, 35, 30 , 25, 20, 15, 10, 5, 1];
%  the transition is. (n must be an integer >= 1).

%%
count1 = size(opts.n,2);
count2 = size(opts.lowf,2);
for O = 1:count1
    for bands = 1:count2
        bp = bandpassfilter([opts.h opts.w], opts.lowf(bands), opts.highf(bands), opts.n(O));
        %bp(bp == 0) = eps; % assign a low value at zeros to avoid divide by zeros
        filters(O,bands).bp=bp;
    end
end
save('Bpfilters_130filters.mat', 'filters');