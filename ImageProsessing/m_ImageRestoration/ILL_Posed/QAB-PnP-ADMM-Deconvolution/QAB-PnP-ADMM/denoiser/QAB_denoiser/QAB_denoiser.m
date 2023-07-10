% Sample code of the paper:
% 
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% “Quantum mechanics-based signal and image representation: Application
% to denoising,” IEEE Open Journal of Signal Processing, vol. 2, pp. 190–206, 2021.
% 
% MATLAB code prepard by Sayantan Dutta
% E-mail: sayantan.dutta@irit.fr and sayantan.dutta110@gmail.com
% 
% This script shows an example of calling our denoising algorithm 
% for image using Quantum adaptative basis (QAB)
%---------------------------------------------------------------------------------------


function [I_result] = QAB_denoiser(I,m,n,psi,alp,significant_E)

% Data
Ms = 20;    % number of iteration in reconstruction
saut = 12;  % Moving the threshold (must be at least 1, this is the slowest case)

% Threshold parameter
Vs = linspace(7,12,Ms); % for reconstruction
Vs = 2 .^Vs;      
        
  % These variables store the values associated with the maximums.
    V_ms = 0.01;
    SNR_max = 0; % maximum SNR for adaptive transformation 
    seuil_ms = 1;
 
    pI = sum(sum(I .^2)) / (m*n);

% new images
Jns = zeros(n,n);

% Reconstruction of images
 for k = 9 %1:Ms % Loop on the slope parameter
    
    v = Vs(k);
        
    max_atteint = 0;
    RSB_s = 0;
    l = 1;
        
     while (l <= (m*n)) * (max_atteint < 20) %Loop on the threshold position, stops when one reaches a local maximum (global?) For the threshold parameter
      
        % threshold
         x = (1:(m*n)) - l + 2;
         taux = heavi(x,v);
         
        % Reconstruction
        n_I = zeros(n,n);
        for t = 1: (m*n)/2 % significant_E
            n_I = n_I + psi(:,:,t) * taux(t) * alp(t);
        end
        
        % Calculation of SNR
          n_B = n_I - I;
          pnB = sum(sum(n_B .^2)) / (m*n);
          RSB_n = 10 * log10(pI / pnB);
          
          % Test if the SNR increases
          max_atteint = (max_atteint + 1) * (RSB_s > RSB_n);
          RSB_s = RSB_s * (RSB_s > RSB_n) + RSB_n * (RSB_s <= RSB_n);
          
          V_ms = V_ms * (SNR_max >= RSB_n) + v * (SNR_max < RSB_n);
          seuil_ms = seuil_ms * (SNR_max >= RSB_n) + l * (SNR_max < RSB_n);
          Jns = Jns * (SNR_max >= RSB_n) + n_I * (SNR_max < RSB_n);
          SNR_max = SNR_max * (SNR_max >= RSB_n) + RSB_n * (SNR_max < RSB_n);
                
          l = l + saut;
      end
  end

I_result = Jns;  % final denoised image

end
 