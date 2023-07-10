%This program print pattern (AF) for Short and any Dipole Antenna by giving the length of your Dipole
%and the wavelength you work with
%Have a nice Pattern "Arabia Tech"
lamda=input('enter the value of wave length= ');
l=input('enter your dipole length l= ');
ratio=l/lamda;
B=(2*pi/lamda);
theta= pi/100:pi/100:2*pi;
if ratio<= 0.1            %check if Short Dipole
    E=sin(theta);
    En=abs(E);
    subplot(2,3,1)
    polar(theta,En)      %This plot polar pattern in plane which dipole appear as line
else                     %check if not short dipole
    f1=cos(B*l/2.*cos(theta));
    f2=cos(B*l/2);
    f3=sin(theta);
    E=(f1-f2)./f3;
    En=abs(E);
    subplot(2,2,2)
    polar(theta,En)        %This plot polar pattern in plane which dipole appear as line
end
