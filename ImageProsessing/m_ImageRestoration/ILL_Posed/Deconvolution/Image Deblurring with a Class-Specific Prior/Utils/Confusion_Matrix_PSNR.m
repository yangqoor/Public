
pathte = {'Bottles', 'Car' , 'Cat' , 'CMU' , 'Human' ,'Yale' };
pathtr = {'Bottles', 'Car' , 'Cat' , 'CMU' , 'Human' ,'Yale' };
ext = {'*.jpg','*.jpg', '*.jpg', '*.png', '*.pnm', '*.pgm'};

for i=1:6
    pathDirTr=['I:\Confusion_matrix_data\test\' char(pathtr(i)) '\'];
    DirTr = dir([pathDirTr char(ext(i))]);
    for j=1:6
        
        fprintf('test == %d, train == %d\n\n', i,j);
        pathDirTe = ['I:\confusion_results\' char(pathtr(i)) '_' char(pathte(j)) '\'];
        DirTe = dir([pathDirTe '*.png']);
        ij=0;
        PSNR_Ave = 0;
        for di=1:length(DirTr)
            fprintf('image  = %d\n', di);
            g =  (im2double(imread([pathDirTr DirTr(di).name])));
            ii=1;
            for dj = ij+1:ij+8
                
                im =im2double(imread([pathDirTe DirTe(dj).name]));
                PSNR_INITIAL_ESTIMATE = 10*log10(1/mean((im(:)-g(:)).^2));
                err = double(g) - double(im);
             
                PSNR(ii) = PSNR_INITIAL_ESTIMATE;
                
                ii=ii+1;
                clear err;
            end
            ij=di*8;
            PSNR_Ave= (PSNR_Ave + mean(PSNR(:)))/2;
         
        end
        Conf_Matrix_PSNR(i,j) = PSNR_Ave;
        PSNR_Ave = 0;
    end
end


% clear all;
% close all;
% clc;
% 
% path='C:\Users\sanwar\Dropbox\ANU_PhD_Data\Denoising\Codes\Our_implementation\C-BM3D-withoutExemplar\color-final-Results\';
% ext='*.png';
% Dir = dir([path ext]);
% 
% fileNamePSNR = 'LPCA-color-psnr1.txt';
% fidpsnr = fopen(fileNamePSNR,'w');
% 
% pathg='C:\Users\sanwar\Dropbox\ANU_PhD_Data\Denoising\Denoising Results\Dataset\color\';
% ext='*.png';
% Dirg = dir([pathg ext]);
% i=0;
% for di=1:length(Dirg)
%     fprintf('image  = %d\n', di);
%     g =  (im2double(imread([pathg Dirg(di).name])));
%     ii=1;
%     for dj = i+1:i+8
%         
%         im =im2double(imread([path Dir(dj).name]));
%         PSNR_INITIAL_ESTIMATE = 10*log10(1/mean((im(:)-g(:)).^2));
%         err = double(g) - double(im);
%         % Calculate the PSNR value
%         %PSNR_INITIAL_ESTIMATE = 20*log10(256/std(err(:)));
%         PSNR(ii) = PSNR_INITIAL_ESTIMATE;
%         ii=ii+1;
%         clear err;
%     end
%     i=di*4;
%     dlmwrite(fileNamePSNR,  Dirg(di).name(1:end-4),'-append','newline','pc', 'delimiter','','precision',6);
%     dlmwrite(fileNamePSNR, PSNR,'-append','newline','pc','newline', 'pc' ,'delimiter','\t','precision',6);
% end
% fclose('all');
