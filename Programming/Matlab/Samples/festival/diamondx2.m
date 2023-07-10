function diamondx2
hold on
ax=gca;
axis equal
grid on
ax.GridLineStyle='--';
ax.LineWidth=1.2;
ax.XLim=[-2,2];
ax.YLim=[-2,2];
ax.ZLim=[-1.8,1.5];
ax.XColor=[1,1,1].*0.4;
ax.YColor=[1,1,1].*0.4;
ax.ZColor=[1,1,1].*0.4;
ax.DataAspectRatio=[1,1,1];
ax.DataAspectRatioMode='manual';
ax.CameraPosition=[-67.6287 -204.5276   82.7879];

light('Position',[5,6,5])
light('Position',[5,6,5])


faceColor=[0 71 177];
facePara={faceColor./255,'FaceAlpha',0.4,'EdgeColor',faceColor./255.*0.8,'EdgeAlpha',0.2,...
      'FaceLighting','gouraud','EdgeLighting','gouraud',...
      'SpecularStrength',0.9,'DiffuseStrength',0.8,'AmbientStrength',0.7}; % ����� 
drawDiamond(facePara)

faceColor=[237 64 153];
facePara={faceColor./255,'FaceAlpha',0.4,'EdgeColor',faceColor./255.*0.8,'EdgeAlpha',0.2,...
      'FaceLighting','gouraud','EdgeLighting','gouraud',...
      'SpecularStrength',0.9,'DiffuseStrength',0.8,'AmbientStrength',0.7}; % ����� 
drawDiamond(facePara) 

    function drawDiamond(facePara)
        
        thetaSet8=linspace(0,2*pi-pi/4,8)';
        thetaSet16=linspace(0,2*pi-pi/8,16)';
        
        % �������Ϸ��˱���
        pntSet1=[cos(thetaSet8),sin(thetaSet8),ones(8,1)];
        fill3(pntSet1(:,1),pntSet1(:,2),pntSet1(:,3),facePara{:})
        
        % һȦ8��������
        pntSet2=[cos(thetaSet8+pi/8).*1.3,sin(thetaSet8+pi/8).*1.3,ones(8,1).*0.7];
        for i=1:8
            p1=i;
            p2=mod(i,8)+1;
            p3=i;
            fill3([pntSet1([p1,p2],1);pntSet2(p3,1)],...
                [pntSet1([p1,p2],2);pntSet2(p3,2)],...
                [pntSet1([p1,p2],3);pntSet2(p3,3)],facePara{:})
        end
        
        % һȦ8���ı���
        pntSet3=[cos(thetaSet8).*1.7,sin(thetaSet8).*1.7,ones(8,1).*0.3];
        for i=1:8
            p1=mod(i,8)+1;
            p2=i;
            p3=p1;
            p4=p1;
            fill3([pntSet1(p1,1);pntSet2(p2,1);pntSet3(p3,1);pntSet2(p4,1)],...
                [pntSet1(p1,2);pntSet2(p2,2);pntSet3(p3,2);pntSet2(p4,2)],...
                [pntSet1(p1,3);pntSet2(p2,3);pntSet3(p3,3);pntSet2(p4,3)],facePara{:})
        end
        
        % һȦ16��������
        pntSet4=[cos(thetaSet16).*1.7,sin(thetaSet16).*1.7,ones(16,1).*0.3];
        for i=1:8
            p1=i;
            p2=2*i-1;
            p3=2*i;
            fill3([pntSet2(p1,1);pntSet4([p2,p3],1)],...
                [pntSet2(p1,2);pntSet4([p2,p3],2)],...
                [pntSet2(p1,3);pntSet4([p2,p3],3)],facePara{:})
            p2=2*i;
            p3=mod(2*i,16)+1;
            fill3([pntSet2(p1,1);pntSet4([p2,p3],1)],...
                [pntSet2(p1,2);pntSet4([p2,p3],2)],...
                [pntSet2(p1,3);pntSet4([p2,p3],3)],facePara{:})
        end
        
        % һȦ16���ı߽���
        pntSet5=[cos(thetaSet16).*1.7,sin(thetaSet16).*1.7,ones(16,1).*0.15];
        for i=1:16
            p1=i;p2=mod(i,16)+1;
            p3=mod(i,16)+1;p4=i;
            fill3([pntSet4(p1,1);pntSet4(p2,1);pntSet5(p3,1);pntSet5(p4,1)],...
                [pntSet4(p1,2);pntSet4(p2,2);pntSet5(p3,2);pntSet5(p4,2)],...
                [pntSet4(p1,3);pntSet4(p2,3);pntSet5(p3,3);pntSet5(p4,3)],facePara{:})
        end
        pntSet6=[cos(thetaSet8+pi/8).*0.4,sin(thetaSet8+pi/8).*0.4,ones(8,1).*(-1.15)];
        
        % һȦ16����������
        for i=1:8
            p1=i;
            p2=2*i-1;
            p3=2*i;
            fill3([pntSet6(p1,1);pntSet5([p2,p3],1)],...
                [pntSet6(p1,2);pntSet5([p2,p3],2)],...
                [pntSet6(p1,3);pntSet5([p2,p3],3)],facePara{:})
            p2=2*i;
            p3=mod(2*i,16)+1;
            fill3([pntSet6(p1,1);pntSet5([p2,p3],1)],...
                [pntSet6(p1,2);pntSet5([p2,p3],2)],...
                [pntSet6(p1,3);pntSet5([p2,p3],3)],facePara{:})
        end
        
        % һȦ8�����ı���
        pntSet7=[cos(thetaSet8).*1.7,sin(thetaSet8).*1.7,ones(8,1).*0.15];
        for i=1:8
            p1=mod(i,8)+1;
            p2=i;
            p4=mod(i,8)+1;
            fill3([pntSet7(p1,1);pntSet6(p2,1);0;pntSet6(p4,1)],...
                [pntSet7(p1,2);pntSet6(p2,2);0;pntSet6(p4,2)],...
                [pntSet7(p1,3);pntSet6(p2,3);-1.5;pntSet6(p4,3)],facePara{:})
            
        end
    end
end
