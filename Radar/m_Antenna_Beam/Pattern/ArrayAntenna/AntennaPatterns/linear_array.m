%This program print pattern for linear Array (uniform) Antenna by giing
%N,alfa,d
%and the wavelength you work with
%if you want full pattern maultiply this pattern by any Antenna pattern
%Have a nice Pattern "Arabia Tech"
lamda=input('enter the value of wave length= ');
N=input('enter the no. of elements= ');
alfa=input('enter your progressive phase= ');
d=input('enter the seperation distance between elements= ');
B=(2*pi/lamda);
theta= pi/100:pi/100:2*pi;
w=alfa+B*d.*cos(theta);
AF=sinc(N*(w./2))./sinc(w./2);
subplot(2,3,3)
polar(theta,AF)