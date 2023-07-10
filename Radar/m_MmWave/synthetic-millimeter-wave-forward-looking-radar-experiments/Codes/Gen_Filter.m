function filter=Gen_Filter(Scan,Wave,Radar,RNum)
filter=zeros(Radar.Number,RNum);
sita=(Scan.CurrentDown+Scan.CurrentUp)/2;

for ii=1:RNum
    for jj=1:Radar.Number
        r_ref=ii*Wave.c*Wave.fs/2/Wave.b/Wave.N;
        x=r_ref*cosd(sita);
        y=r_ref*sind(sita);
        
        r=sqrt(x^2+(y-Radar.PosArray(jj))^2);
        filter(jj,ii)=exp(1j*4*pi*r/Wave.lamda);
    end
end
end