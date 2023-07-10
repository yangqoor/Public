function arpat(action)
% filename: arpat.m   (v2.1: qloss and dif. beam fixed in arpat.m)  
%                     (v2.2: dif. beam fixed in getamplitudes.m) 
% HAS EXPORT OF DATA TO FILE PLOTDAT
% pedval lists corrected 9/03
% Project: 2-D Array Antenna Pattern
% Description: This program implements the functionalities of the 
%			2-D Array Antenna Patter GUI, computes the Array Factor
% 			and performs the calculations requested by the user.
% Author:  Prof. David C. Jenn and Elmo E. Garrido Jr.
% Date:   16 September 2000
% Place: NPS


switch(action)
   
   case 'PStart'
      h_pstart = findobj(gcf,'Tag','PStart'); 
      pstart_str = get(h_pstart,'String'); 
      pstart = getPStart(pstart_str); 
      set(h_pstart,'String',num2str(pstart));

   case 'PStop'
      h_pstop = findobj(gcf,'Tag','PStop'); 
      pstop_str = get(h_pstop,'String'); 
      pstop = getPStop(pstop_str); 
      set(h_pstop,'String',num2str(pstop));

   case 'Delp'
      h_delp = findobj(gcf,'Tag','Delp');
      delp_str = get(h_delp,'String'); 
      delp = getDelp(delp_str);
      set(h_delp,'String',num2str(delp));     

   case 'TStart'
      h_tstart = findobj(gcf,'Tag','TStart'); 
      tstart_str = get(h_tstart,'String'); 
      tstart = getTStart(tstart_str); 
      set(h_tstart,'String',num2str(tstart));
      
   case 'TStop'
      h_tstop = findobj(gcf,'Tag','TStop'); 
      tstop_str = get(h_tstop,'String'); 
      tstop = getTStop(tstop_str); 
      set(h_tstop,'String',num2str(tstop));

   case 'Delt'
      h_delt = findobj(gcf,'Tag','Delt');
      delt_str = get(h_delt,'String'); 
      delt = getDelt(delt_str);
      set(h_delt,'String',num2str(delt));     

   case 'Nx'
      h_Nx = findobj(gcf,'Tag','Nx'); 
      nx_str = get(h_Nx,'String'); 
      Nx = getNEL(nx_str); 
      set(h_Nx,'String',num2str(Nx));
      if Nx == 1
         dx = 0;
         set(findobj(gcf,'Tag','Dx'),'String',num2str(dx));
         warndlg('For a single element, array spacing is set to zero.',...
            	  '  Array Spacing','help');
      elseif Nx > 1   
      	dx = str2num(get(findobj(gcf,'Tag','Dx'),'String'));
         if dx == 0
            set(findobj(gcf,'Tag','Dx'),'String',num2str(1));
            warndlg('For the number of elements, array spacing cannot be zero.',...
               '  Array Spacing','help');
         end         
      end
              
   case 'Ny'
      h_Ny = findobj(gcf,'Tag','Ny'); 
      ny_str = get(h_Ny,'String'); 
      Ny = getNEL(ny_str); 
      set(h_Ny,'String',num2str(Ny));
      if Ny == 1
         dy = 0;
         set(findobj(gcf,'Tag','Dy'),'String',num2str(dy));
         warndlg('For a single element, array spacing is set zero.',...
            	  '  Array Spacing','help');
      elseif Ny > 1   
      	dy = str2num(get(findobj(gcf,'Tag','Dy'),'String'));
         if dy == 0
            set(findobj(gcf,'Tag','Dy'),'String',num2str(1));
            warndlg('For the number of elements, array spacing cannot be zero.',...
               '  Array Spacing','help');
         end         
      end

   case 'Dx'
      h_Dx = findobj(gcf,'Tag','Dx'); 
      dx_str = get(h_Dx,'String'); 
      dx = getSpacing(dx_str); 
      set(h_Dx,'String',num2str(dx));
      if dx == 0
         Nx = 1;
         set(findobj(gcf,'Tag','Nx'),'String',num2str(Nx));
         warndlg('Number of array elements set to 1.',' Number of Array Elements','help');
      end
      
      Nx = str2num(get(findobj(gcf,'Tag','Nx'),'String')); 
      if dx > 0
         if Nx == 1
            errordlg('For the spacing indicated, number of elements must be at least 2.',...
            	   'Number of Elements','error');
            dx = 0;
            set(h_Dx,'String',num2str(dx));
         end
      end
           
   case 'Dy'
      h_Dy = findobj(gcf,'Tag','Dy'); 
      dy_str = get(h_Dy,'String'); 
      dy = getSpacing(dy_str); 
      set(h_Dy,'String',num2str(dy));
      if dy == 0
         Ny = 1;
         set(findobj(gcf,'Tag','Ny'),'String',num2str(Ny));
         warndlg('Number of array elements set to 1.',...
            	  ' Number of Array Elements','warn');
      end
      
      Ny = str2num(get(findobj(gcf,'Tag','Ny'),'String')); 
      if dy > 0
         if Ny == 1
            errordlg('For the spacing indicated, number of elements must be at least 2.',...
            	   'Number of Elements','error');
            dy = 0;
            set(h_Dy,'String',num2str(dy));
         end
      end
      
	case 'XDist'
      h_XDist = findobj(gcf,'Tag','XDist'); 
      xval = get(h_XDist,'Value'); 
      ixdist = xval;
      if (ixdist == 2 | ixdist == 4)
      	Nx = str2num(get(findobj(gcf,'Tag','Nx'),'String'));
         if rem(Nx,2) ~= 0
            set(findobj(gcf,'Tag','XDist'),'Value',1); 
            errordlg('Number of array elements in X-plane must be even. Change number of elements or select another distribution.', ...
               ' Number of Array Elements','error');
         end
      end
      
      if (ixdist == 2) |(ixdist == 3) |(ixdist == 4) 
         set(findobj(gcf,'Tag','PedVal1'),'Enable','on');
         set(findobj(gcf,'Tag','ExpVal1'),'Enable','on');
      else
         set(findobj(gcf,'Tag','PedVal1'),'Enable','off');
         set(findobj(gcf,'Tag','ExpVal1'),'Enable','off');
      end
                 
   case 'YDist'
      h_YDist = findobj(gcf,'Tag','YDist'); 
      yval = get(h_YDist,'Value'); 
      iydist = yval;
      if iydist == 2 | iydist == 4
      	Ny = str2num(get(findobj(gcf,'Tag','Ny'),'String'));
         if rem(Ny,2) ~= 0
            set(findobj(gcf,'Tag','YDist'),'Value',1); 
            errordlg('Number of array elements in Y-plane must be even. Change number of elements or select another distribution.', ...
               ' Number of Array Elements','error');
         end
      end
      
      if (iydist == 2) |(iydist == 3) |(iydist == 4) 
         set(findobj(gcf,'Tag','PedVal2'),'Enable','on');
         set(findobj(gcf,'Tag','ExpVal2'),'Enable','on');
      else
         set(findobj(gcf,'Tag','PedVal2'),'Enable','off');
         set(findobj(gcf,'Tag','ExpVal2'),'Enable','off');
      end
      
   case 'PedVal1'
      h_PedVal1 = findobj(gcf,'Tag','PedVal1'); 
      pedval1 = get(h_PedVal1,'Value'); 
      switch pedval1  
       case 1
         	peddb = 15;
	    case 2
   	      peddb = 20;
      	case 3
         	peddb = 25;
	    case 4
   	      peddb = 30;
      	case 5
         	peddb = 35;
	    case 6
   	      peddb = 40;
      	case 7
         	peddb = 45;
        case 8
            peddb = 50;
	   end          

   case 'ExpVal1'
      h_ExpVal1 = findobj(gcf,'Tag','ExpVal1'); 
      expval1 = get(h_ExpVal1,'Value'); 
      nexpx = expval1;
          
   case 'PedVal2'      
      h_PedVal2 = findobj(gcf,'Tag','PedVal2'); 
      pedval2 = get(h_PedVal2,'Value'); 
      switch pedval2        
       case 1
         	peddb = 15;
	    case 2
   	      peddb = 20;
      	case 3
         	peddb = 25;
	    case 4
   	      peddb = 30;
      	case 5
         	peddb = 35;
	    case 6
   	      peddb = 40;
      	case 7
         	peddb = 45;
        case 8
            peddb = 50;
	   end          

	case 'ExpVal2'
      h_ExpVal2 = findobj(gcf,'Tag','ExpVal2'); 
      expval2 = get(h_ExpVal2,'Value'); 
      nexpy = expval2;
                
   case 'ThScan'   
      h_ThScan = findobj(gcf,'Tag','ThScan'); 
      thscan_str = get(h_ThScan,'String'); 
      ths = getScanAngle(thscan_str); 
      set(h_ThScan,'String',num2str(ths));

   case 'PhScan'   
      h_PhScan = findobj(gcf,'Tag','PhScan'); 
      phscan_str = get(h_PhScan,'String'); 
      phs = getScanAngle(phscan_str); 
      set(h_PhScan,'String',num2str(phs));
      
   case 'Rectangular'
      if get(findobj(gcf,'Tag','Rectangular'),'Value') == 1
         set(findobj(gcf,'Tag','Polar'),'Value',0);
      elseif get(findobj(gcf,'Tag','Rectangular'),'Value') == 0
         set(findobj(gcf,'Tag','Polar'),'Value',1);        
      end
      
   case 'Polar'
      if get(findobj(gcf,'Tag','Polar'),'Value') == 1
         set(findobj(gcf,'Tag','Rectangular'),'Value',0);
      elseif get(findobj(gcf,'Tag','Polar'),'Value') == 0
         set(findobj(gcf,'Tag','Rectangular'),'Value',1);   
      end
      
% roundoff values      

    case 'IPh'      
        iph = get(findobj(gcf,'Tag','IPh'),'Value');
        
    case 'Bits'
        bitz = get(findobj(gcf,'Tag','Bits'),'Value');
        nbits=bitz-1;
        
   case 'Calculate'     
       
      Nx = str2num(get(findobj(gcf,'Tag','Nx'),'String')); 
      Ny = str2num(get(findobj(gcf,'Tag','Ny'),'String')); 
      dx = str2num(get(findobj(gcf,'Tag','Dx'),'String')); 
      dy = str2num(get(findobj(gcf,'Tag','Dy'),'String')); 
      ixdist = get(findobj(gcf,'Tag','XDist'),'Value');
      iydist = get(findobj(gcf,'Tag','YDist'),'Value');
      
      if Nx > 1
         if dx == 0
            errordlg('Please set array spacing in X-axis or change the number of elements.',...
               		'Array Spacing','error');
         end
      elseif dx > 0
         if Nx == 1
            errordlg('Please change array spacing in X-axis or the number of elements.',...
               		'Array Spacing','error');
         end          
      end      
      
      if Ny > 1
         if dy == 0
            errordlg('Please set array spacing in Y-axis or change the number of elements.',...
               		'Array Spacing','error');
         end
      elseif dy > 0
         if Ny == 1
            errordlg('Please change array spacing in Y-axis or the number of elements.',...
               		'Array Spacing','error');
         end          
      end      
       
   % get parameters 
      bk = 2*pi;
      rad = pi/180;
      pstart = str2num(get(findobj(gcf,'Tag','PStart'),'String')); 
      pstop  = str2num(get(findobj(gcf,'Tag','PStop'),'String')); 
      delp   = str2num(get(findobj(gcf,'Tag','Delp'),'String')); 
      tstart = str2num(get(findobj(gcf,'Tag','TStart'),'String')); 
      tstop  = str2num(get(findobj(gcf,'Tag','TStop'),'String')); 
      delt   = str2num(get(findobj(gcf,'Tag','Delt'),'String'));      
      it	 = floor((tstop-tstart)/delt)+ 1;
   	  ip 	 = floor((pstop-pstart)/delp)+ 1;
      Nx = str2num(get(findobj(gcf,'Tag','Nx'),'String')); 
      Ny = str2num(get(findobj(gcf,'Tag','Ny'),'String'));       
      dx = str2num(get(findobj(gcf,'Tag','Dx'),'String')); 
      dy = str2num(get(findobj(gcf,'Tag','Dy'),'String')); 
      ixdist = get(findobj(gcf,'Tag','XDist'),'Value');
      iydist = get(findobj(gcf,'Tag','YDist'),'Value');     
      iph = get(findobj(gcf,'Tag','IPh'),'Value');
      nbits = get(findobj(gcf,'Tag','Bits'),'Value')-1;
      ths = str2num(get(findobj(gcf,'Tag','ThScan'),'String')); 
      phs = str2num(get(findobj(gcf,'Tag','PhScan'),'String')); 
			if ixdist == 1, disp('in x: Uniform distribution'); end
			if ixdist == 2, disp('in x: Taylor distribution'); end
			if ixdist == 3, disp('in x: Cosine distribution'); end
			if ixdist == 4, disp('in x: Bayliss distribution'); end
			if ixdist == 5, disp('in x: Triangular distribution'); end
			if iydist == 1, disp('in y: Uniform distribution'); end
			if iydist == 2, disp('in y: Taylor distribution'); end
			if iydist == 3, disp('in y: Cosine distribution'); end
			if iydist == 4, disp('in y: Bayliss distribution'); end
         if iydist == 5, disp('in y: Triangular distribution'); end
         
      msg = ['Computing array pattern for ',num2str(it*ip),' angles'];             
      hwait=waitbar(0,msg);
      pause(0.1);
   
      [ampxn,ampyn] = getamplitudes(Nx,ixdist,Ny,iydist);
      
% calculate aperture efficiency
      s1=0; s2=0;
      for i1=1:Nx
		for i2=1:Ny
		  s1=s1+abs(ampxn(i1)*ampyn(i2)); s2=s2+abs(ampxn(i1)*ampyn(i2))^2;
	    end
	  end
	  eta=s1^2/Nx/Ny/s2;
%	  disp(['aperture efficiency: ',num2str(eta)])       
 
           
 % determine the phase distribution  

      us = sin(ths*rad)*cos(phs*rad);
      vs = sin(ths*rad)*sin(phs*rad);
      psix = bk*dx*us; 
      psiy = bk*dy*vs;
      
% generate exact phase required at each element.  
% positive scan corresponds to increasing phase lag with increasing n.

      xsix = -(2*[1:Nx] - (Nx + 1))/2*psix;
      xminx = min(xsix(1),xsix(Nx));
      xsix(1:Nx)=xsix(1:Nx)-xminx;
      qphx=xsix;
      xsiy = -(2*[1:Ny] - (Ny + 1))/2*psiy;
      xminy = min(xsiy(1),xsiy(Ny));
      xsiy(1:Ny)=xsiy(1:Ny)-xminy;
      qphy=xsiy;
      
% number of bits is nbit; number of phase states is 2**nbit; each bit
% is 360/(2^nbit) degrees
        	nstates = 2^nbits;
        	bitsize = 2*pi/nstates;
         if iph == 2 
			qphx = truncate(Nx,bitsize,xsix);
			qphy = truncate(Ny,bitsize,xsiy);
		 end
         if (iph == 3 | iph == 4)
            qphx = rro(iph,Nx,nstates,bitsize,xsix);
			qphy = rro(iph,Ny,nstates,bitsize,xsiy);
         end
% save quantized and unquantized phases if desired
%  save Qfaz.m qphx -ASCII
%  save Lfaz.m xsix -ASCII
      % begin Pattern loop
      for i1=1:ip
    	for i2=1:it
         figure(hwait);
         waitbar(((i1-1)*ip+i2)/(ip*it),hwait);
         phi(i1,i2) = pstart + (i1 - 1)*delp;
	      phr = phi(i1,i2)*rad;
   	      theta(i1,i2)=tstart + (i2 - 1)*delt;
      	   thr = theta(i1,i2)*rad;
         	st = sin(thr);		ct = cos(thr);
	        cp = cos(phr);		sp = sin(phr);
   	        u = st*cp; 			v = st*sp; 			w = ct;
            U(i1,i2) = u; 		V(i1,i2) = v; 		W(i1,i2)=w;          
         	uu = ct*cp; 		vv = ct*sp; 		ww = -st;
	        sumx = 0;
% sum to get array factor -- begin array loop ---
      		for n = 1:Nx
				nn = (2*n - (Nx + 1))/2;
		        argx = bk*dx*u*nn;
				for m = 1:Ny
					mm = (2*m - (Ny+1))/2;
					argy = bk*dy*v*mm;
% for difference distribution add 180 deg to half the elements
         			phase = qphx(n) + qphy(m); flpx=0; flpy=0;
         			if ixdist == 4 & n > Nx/2, flpx = pi;, end
         			if iydist == 4 & m > Ny/2, flpy = pi;, end
                    pherror(n,m)= phase - xsix(n) - xsiy(m);
		 			sumx = sumx + ampxn(n)*ampyn(m)*exp(j*(phase + flpx + flpy + argx + argy));
	   			end
      		end  % end array loop -----
            
% normalize the pattern to the number of elements
% (i.e., uniform array is reference level for pattern plot)
        		ev(i1,i2) = abs(sumx);
                eva(i1,i2) = sumx;
        		ee = ev(i1,i2)^2;
        		edb(i1,i2) = 10*log10(ee + 1e-10);
	 		end
		end    % end of pattern loop 
        % close waitbar
        close(hwait);
        
        
  		dbmax = max(max(edb));
% plot dB relative to a uniform array; set dynamic range to pmin
		pmin = -50;
		edb = edb - dbmax;

      for i1 = 1:ip
    		for i2 = 1:it
      		if edb(i1,i2) < pmin, edb(i1,i2) = pmin; end
    		end
  		end


% calculate phase quantization loss at scan angle (assume uniform array)
     AF = abs(sum(sum(exp(j*pherror))))/Nx/Ny;
     qloss=-20*log10(AF);
     disp(['phase shifter quantization loss (dB): ',num2str(qloss)])
     save arraydat
      if (it == 1 | ip == 1)
         reply = questdlg('Select Plot Type','Plot Type Selection','Rectangular','Polar','Rectangular');
         switch reply
            case 'Rectangular'
              answer=1;
                        
            case 'Polar'
              answer=0;
          
        end%switch
      end %if
      % export pattern data to file patdata
      reva=real(eva); ieva=imag(eva);
      save patdata theta phi reva ieva -ASCII
      if ip == 1
   		figure(3),clf
	   	if answer == 1, plot(theta,edb),grid 
 	 			axis([tstart,tstop,pmin,0])
    			xlabel('Pattern Angle, theta (deg)')
    			ylabel('Normalized Pattern (dB)')
   		end
   		if answer == 0, polardb(theta,edb,'k-'), end
   		title(['phi = ',num2str(pstart),', aperture efficiency= ',num2str(eta)])
 		end
       
      if it == 1
   		figure(3),clf
   		if answer == 1, plot(phi,edb),grid
    			axis([pstart,pstop,pmin,0])
    			xlabel('Pattern Angle, phi (deg)')
    			ylabel('Normalized Pattern (dB)')
   		end
   		if answer == 0, polardb(phi,edb,'k-'), end
   		title(['theta = ',num2str(tstart),', aperture efficiency= ',num2str(eta)])
  		end
                
      if ip > 1 & it > 1
   		figure(3),clf
			meshc(U,V,edb),grid,axis([-1 1 -1 1 -60,0]),grid
    		axis square
    		xlabel('U = sin(theta)*cos(phi)')
    		ylabel('V = sin(theta)*sin(phi)')
			zlabel('|AF|, dB')
			view(45,45)
			if ixdist == 1, xlab='in x: Uniform distribution'; end
			if ixdist == 2, xlab='in x: Taylor distribution'; end
			if ixdist == 3, xlab='in x: Cosine distribution'; end
			if ixdist == 4, xlab='in x: Bayliss distribution'; end
			if ixdist == 5, xlab='in x: Triangular distribution'; end
			if iydist == 1, ylab='in y: Uniform distribution'; end
			if iydist == 2, ylab='in y: Taylor distribution'; end
			if iydist == 3, ylab='in y: Cosine distribution'; end
			if iydist == 4, ylab='in y: Bayliss distribution'; end
			if iydist == 5, ylab='in y: Triangular distribution'; end
			title([xlab,';   ',ylab])
   	end
        
   case 'Close'       
      h_figs = get(0,'children');    
      for fig = h_figs'              
            delete(fig);      
	   end             
                  
   case 'Print'
      h_figs = get(0,'children');
		for fig = h_figs'
         if strcmp(get(fig,'Tag'),'Array2d')
            figure(fig);  
            print;
            break;
         end
      end   
      
end % switch
  
% >>>>>>>>>>>>>>>> Validation of input values <<<<<<<<<<<<<<<<<<<
% validates phi starting angle
function o_pstart = getPStart(start) 
  
  temp1 = str2num(start);
  temp2 = str2num(get(findobj(gcf,'Tag','PStop'),'String'));

  if (isempty(temp1)) | temp1 < 0 | temp1 > 360
  		errordlg('Enter a Phi Starting angle between 0 and 360 degrees.', ...
        		  'Angle Status', 'error');
    	temp1 = 0; % default phi start angle
  elseif temp1 == temp2
 		set(findobj(gcf,'Tag','Delp'),'String',num2str(1));
      msgbox('For a phi-cut, increment is set to 1 degree.', ...
         	 'Phi-Cut Set','help');        
  elseif (start == 'i' | start == 'j')
     errordlg('Enter a Phi Starting angle between 0 and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 0; % default phi start angle
  elseif temp1 > temp2   % phi start greater than phi stop angle
     errordlg('Phi starting angle is greater than ending angle!', ...
        		  'Angle Status','error'); 
     temp1 = 0; % default phi ending angle             
  end 
  o_pstart = temp1;
% end getPStart  
  
% validates phi ending angle 
function o_pstop = getPStop(stop)  
  
  temp1 = str2num(stop);
  temp2 = str2num(get(findobj(gcf,'Tag','PStart'),'String'));
  
  if (isempty(temp1)) | temp1 < 0 | temp1 > 360
     errordlg('Enter a Phi ending angle between starting angle and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 180; 
  elseif temp1 == temp2 % pstop angle = pstart angle
		set(findobj(gcf,'Tag','Delp'),'String',num2str(1));
      msgbox('For a phi-cut, increment is set to 1 degree.', ...
         	 'Phi-Cut Set','help');        
  elseif temp2 > temp1   % phi start greater than phi stop angle
     errordlg('Phi ending angle is less than starting angle!', ...
        		  'Angle Status','error'); 
     temp1 = 180; % default phi ending angle
  elseif (stop == 'i' | stop == 'j')
     errordlg('Enter a Phi ending angle between 0 and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 180; % default phi ending angle
  end 
  o_pstop = temp1;
% end getPStop  
  
% validates phi increment angle
function o_delp = getDelp(inc)   
  temp3 = str2num(inc);
  temp1 = str2num(get(findobj(gcf,'Tag','PStart'),'String'));
  temp2 = str2num(get(findobj(gcf,'Tag','PStop'),'String'));
  del = temp2 - temp1;
   
  if temp1 == temp2
     if (temp3 ~= 1)
        msgbox('For a phi-cut, increment is set to 1 degree.', ...
           		'Phi-Cut Set','help');
        del = 1;  % default value for phi-cut
     end     
  elseif isempty(temp3) | (temp3 <= 0) | (temp3 > del)
     errordlg('Enter an increment angle less than the diference between starting and ending angles.',...
        		  'Angle Status', 'error');         
     del = 3;  % default phi increment
  elseif (inc == 'i' | inc == 'j')
     errordlg('Enter an increment angle less than the diference between starting and ending angles.', ...
     			  'Angle Status', 'error');     
     del = 3; % default phi increment angle
  else
     del = temp3;
  end % if
  o_delp = del;
% end getDelp  
   
   % validates theta starting angle
function o_tstart = getTStart(start)    

  temp1 = str2num(start);
  temp2 = str2num(get(findobj(gcf,'Tag','TStop'),'String'));

  if (isempty(temp1)) | temp1 < -360 | temp1 > 360
  		errordlg('Enter a Theta Starting angle between -360 and 360 degrees.', ...
        		  'Angle Status', 'error');
    	temp1 = 0; % default theta start angle
  elseif temp1 == temp2
 		set(findobj(gcf,'Tag','Delt'),'String',num2str(1));
      msgbox('For a theta-cut, increment is set to 1 degree.', ...
         	 'Phi-Cut Set','help');  
% allowing negative theta values by commenting out
     elseif (start == 'i' | start == 'j')
     errordlg('Enter a Theta Starting angle between -360 and 360 degrees.', ...
        		  'Angle Status', 'error');
     temp1 = 0; % default theta start angle
  elseif temp1 > temp2   % theta start greater than theta stop angle
     errordlg('Theta starting angle is greater than ending angle!', ...
        		  'Angle Status','error'); 
     temp1 = 0; % default theta ending angle             
  end 
  o_tstart = temp1;
% end getTStart  
    
% validates theta ending angle
function o_tstop = getTStop(stop)   
  
  temp1 = str2num(stop);
  temp2 = str2num(get(findobj(gcf,'Tag','TStart'),'String'));
       
  if (isempty(temp1)) | (temp1 < 0) | (temp1 > 360)
     errordlg('Enter a Theta ending angle between starting angle and 360 degrees.', ...
        		  'Theta Stop Angle Status', 'error');
     temp1 = 180; 		% default theta stop angle
  elseif temp1 == temp2	% tstop angle = tstart angle
		set(findobj(gcf,'Tag','Delt'),'String',num2str(1));
      msgbox('For a theta-cut, increment is set to 1 degree.', ...
         	 'Theta-Cut Set','help');
  elseif (temp2 > temp1)   % theta stop less than theta start angle
     errordlg('Theta ending angle is less than starting angle!', ...
        		  'Theta Stop Angle Status','error'); 
     temp1 = 180; % default theta stop angle 
% allowing negative values 
  elseif (stop == 'i' | stop == 'j')
        errordlg('Enter a Theta Ending angle between -360 and 360 degrees.', ...
        		  'Theta Stop Angle Status', 'error');
        temp1 = 180; % default theta ending angle
  end 
  o_tstop = temp1;
% end getTStop  
  
% validates theta increment angle
function o_delt = getDelt(inc)    
   temp3 = str2num(inc);
   temp1 = str2num(get(findobj(gcf,'Tag','TStart'),'String'));
   temp2 = str2num(get(findobj(gcf,'Tag','TStop'),'String'));
   del = temp2 - temp1;
   
   if temp1 == temp2 	% tstart == tstop
      if temp3 ~= 1
         msgbox('For a theta-cut, increment is set to 1 degree.', ...
            	 'Theta-Cut Set','help');
         del = 1;  % default value for theta-cut
      end
   elseif isempty(temp3) | (temp3 <= 0) | (temp3 > del)
      errordlg('Enter an increment angle less than the diference between starting and ending angles.', ...
         		'Angle Status', 'error');     
      del = 3;  % default theta increment angle
   elseif (inc == 'i' | inc == 'j')
      errordlg('Enter an increment angle less than the difference between starting and ending angle.', ...
         		'Angle Status', 'error');
      del = 3; % default theta increment angle
   else         
      del = temp3;
   end % if
   o_delt = del;
% end getDelt  

   
% validates Number of Elemets
function o_nel = getNEL(nx_str)    
  
  	temp = str2num(nx_str);
   if (isempty(temp)) | (floor(temp) <= 0)
      errordlg('Enter a postive integer.', ...
         		'Number of Elements', 'error');
      temp = 10; % default          
   end 
   o_nel = floor(temp);
% end getNEL  
   
% validates Array Element Spacing
function o_del = getSpacing(str)   
  
   temp = str2num(str);
   if (isempty(temp)) | (floor(temp) < 0)      
      errordlg('Please check spacing of array elements.',...
         		'  Element Spacing', 'error');
      temp = 1; % default  
   end 
   o_del = temp;
% end getSpacing  
 
% validates Scan Angle for Theta and Phi
function o_scan = getScanAngle(start)    
  
  temp = str2num(start);
  if (isempty(temp)) | (temp < 0) | (temp > 360)
     errordlg('Enter a Scan Angle between 0 and 360 degrees.', ...
        		  '  Scan Angle', 'error');
     temp = 30; % default theta start angle
  elseif (start == 'i' | start == 'j')
     errordlg('Enter a Scan Angle between 0 and 360 degrees.', ...
        		  '  Scan Angle', 'error');
     temp = 30; % default theta start angle
  end 
  o_scan = temp;
% end getScanAngle  
