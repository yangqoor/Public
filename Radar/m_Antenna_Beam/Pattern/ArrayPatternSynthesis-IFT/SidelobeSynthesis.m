function SidelobeSynthesis

% SIDELOBESYNTHESIS computes for a linear array antenna with uniform 
% element spacing an amplitude taper that matches the user defined sidelobe 
% level (SLL) requirement. 

% The program applies the iterative Fourier technique (IFT)to compute the 
% array factor (AF) satisfying the SLL requirements.
% The synthesized AF is displayed as a function of the direction cosine
% u = sin(theta) where theta is the angular coordinate measured between
% the far-field direction and the array normal.

% The IFT synthesis takes standard one element constraint into
% consideration and that is the ratio of the maximum and mimimum 
% amplitude A of the array illumination defined as Amax/Amin. 
% Another element constraint (optional) is the the occurence of defective
% (= non-radiating) elements. The implemented IFT approach has the ability 
% to perform pattern recovery that restores the original low sidelobe 
% performance as close as possible in case of element failures.
% Pattern recovery can be activated by uncommenting Line 154 followed by a 
% new run of the program. 

% More information about the IFT method can be found in the following two 
% papers:

% W.P.M.N. Keizer, "Fast low sidelobe synthesis for large planar 
% array antennas antennas utilizing successive fast Fourier transforms of 
% the array factor," IEEE Trans. Antennas Propagat., vol. 55, no. 3, 
% pp. 715-722, March 2007.

% W.P.M.N. Keizer, "Element failure correction for a large monopulse phased
% array antenna with active amplitude weighting," IEEE Trans. Antennas 
% Propagat., vol. 55, no. 8, pp. 2211-2218, August 2007.

% Language:  Matlab R2008b
% Author:    Will P.M.N. Keizer, willkeizer@ieee.org
% Date:      10/08/2008
% 
% Copyright 2008 ArraySoft, Inc.

% This routine may be used by anyone for any purpose.  I simply ask
% that acknowledgement be made to me.


% ------------------ Input Parameters -------------------------------

noEl        = 100;         % # of array elements 
dx          = 0.5;         % Normalized element spacing
specSLL     = -40;         % Required SLL, (dB)
ratioIllum  = 19;          % Ratio maximum/minimum value Illumination, (dB) 

noIter      = 1000;        % Maximum # of iterations 
noFF        = 4096;        % # of far-field (FF) directions

% ------------------ End Input Parameters --------------------------------- 

u           = (-noFF/2:noFF/2-1)/dx/noFF;  % u-coordinates FF

patternType = {'Sum Pattern'};

IllumEven   = ones(1,noEl);                % Uniform illumination
minIllum    = 10^(-ratioIllum/20);         % Minimum value illumination

monResults(1:noIter,1:5) = 0;              % Container for storing 
                                           % intermediate synthesis results 
maxAF   = 1;

for imk = 1:1
         
   IllumInit = IllumEven; % Initial illumination sum pattern at start
         
   IllumS    = IllumInit;

   Phase     = exp(1i*(angle(IllumInit)));   
           
   tic
         
   [Illum, AFabs] = synthesisFFT;
   
   toc
      
   plotGraphics(Illum./max(abs(Illum)))
   
   monResults(1:iCount,1:end) = 0; % Restore initial state
     
end

   % ------  Low sidelobe synthesis using iterative FTT technique --------- 

   function [Illum, AFabs]= synthesisFFT
   
      for ikk = 1:noIter
   
         Illum = IllumS;  
          
         AF    = ifftshift(ifft(Illum,noFF)); % AF computed by FFT
         
         AFabs = abs(AF);         % Absolute value AF 
                  
         maxAF = max(AFabs);
             
         AFabs = AFabs/maxAF;     % Normalize |AF|   
     
         AF    = AF/maxAF;        % Normalize AF (complex)   
      
         % ------- Find all FF nulls --------------------------------------  
   
         minVal = sign(diff([inf AFabs inf]));
    
         indMin = find(diff(minVal+(minVal==0))==2); % Indices FF nulls 
     
         % -------- Find all FF peaks -------------------------------------  
     
         indPeaks   = find(diff(minVal)<0);          % Indices FF peaks
  
         [peakLevel indP] = sort(AFabs(indPeaks),'descend');
          
         indMax     = indPeaks(indP(1));
                                   
         indNullL   = find(indMin<indMax,1,'last'); % Index first null mainbeam
         
         % Find indices all SLL directections
                              
         indSLL     = [1:(indMin(indNullL)-1),(indMin(indNullL+1)+1):noFF]; 
        
         indSynth   = AFabs(indSLL)>10^(specSLL/20); 
                                          
         max_SLL    = 20*log10(peakLevel(2));    % Maximum value SLL   
            
         noSLLdir   = sum(indSynth); % # of SLL directions >SLL requirement
          
         monResults(ikk,1:4) = [ikk noSLLdir max_SLL ...
                             (indMin(indNullL+1)-indMin(indNullL))]; 
          
         if noSLLdir==0, return, end
         
         % if max_SLL< specSLL+20, return, end 
                  
         % ----- Adapt AF to SLL constraints ------------------------------
     
         AF(indSLL(indSynth)) = 10^((specSLL-40)/20); 
              
         IllumS = fft(ifftshift(AF));   % Illumination derived from AF 
      
         % ---- Adapt Illumination to aperture domain constraints ---------
   
         IllumS = IllumS(1:noEl);   % Truncate # elements illumation 

         IllumS = IllumS/max(abs(IllumS));  
         
         IllumS(abs(IllumS)<minIllum) = minIllum; % Dynamic range constraint
         
        % IllumS([8,20,23,24,25,26,27,29]) = 0; % Defective elements
                        
         IllumS = IllumS.*Phase;
                        
      end
    
   end

   function plotGraphics(Illum)  
     
   AF     = 20*log10(AFabs);
     
   maxAFunif = max(abs(ifftshift(ifft(IllumEven,noFF)))); 
   
   taperEff  = ((maxAF/maxAFunif)^2)*sum(abs(IllumEven).^2)/...
                                                        sum(abs(Illum).^2);
   fonts = 11;

   iCount = max(monResults(:,1));
   
   hFig = figure('Tag','Array');
      
   aX1 = axes('position',[.07 .58 .35 .35],'Units','Normalized'); 
   plot(u,AF,'Parent',aX1);
   set(aX1,'Ylim',[specSLL-20 0])
   xlabel('u','Fontsize',fonts+1);
   ylabel('Normalized Far Field (dB)','Fontsize',fonts+1)
   title([patternType{1},' ', num2str(noEl), ...
                              '-Element Linear Array'],'Fontsize',fonts+1) 
   
   txtStr{1} = {['element spacing = ',sprintf('%3.1f',dx), ' \lambda'];...
                 'isotropic element pattern';...
                ['taper efficiency = ',sprintf('%5.3f',taperEff)];... 
                ['max SLL = ',sprintf('%6.2f',monResults(iCount,3)),' dB'];...
                ['SLL Req. = ',sprintf('%6.2f',specSLL),' dB']};                                                         
               
   text(0.66,0.84,txtStr{1},'Parent',aX1,'Units','Normalized',...
                                                       'Fontsize',fonts-1)
   text(0.5-0.018,-0.16,'(a)','Fontsize',fonts-1,'FontWeight','bold',...
                                                      'Units','Normalized')
                                                     
   if noIter>1                                               
      aX2 = axes('position',[.07 .1 .35 .35],'Units','Normalized');  
      plot(20*log10(abs(Illum)),'Parent',aX2);
      set(aX2,'XLim',[1 noEl])
      ylabel('Magnitude (dB)','Fontsize',fonts+1)
      xlabel('Element Index','Fontsize',fonts+1)
      title(['Illumination ',patternType{1}, ' ',num2str(noEl),...
                              '-Element Linear Array'],'Fontsize',fonts+1)
      text(0.5-0.018,-0.16,'(c)','Fontsize',fonts-1,'FontWeight','bold',...
                                                      'Units','Normalized')
                          
                          
      aX3 = axes('position',[.53 .58 .35 .35],'Units','Normalized'); 
      plot(monResults(1:iCount,1),monResults(1:iCount,3),'Parent',aX3);
      ylabel('Max. SLL (dB)','Fontsize',fonts+1)
      xlabel('# of Iterations','Fontsize',fonts+1)
      set(aX3,'XLim',[1 iCount])
      title('Progress max SLL during Synthesis','Fontsize',fonts+1)
      text(0.66,0.90,['# of iterations = ',sprintf('%5.0f',iCount)], ...
                     'Parent',aX3,'Units','Normalized','Fontsize',fonts-1); 
   
      text(0.5-0.018,-0.16,'(b)','Fontsize',fonts-1,'FontWeight','bold',...
                                                      'Units','Normalized')
                 
      axes('position',[.53 .1 .35 .35],'Parent',hFig);
      Hndl = plotyy(monResults(1:iCount,1),monResults(1:iCount,2), ...
                   monResults(1:iCount,1),monResults(1:iCount,4));
      ylabel(Hndl(1),'# of SL Directions violating SL Requirements', ...
                                                        'Fontsize',fonts+1)
      xlabel(Hndl(1),'# of Iterations','Fontsize',fonts+1)
      set(Hndl(1),'XLim',[1 iCount])
      ylabel(Hndl(2),'# of FF Directions contained in Mainlobe', ...
                                                        'Fontsize',fonts+1)
                                                    
      text(0.5-0.018,-0.16,'(d)','Fontsize',fonts-1,'FontWeight','bold',...
                                                      'Units','Normalized')                                                 
      set(Hndl(2),'XLim',[1 iCount])
   end
   end
end
