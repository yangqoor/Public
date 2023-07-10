%This program print pattern for Loop Antenna by giving the radius of your
%Loop and the wavelength you work with
%Have a nice Pattern "Arabia Tech"
lamda=input('enter the value of wave length= ');
a=input('enter your loop radius a= ');
B=(2*pi/lamda);
theta= pi/100:pi/100:2*pi;
E=besselj(1,B*a.*sin(theta));
subplot(2,3,6)
polar(theta,E)
