clear all;
%======================================================================
%%% (I) parameters' definition
%======================================================================
c=3e+8;						% speed of light
pi=3.1415926;	 		    % pi
j00=sqrt(-1);			    % square root of -1

res_a=2;				    % required azimuth resolution
res_r=2;				    % required range resolution
k_a=1.2;				    % azimuth factor
k_r=1.2;				    % range factor

Ra=5000.;				    % radar working distance
va=70.; 				    % radar/platform forward velocity
Tp=1.e-6; 					% transmitted pulse width      
fc=3.e+9;	 				% carrier frequency 
FsFactor = 1.2;
theta=90*pi/180;			% squint angle   

%======================================================================

lamda=c/fc;							    % wavelength
Br=k_r*c/2./res_r;					    % required transmitted bandwidth
Fs=Br*FsFactor;						    % A/D sampling rate
bin_r=c/2./Fs;						    % range bin
Kr=Br/Tp;					  		    % range chirp rate	  

La=Ra*k_a*lamda/2/res_a/sin(theta);     % required synthetic aperture length
Ta=La/va;							    % required synthetic aperture time
fdc=2*va*cos(theta)/lamda;              % doppler centriod
fdr=-2*(va*sin(theta)).^2/lamda/Ra;	    % doppler rate
Bd=abs(fdr)*Ta;						    % doppler bandwidth
prf=round(Bd*2);					    % PRF	

%======================================================================
%%%(II) echo return modelling (point target)
%======================================================================

na=fix(Ta*prf/2);					% azimuth sampling number
ta=-na:na;											
ta=ta/prf;							% slow time along azimuth
xa=va*ta;%-Ra*cos(theta);				% azimuth location along flight track
Na=2*fix(na);

x0=[0 0 0 0 0];             % define multi points if you want
R0=[-20 -10 0 10 20];             % x0: azimuth location (positive towards forward velocity)
                                    % R0: slant range location (positive towards far range)
% x0=[0 0 ];
% R0=[0 10]; 

% x0=[ 0 ];  R0=[ 0 ];                % only one point
Npt_num = length(x0);

ra=zeros(Npt_num, length(xa));      % calculate every point target's slant range history
for i=1:Npt_num                                    
	ra(i,:)=sqrt((Ra*sin(theta)+R0(i)).^2+(xa+x0(i)).^2);		 
end   

rmax=max(max(ra));					% max. slant range
rmin=min(min(ra));					% min. slant range
rmc=fix((rmax-rmin)/bin_r);			% range migration,	number

rg=0*ra;                            % initialize 
rg=fix((ra-rmin)/bin_r+1);			% range gate index caused by range migration
rgmax=max(max(rg));
rgmin=min(min(rg));

nr=round(Tp*Fs);					% samples of a pluse
tr=1:fix(nr)+1;									
tr=tr/Fs-Tp/2;						% fast time within a pluse duration
Nr=nr+rgmax;

%======================================================================
%%%(II) echo return modelling (point target)
%======================================================================

sig=zeros(Na,Nr); 
for i=1:Na			
   for k=1:Npt_num
      sig_range=exp(-j00*4*pi/lamda*ra(k,i))*exp(-j00*pi*Kr*(tr).^2);
  		sig(i,rg(k,i):rg(k,i)+nr)=sig(i,rg(k,i):rg(k,i)+nr)+sig_range;
   end  
end
sig_real=real(sig);
colormap(gray); contour(sig_real);

