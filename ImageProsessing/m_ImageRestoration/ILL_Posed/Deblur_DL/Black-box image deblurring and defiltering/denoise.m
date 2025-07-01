function [Im2] = denoise(Im)
% Use cnn denoising (requires deep learning toolbox) 
net = denoisingNetwork('DnCNN');
if (size(Im,3) == 3)
   [ImR, ImG, ImB] = imsplit(Im);
   Im2R = denoiseImage(ImR, net);
   Im2G = denoiseImage(ImG, net);
   Im2B = denoiseImage(ImB, net);
   Im2 = cat(3, Im2R, Im2G, Im2B);
else
    Im2 = denoiseImage(Im, net);
end
end
