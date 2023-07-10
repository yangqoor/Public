function result=Scan_Synthetic(Scene,Carrier,Scan,Wave,Radar,Times,result)
result=[];

for i=1:Scan.Number
% for i=4:4
    Scan.CurrentDown=-Scan.Scope/2+(i-1)*Scan.Beam_Width;
    Scan.CurrentUp=-Scan.Scope/2+i*Scan.Beam_Width;
    s=zeros(Radar.Number,Wave.N);
    for j=1:Radar.Number     
        t=(1:1:Wave.N)/Wave.fs;       
        out=Cal_Scene_Para(Scene,Carrier,Scan,Radar.PosArray(j));
        for k=1:numel(out)
            s(j,:)=s(j,:)+out(k).sigma*exp(1j*2*pi*(2*Carrier.v/Wave.lamda-Wave.b*2*out(k).r/Wave.c)*t-1j*4*pi*out(k).r/Wave.lamda)...
                .*(t>2*out(k).r/Wave.c).*(t<2*out(k).r/Wave.c+Wave.Tm);
        end
    end
  
    imaging_s=fliplr(fftshift(fft(s,[],2),2));
    imaging_s=imaging_s(:,2049:2700);
    
    %     Filtering
    filter=Gen_Filter(Scan,Wave,Radar,2700-2049+1);
    
    image1=imaging_s.*filter;
%     image2=[zeros(size(image1,1)*4,size(image1,2));image1;zeros(size(image1,1)*4,size(image1,2))];
    image2=image1;
%     image3=fft(image2,[],1);
    image3=fftshift(fft(image2,[],1),1);
%     figure;imshow(abs(image3)/max(max(abs(image3))));

%     for kkk=1:2
%         figure;plot(abs(imaging_s(kkk,:)));
%     end
%     apk=fft(imaging_s,[],1);
%     figure;imshow(abs(apk)/max(max(abs(apk))));
    
    %     figure;plot(abs(imaging_s));
%         result=[result;repmat(imaging_s(200:700),Times,1)];
result=[result;image3];
end

end