close all;
clc;

% Scientific papaer style 
set(0,'defaulttextinterpreter','latex')
set(0,'defaultaxesfontname','Times')
set(0,'defaultaxesfontsize', 12)

[ha, hfigure]= tight_subplot_cm(3, 2, [.3 .5], [1 0.5], [.7 .5], 10, 10);
for ii = 1:6; 
    axes(ha(ii)); plot(randn(10,ii)); 
end

axes(ha(5))
xlabel('x-axis')
axes(ha(6))
xlabel('x-axis')

axes(ha(1))
ylabel('y-axis')
axes(ha(3))
ylabel('y-axis')
axes(ha(5))
ylabel('y-axis')


set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

% Download export fig from: 
%    http://ch.mathworks.com/matlabcentral/fileexchange/23629-export-fig
% Open test.pdf, see the size of it (see in the properties), it should be
% 10cm x 10cm.
export_fig test.pdf -transparent -nocrop;