load demo_inp

figure, imshow([I])
title('input')
drawnow


figure, imshow(imresize(filt/max(filt(:)),20))
title('kernel')
drawnow


lucy_dI=deconvlucy(I,filt,20);
figure, imshow([lucy_dI])
title('lucy deconv')
drawnow 


[dI1]=deconvL2(I,filt,0.002,80);
[dI2]=deconvL2(I,filt,0.01,80);

figure, imshow([dI1,dI2])
title('L2 deconv (varying smoothness weight)')
drawnow


[fdI1]=deconvL2_frequency(I,filt,0.002);
[fdI2]=deconvL2_frequency(I,filt,0.01);

figure, imshow([fdI1,fdI2])
title('L2 deconv in frequency domain (varying smoothness weight)')
drawnow


[sdI1]=deconvSps(I,filt,0.001,200);
[sdI2]=deconvSps(I,filt,0.004,200);

figure, imshow([sdI1,sdI2])
title('sparse deconv (varying smoothness weight)')
drawnow

%Note: if you try this code with your own filter, 
%and you arent happy with the result, you might 
%need to flip your filter:
%filt=fliplr(flipud(filt)).
