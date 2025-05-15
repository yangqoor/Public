function kernels = generateKernels(oris, magnitudes)
len = size(oris, 2);
for k = 1 : len
   ori = oris(k);
   mag = magnitudes(k);
   
   kernels{k} = fspecial('motion',mag,ori) ;
end