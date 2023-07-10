startT=[0 3 5 12 16,1.5 6 8 15 18,3 10 11 16 19,2 4 11 13 15,1 3 7 16 18,5 11 14 16 20];
durationT=[3 2 5 4 4,4 1 7 2 5,6 1 4 3 2,1 6 2 2 9,2 3 4 2 5,5 3 1 2 8];
jobId=[1 1 1 1 1,2 2 2 2 2,3 3 3 3 3,4 4 4 4 4,5 5 5 5 5,6 6 6 6 6];

GTC=ganttChart(startT,durationT,jobId);
colorList=[204,154,129;222,191,170;185,184,163;165,165,139;107,112,92]./255;

for i=1:max(jobId)
    tHdl=GTC.(['p',num2str(i)]);
    for j=1:length(tHdl)
        set(tHdl(j),'FaceColor',colorList(j,:))
    end
end