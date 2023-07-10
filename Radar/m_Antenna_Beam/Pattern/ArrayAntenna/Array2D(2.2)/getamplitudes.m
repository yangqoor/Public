function [ampxn,ampyn] = getamplitudes(Nx,ixdist,Ny,iydist)
% filename: getamplitudes.m  (bayliss fixed)
% Project: ARRAY2D
% Description: This program calculates the amplitude distribution.
% Author:  Prof. David C. Jenn 
% Date:   22 September 2000
% Place: NPS
 
%  Get parameters

   h_figs = get(0,'children');
	for fig = h_figs'
		if strcmp(get(fig,'Tag'),'Array2d');
         h_array2d = fig;
         figure(fig);
         break
		end
	end
   
   pedval1 = get(findobj(gcf,'Tag','PedVal1'),'Value');
    if pedval1==1, peddbx = 15; end
     if pedval1==2, peddbx = 20; end
      if pedval1==3, peddbx = 25; end
       if pedval1==4, peddbx = 30; end
        if pedval1==5, peddbx = 35; end
         if pedval1==6, peddbx = 40; end 
          if pedval1==7, peddbx = 45; end
           if pedval1==8, peddbx = 50; end
      
   expval1 = get(findobj(gcf,'Tag','ExpVal1'),'Value'); 
   nexpx = expval1;
     
   pedval2 = get(findobj(gcf,'Tag','PedVal2'),'Value');
   if pedval2==1, peddby = 15; end
    if pedval2==2, peddby = 20; end
     if pedval2==3, peddby = 25; end
      if pedval2==4, peddby = 30; end
       if pedval2==5, peddby = 35; end
        if pedval2==6, peddby = 40; end
         if pedval2==7, peddby = 45; end 
          if pedval2==8, peddby = 50; end
      
   expval2 = get(findobj(gcf,'Tag','ExpVal2'),'Value'); 
   nexpy = expval2;

% uniform array excitation coefficients (=1/nel)
if ixdist == 1 
	for i = 1:Nx
   	ampx(i) = 1/Nx;
   end
end

if iydist == 1 
	for i = 1:Ny
   	ampy(i) = 1/Ny;
   end
end

% subroutine compute taylor coefficients

if ixdist == 2      
   ampx(1:Nx) = tayl(Nx,peddbx,nexpx);
end

if iydist == 2      
   ampy(1:Ny) = tayl(Ny,peddby,nexpy);
end

% cosine-on-a-pedestal distribution

if ixdist == 3    
   ampx(1:Nx) = cosine(Nx,peddbx,nexpx);
end 

if iydist == 3   
   ampy(1:Ny) = cosine(Ny,peddby,nexpy);
end 

% bayliss distribution for difference beams -- NEL MUST BE EVEN

if ixdist == 4   
   ampx(1:Nx) = bayliss(Nx,peddbx,nexpx);
end

if iydist == 4   
   ampy(1:Ny) = bayliss(Ny,peddby,nexpy);
end


% subroutine compute triangular coefficients

if ixdist == 5   
	for i = 1:Nx
		n = (2*i - (Nx + 1))/2;
      ampx(i) = 1 - abs(2*n/Nx);
   end
end

if iydist == 5
	for i = 1:Ny
		n = (2*i -(Ny + 1))/2;
      ampy(i) = 1 - abs(2*n/Ny);
   end
end
      
% normalize all coefficients to the maximum value
amx 	= max(ampx);
ampxn = ampx/amx;
amy 	= max(ampy);
ampyn = ampy/amy;

