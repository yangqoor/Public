function crystalHeart
clc;clear;close all
hold on
% drawCrystal([1,1,1],[3,3,3],pi/6,0.8,0.14)
sep=pi/8;
t=[0:0.2:sep,sep:0.02:pi-sep,pi-sep:0.2:pi+sep,pi+sep:0.02:2*pi-sep,2*pi-sep:0.2:2*pi];
x=16*sin(t).^3;
y=13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t);
z=zeros(size(t));
plot3(x,y,z,'Color',[186,110,64]./255,'LineWidth',1)
for i=1:length(t)
    for j=1:6
        len=rand(1)*2+2;
        tempV=rand(1,3)-0.5;
        tempV=tempV./norm(tempV).*len;
        tempSpnt=[x(i),y(i),z(i)];
        tempEpnt=tempV+tempSpnt;
        drawCrystal(tempSpnt,tempEpnt,pi/6,0.8,0.14)
        disp([i,j])
    end
end
ax=gca;
ax.XLim=[-22,22];
ax.YLim=[-20,20];
ax.ZLim=[-10,10];
grid on
ax.GridLineStyle='--';
ax.LineWidth=1.2;
ax.XColor=[1,1,1].*0.4;
ax.YColor=[1,1,1].*0.4;
ax.ZColor=[1,1,1].*0.4;
ax.DataAspectRatio=[1,1,1];
ax.DataAspectRatioMode='manual';

    function drawCrystal(Spnt,Epnt,theta,cl,w)
       %plot3([Spnt(1),Epnt(1)],[Spnt(2),Epnt(2)],[Spnt(3),Epnt(3)])
       mainV=Epnt-Spnt;
       cutPnt=cl.*(mainV)+Spnt;
       cutV=[mainV(3),mainV(3),-mainV(1)-mainV(2)];
       cutV=cutV./norm(cutV).*w.*norm(mainV);
       cornerPnt=cutPnt+cutV;
       cornerPnt=rotateAxis(Spnt,Epnt,cornerPnt,theta);
       cornerPntSet(1,:)=cornerPnt';
       for ii=1:3
           cornerPnt=rotateAxis(Spnt,Epnt,cornerPnt,pi/2);
           cornerPntSet(ii+1,:)=cornerPnt';
       end
       for ii=1:4
           jj=mod(ii,4)+1;
           fill33(Spnt,cornerPntSet(ii,:),cornerPntSet(jj,:))
           fill33(Epnt,cornerPntSet(ii,:),cornerPntSet(jj,:))
       end
    end

    function fill33(p1,p2,p3)
        fill3([p1(1),p2(1),p3(1)],[p1(2),p2(2),p3(2)],[p1(3),p2(3),p3(3)],[0 71 177]./255.*1.03,...
            'FaceAlpha',0.2,'EdgeColor',[0 71 177]./255.*0.9,'EdgeAlpha',0.25,'LineWidth',0.5,...
            'EdgeLighting','gouraud','SpecularStrength',0.3)
        
    end

    function newPnt=rotateAxis(Spnt,Epnt,cornerPnt,theta)
        V=Epnt-Spnt;V=V./norm(V);
        u=V(1);v=V(2);w=V(3);
        a=Spnt(1);b=Spnt(2);c=Spnt(3);
        cornerPnt=[cornerPnt(:);1];
        
        rotateMat=[u^2+(v^2+w^2)*cos(theta)       ,  u*v*(1-cos(theta))-w*sin(theta),  u*w*(1-cos(theta))+v*sin(theta),  (a*(v^2+w^2)-u*(b*v+c*w))*(1-cos(theta))+(b*w-c*v)*sin(theta);
                   u*v*(1-cos(theta))+w*sin(theta),  v^2+(u^2+w^2)*cos(theta)       ,  v*w*(1-cos(theta))-u*sin(theta),  (b*(u^2+w^2)-v*(a*u+c*w))*(1-cos(theta))+(c*u-a*w)*sin(theta);
                   u*w*(1-cos(theta))-v*sin(theta),  v*w*(1-cos(theta))+u*sin(theta),  w^2+(u^2+v^2)*cos(theta)       ,  (c*(u^2+v^2)-w*(a*u+b*v))*(1-cos(theta))+(a*v-b*u)*sin(theta);
                   0                              ,  0                              ,  0                              ,  1];
        
        newPnt=rotateMat*cornerPnt;
        newPnt(4)=[];
    end

end
