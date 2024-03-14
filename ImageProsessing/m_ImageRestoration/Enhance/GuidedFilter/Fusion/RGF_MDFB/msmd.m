function Y=msmd(image_input1,image_input2,level,iteration,sigma_s,sigma_r,mm)

I=im2double(image_input1);
U=im2double(image_input2);
[h,w] =size(I);
Df=zeros(h,w);

dfilter = 'vk'; 
D1 = zeros(h,w,level);
D2 = zeros(h,w,level);
D = zeros(h,w,level);

Bi=I;
Br=U;
for i=1:1:level
    B1_1=RollingGuidanceFilter(Bi,sigma_s,sigma_r,iteration);
    D1(:,:,i)=Bi-B1_1;
    B2_1=RollingGuidanceFilter(Br,sigma_s,sigma_r,iteration);
    D2(:,:,i)=Br-B2_1;
    Bi=B1_1;
    Br=B2_1;
    D(:,:,i)=myselc(D1(:,:,i),D2(:,:,i));
    Df=Df + D(:,:,i);   
end
%%
Ibdfb=nsdfbdec(Bi,dfilter,mm);
Ubdfb=nsdfbdec(Br,dfilter,mm);
m=length(Ibdfb);
Fb = cell(m);
for j=1:1:m 
    Fb{j} = myselc(Ibdfb{j},Ubdfb{j});
end
Bf=nsdfbrec(Fb,dfilter);  
F=Bf+Df;
Y=uint8(((F)*255));

function Y = myselc(M1,M2)
um = 3;
% first step
A1 = ordfilt2(abs(es2(M1, floor(um/2))), um*um, ones(um));
A2 = ordfilt2(abs(es2(M2, floor(um/2))), um*um, ones(um));
% second step
mm = (conv2(double((A1 > A2)), ones(um), 'valid')) > floor(um*um/2);
Y  = (mm.*M1) + ((~mm).*M2);




