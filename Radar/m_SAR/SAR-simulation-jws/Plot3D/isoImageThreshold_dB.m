function fout = isoImageThreshold_dB(sarImage3DAbs,dynamicRange_dB,x,y,z)

% function call:
% isoImageThreshold(abs(rImage),-20,x2,y2,z2)

sarImage3DAbs_dB = mag2db(sarImage3DAbs/max(sarImage3DAbs(:)));
% sarImage3DAbs_dB = sarImage3DAbs_dB;
[Y,X,Z] = meshgrid(y,x,z);
[faces,vertices,colors] = isosurface(X,Y,Z,sarImage3DAbs_dB,dynamicRange_dB,ones(size(X)));
fout = figure('OuterPosition',[695 166 670 712]);
set(gca,'FontSize',18);
% figure
patch('Vertices',vertices(:,[3,1,2]),'Faces',faces(:,[3,1,2]),'FaceVertexCData',colors,...
    'FaceColor','interp','EdgeColor','interp');
grid on
xlabel('z(m)'); ylabel('x(m)'); zlabel('y(m)')
xlim([x(1) x(end)]); 
zlim([y(1) y(end)]); 
ylim([z(1) z(end)]);
view(-50,10)
colormap gray
