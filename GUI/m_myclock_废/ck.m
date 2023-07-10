function f=ck(ti)
global aa hs hm hh
set(gca,'position',[[0 0 0.5 0.9]]) 
A=linspace(0,6.3,1000); 
x1=8*cos(A); 
y1=8*sin(A); 
x2=7*cos(A); 
y2=7*sin(A); 
plot(x1,y1,'b','linewidth',1.4) 
hold on 
plot(x2,y2,'b','linewidth',3.5) 
fill(0.4*cos(A),0.4*sin(A),'r'); 
axis off 
axis([-10 10 -10 10]) 
axis equal 
for k=1:12; 
xk=9*cos(-2*pi/12*k+pi/2);
yk=9*sin(-2*pi/12*k+pi/2);
plot([xk/9*8 xk/9*7],[yk/9*8 yk/9*7],'color',[0.8 0.1 0.5]) 
h=text(xk-0.5,yk,num2str(k),'fontsize',13,'color',[0.9 0.3 0.8]); 
end 
% 计算时针位置 
th=-(ti(4)+ti(5)/60+ti(6)/3600)/12*2*pi+pi/2; 
xh3=4.0*cos(th); 
yh3=4.0*sin(th); 
xh2=xh3/2+0.5*cos(th-pi/2); 
yh2=yh3/2+0.5*sin(th-pi/2); 
xh4=xh3/2-0.5*cos(th-pi/2); 
yh4=yh3/2-0.5*sin(th-pi/2); 
hh=fill([0 xh2 xh3 xh4 0],[0 yh2 yh3 yh4 0],[0.6 0.5 0.3]); 
set(hh,'EraseMode','Xor');
% 计算分针位置 
tm=-(ti(5)+ti(6)/60)/60*2*pi+pi/2; 
xm3=6.0*cos(tm); 
ym3=6.0*sin(tm); 
xm2=xm3/2+0.5*cos(tm-pi/2); 
ym2=ym3/2+0.5*sin(tm-pi/2); 
xm4=xm3/2-0.5*cos(tm-pi/2); 
ym4=ym3/2-0.5*sin(tm-pi/2); 
hm=fill([0 xm2 xm3 xm4 0],[0 ym2 ym3 ym4 0],[0.6 0.5 0.3]); 
set(hm,'EraseMode','Xor');
% 计算秒针位置 
ts=-(ti(6))/60*2*pi+pi/2; 
hs=line([0 7*cos(ts)],[0 7*sin(ts)],'color',...
    [0.6 0.5 0.3],'linewidth',3); 
set(hs,'EraseMode','Xor');
set(gcf,'doublebuffer','on'); 

while 1
    if aa==0
         break
    end
   % 计算时针位置 
   th=-(ti(4)+ti(5)/60+ti(6)/3600)/12*2*pi+pi/2;
   xh3=4.0*cos(th); 
   yh3=4.0*sin(th); 
   xh2=xh3/2+0.5*cos(th-pi/2); 
   yh2=yh3/2+0.5*sin(th-pi/2); 
   xh4=xh3/2-0.5*cos(th-pi/2); 
   yh4=yh3/2-0.5*sin(th-pi/2); 
   set(hh,'XData',[0 xh2 xh3 xh4 0],'YData',[0 yh2 yh3 yh4 0]) 
   plot(0,0,'*')
   % 计算分针位置 
   tm=-(ti(5)+ti(6)/60)/60*2*pi+pi/2; 
   xm3=6.0*cos(tm); 
   ym3=6.0*sin(tm); 
   xm2=xm3/2+0.5*cos(tm-pi/2); 
   ym2=ym3/2+0.5*sin(tm-pi/2); 
   xm4=xm3/2-0.5*cos(tm-pi/2); 
   ym4=ym3/2-0.5*sin(tm-pi/2); 
   set(hm,'XData',[0 xm2 xm3 xm4 0],'YData',[0 ym2 ym3 ym4 0]) 
   % 计算秒针位置 
   ts=-(ti(6))/60*2*pi+pi/2; 
   set(hs,'XData',[0 7*cos(ts)],'YData',[0 7*sin(ts)]) 
   drawnow;
   pause(0.05) ;
   %时间更新
   ti(6)=ti(6)+0.15;
   if ti(6)>60
       ti(6)=0;
       ti(5)=ti(5)+1;
   end
   if ti(5)>60
       ti(5)=0;
       ti(4)=ti(4)+1;
   end
   if ti(4)>12
       ti(4)=0;
   end
end 

