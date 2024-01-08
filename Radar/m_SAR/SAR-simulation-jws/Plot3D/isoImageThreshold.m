function fout = isoImageThreshold(sarImage3DAbs,x,y,z)

% function call:
% isoImageThreshold(abs(rImage),-20,x2,y2,z2)

[Y,X,Z] = meshgrid(y,x,z);
[faces,vertices,colors] = isosurface(X,Y,Z,sarImage3DAbs,ones(size(X)));
fout = figure('OuterPosition',[695 166 670 712]);
% figure
set(gca,'FontSize',18);
patch('Vertices',vertices(:,[3,1,2]),'Faces',faces(:,[3,1,2]),'FaceVertexCData',colors,...
    'FaceColor','interp','EdgeColor','interp');
grid on
xlabel('z(m)'); 
ylabel('x(m)'); 
zlabel('y(m)')
xlim([x(1) x(end)]); 
zlim([y(1) y(end)]); 
ylim([z(1) z(end)]);
view(-50,10)
colormap gray
