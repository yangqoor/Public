
startT=[0 3 5 12 16,1.5 6 8 15 18,3 10 11 16 19,2 4 11 13 15,1 3 7 16 18,5 11 14 16 20];
durationT=[3 2 5 4 4,4 1 7 2 5,6 1 4 3 2,1 6 2 2 9,2 3 4 2 5,5 3 1 2 8];
jobId=[1 1 1 1 1,2 2 2 2 2,3 3 3 3 3,4 4 4 4 4,5 5 5 5 5,6 6 6 6 6];

% pName{length(jobId)}='';
% for i=1:length(jobId)
%     pName(i)={['[',num2str(startT(i)),',',num2str(startT(i)+durationT(i)),']']};
% end
pName{length(jobId)}='';
for i=1:length(jobId)
    pName(i)={num2str(i)};
end

GTC=ganttChart(startT,durationT,jobId,'String',pName);
% GTC=ganttChart(startT,durationT,jobId,'Curvature',.8);

% ax=gca;
% ax.YTickLabel={'Process1','Process2','Process3','Process4','Process5','Process6'};


GTC.t1(2).Color=[1,0,0];
GTC.t1(2).FontSize=25;