%This program print electric field pattern for rectangular Aperture Antenna by giving
%the a,b
%and the wavelength you work with
%Have a nice Pattern "Arabia Tech"
kind=input('Enter your antenna type Rectangular (1) or circular (2)= ');
lamda=input('enter the value of wave length= ');
theta= pi/100:pi/100:2*pi;
B=(2*pi/lamda);
u0=0;                  %@phi=90
u=B.*(sin(theta));
v0=0;                  %@phi=0
v=B.*(sin(theta));
if kind==1
    feeding=input('enter your feeding type "uniform(1),blocked in one dim. Aperture(2),TE10(3)": ');
    if feeding==1             %uniform
            a=input('enter ur larg rectanglar length a= ');
            b=input('enter ur small rectanglar length b= ');
            E1=sinc((b.*v)./2);   %E-plane phi=90
            E2=sinc((a.*u)./2);   %H-plane phi=0
            subplot(3,3,1)
            polar(theta,E1),title('E-plane')
            subplot(3,3,2)
            polar(theta,E1),title('H-plane')
    elseif feeding==2                                            %blocked
        delta=input('enter value of blocking= ');
        E1=(b.*sinc((b.*v)./2)) - (delta.*sinc((delta.*v)./2));     %E-plane
        E2=sinc((a.*u)./2);                                         %H-plane phi=0
        subplot(3,3,3)
        polar(theta,E1),title('E-plane')
        subplot(3,3,4)
        polar(theta,E1),title('H-plane')
        
   elseif feeding==3         %TE10
       E1=sinc((b.*v)./2);   %E-plane phi=90
       f1=(a/2).*(u-(pi/a));
       f2=(a/2).*(u+(pi/a));
       E2=sinc(f1)+sinc(f2); %H-plan phi=0
       subplot(3,3,5)
       polar(theta,E1),title('E-plane')
       subplot(3,3,6)
       polar(theta,E1),title('H-plane')
   end
elseif kind==2
    a=input('Enter radius of Circlur Aperture= ');
    f1=B*a;
    f=f1.*(sin(theta));
    E=(besselj(1,f))./f;      %E-plane or H-plane
    subplot(3,3,7)
    polar(theta,E)
end