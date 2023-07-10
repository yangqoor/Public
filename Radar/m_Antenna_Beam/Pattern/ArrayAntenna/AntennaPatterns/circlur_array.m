%This program print pattern for circlar Array (uniform) Antenna by giing
%N,a
%and the wavelength you work with
%if you want full pattern maultiply this pattern by any Antenna pattern
%Have a nice Pattern "Arabia Tech"
lamda=input('enter the value of wave length= ');
N=input('enter the no. of elements= ');
a=input('enter your circular radius= ');
theta0=input('enter angle theta at which main lobe occurs= ');
phi0=input('enter angle phi at which main lobe occurs= ');
B=(2*pi/lamda);
theta= pi/100:pi/100:2*pi;
phi=pi/100:pi/100:2*pi;
f1=sin(theta0)*cos(phi0);
f2=sin(theta0)*sin(phi0);
f3=sin(theta).*cos(phi);
f4=sin(theta).*sin(phi);
x=f3-f1;
y=f4-f2;
ro=a.*sqrt(x.^2+y.^2);
AFn=besselj(0,B.*ro);
subplot(2,3,6)
polar(theta,AFn)
