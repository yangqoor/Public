 function polardb(ang,pat,line_style)
% NON-NORMALIZING VERSION THAT DOES NOT REQUIRE POLAR2
% take angle and dB data and generate polar plot
% angle data in ang(:) is degrees; dB data in pat(:)
if any(size(ang) ~= size(pat))
	error('THETA and RHO must be the same size.');
end
  pmax=max(pat);
  dynr=60;  % dynamic range of dB scale
  rticks=6;  % number of rings in polar plot
  dbstep=dynr/rticks;    % dB spacing between rings -- must be integer
  top=floor(pmax/dbstep)*dbstep+dbstep;   % convenient outer ring dB value
  theta=ang*pi/180;
% set a floor
  for i=1:length(pat)
    if pat(i) < top-dynr, pat(i)=top-dynr; end
  end
  rho=pat+dynr-top;
  hold on
% define a circle
	th = 0:pi/50:2*pi;
	xunit = cos(th);
	yunit = sin(th);
	
% now really force points on x/y axes to lie on them exactly
    inds = [1:(length(th)-1)/4:length(th)];
    xunits(inds(2:2:4)) = zeros(2,1);
    yunits(inds(1:2:5)) = zeros(3,1);
	rmax=dynr; rmin=0;
	rinc = (rmax-rmin)/rticks;
	for i=(rmin+rinc):rinc:rmax
		plot(xunit*i,yunit*i,'-','color','k','linewidth',1);
		text(0,i+rinc/10,['  ' num2str(i-dynr+top)],'verticalalignment','bottom' );
	end

% plot spokes
	th = (1:6)*2*pi/12;
	cst = cos(th); snt = sin(th);
	cs = [-cst; cst];
	sn = [-snt; snt];
	plot(rmax*cs,rmax*sn,'-','color','k','linewidth',1);

% annotate spokes in degrees
	rt = 1.1*rmax;
	for i = 1:max(size(th))
	
	text(rt*cst(i),rt*snt(i),int2str(i*30),'horizontalalignment','center' );
		if i == max(size(th))
			loc = int2str(0);
		else
			loc = int2str(180+i*30);
		end
		text(-rt*cst(i),-rt*snt(i),loc,'horizontalalignment','center' );
	end

% set viewto 2-D
	view(0,90);
% set axis limits
	axis(rmax*[-1 1 -1.1 1.1]);

% transform data to Cartesian coordinates
xx = rho.*cos(theta);
yy = rho.*sin(theta);

% plot data on top of grid
	q = plot(xx,yy,line_style);
	hpol = q;
	axis('equal');axis('off');
    hold off
