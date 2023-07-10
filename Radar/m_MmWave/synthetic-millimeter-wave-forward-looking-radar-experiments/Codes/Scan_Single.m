function result=Scan_Single(Scene,Carrier,Scan,Wave,Times,result)
result=[];
for i=1:Scan.Number
    Scan.CurrentDown=-Scan.Scope/2+(i-1)*Scan.Beam_Width;
    Scan.CurrentUp=-Scan.Scope/2+i*Scan.Beam_Width;
    
    t=(1:1:Wave.N)/Wave.fs;
    s=zeros(1,Wave.N);
    
    out=Cal_Scene_Para(Scene,Carrier,Scan);
    for k=1:numel(out)
        s=s+out(k).sigma*exp(1j*2*pi*(2*Carrier.v/Wave.lamda-Wave.b*2*out(k).r/Wave.c)*t-1j*4*pi*out(k).r/Wave.lamda)...
            .*(t>2*out(k).r/Wave.c).*(t<2*out(k).r/Wave.c+Wave.Tm);
    end
    
    imaging_s=fliplr(fftshift(fft(s)));
%         figure;plot(abs(imaging_s));
    result=[result;repmat(imaging_s(2049:2700),Times,1)];
end

end