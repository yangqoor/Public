%% main.m
clear all;clc;

%% Load Data
[fre,data]=Load_data('array_2.txt');


%% calculate the AF and Pattern
[M,N]=size(data);
theta=0:0.02:pi/2;
phi=0:0.02:2*pi;
beta=2*pi*fre/3/10^8;
length_theta=length(theta);
length_phi=length(phi);
Pattern=zeros(length_theta,length_phi);
for a=1:length(theta)
    for b=1:length(phi)
        for i=1:M
             AF(i,a,b)=data(i,4)*exp(j*data(i,5))*exp(j*beta*(data(i,2)*cos(phi(b))+data(i,3)*sin(phi(b)))*sin(theta(a)));
                Pattern(a,b)=AF(i,a,b)+Pattern(a,b);
        end
    end
end

%% Normalization
Norm_Pattern=abs(Pattern/(max(max(Pattern))));

XX=sin(theta)'*cos(phi).*Norm_Pattern;
YY=sin(theta)'*sin(phi).*Norm_Pattern;
ZZ=cos(theta)'*ones(1,length(phi)).*Norm_Pattern;
figure;
surf(XX,YY,ZZ);
colormap;shading interp;


%% Beam Direction
 for a=1:length(theta)
     for b=1:length(phi)
       if (Pattern(a,b)==1)
           Beam_theta=a*0.01;
       end
     end
 end
 
 
%% Directivity

F2=Norm_Pattern.*Norm_Pattern;
omega=sum(sum(F2))*0.01*0.01;
D=4*pi/omega;






