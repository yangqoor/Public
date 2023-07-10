%This program print pattern for TWA by giving the length of your Line
%and the wavelength you work with
%Have a nice Pattern "Arabia Tech"
lamda=input('enter the value of wave length= ');
l=input('enter your Line length l= ');
B=(2*pi/lamda);
theta= pi/100:pi/100:2*pi;
f1=sin(theta);
f2=1-cos(theta);
f3=sin(B*l/2.*(f2));
E=(f1./f2).*f3;
En=abs(E);
subplot(2,3,3)
polar(theta,En);