%program for the synthesis of thinned planar arrays with low peak sidelobe level
%it can operate on two frequency
clear;
res=1000;%resolution
MaxTemperature=4;%initial temperature
MinTemperature=0.1;%final temperature
NumTempsteps=1000;%No.of algorithm iteration
MinSideLobeLevel=-24;%estimate of best sidelobe level
FrozenTest=1000;%No.of attempts to change iteration
Lengthx=10;%No.of elements in each row of the array
Lengthy=10;%No.of elements in each line of the array

%Use program above to caculate how temperature must be lowered
logMaxTemp=log(MaxTemperature);
logMinTemp=log(MinTemperature);
deltaTemp=(logMaxTemp-logMinTemp)/NumTempsteps;
c=3e8;
B=[10e9 9e9 8e9 6e9 4e9];
fh=B(1);
lemdah=c/fh;
lemda=c./B;
d=lemdah/2;
k=2*pi./lemda;
visc=0;
alpha=-10/119;
beta=5760/119;
MagicConstant=4;

%Caculate the radiation pattern for the trial solution
plcmnt=zeros(Lengthy,Lengthx);
for m=1:1000
        x=floor(rand*Lengthx)+1;
        y=floor(rand*Lengthy)+1;
        sel=floor(rand*3);
        if sel==1
           plcmnt(y,x)=1;
       elseif sel==2
           plcmnt(y,x)=2;
       else
            plcmnt(y,x)=0;
       end;
end

%caculate the radiation pattern for the trial solution
theta=(0:res)'/res*pi/2;
phi=[0 pi/2];%linspace(0,2*pi,25);
u=sin(theta)*cos(phi);
v=sin(theta)*sin(phi);
S0=zeros(size(u));S1=zeros(size(u));S2=zeros(size(u));
for m=1:Lengthy
    for n=1:Lengthx
        if (plcmnt(m,n)==0)
            S0=S0+exp(i*k(1)*((n-1)*d*u+(m-1)*d*v));
        elseif(plcmnt(m,n)==1)
            S1=S1+exp(i*k(2)*((n-1)*d*u+(m-1)*d*v));
        else
            S2=S2+exp(i*k(3)*((n-1)*d*u+(m-1)*d*v));
        end
    end
end
%run the algorithm
OldPlacement=plcmnt;
S0=abs(S0);S0=S0/max(max(S0));S0=20*log10(S0);
S1=abs(S1);S1=S1/max(max(S1));S1=20*log10(S1);
S2=abs(S2);S2=S2/max(max(S2));S2=20*log10(S2);
%find the peak side lobe level
for m=1:length(phi)
    for n=res+1:-1:2
         if S0(n-1,m)<S0(n,m),brk0=n;end
         if S1(n-1,m)<S1(n,m),brk1=n;end
         if S2(n-1,m)<S2(n,m),brk2=n;end
    end
    BS0(m)=max(S0(brk0:res+1,m));
    BS1(m)=max(S1(brk1:res+1,m));
    BS2(m)=max(S2(brk2:res+1,m));
end
bsc=max([BS0,BS1,BS2]);

%thinning
ArraysTested=0;
NoEventCount=0;
ScoreTable=zeros(Lengthy,Lengthx);
for tmprtr=logMaxTemp:-deltaTemp:logMinTemp %the simulated annealing procedure from the highest temprature to the lowest temprature
    Temperature=exp(tmprtr);
    event=0;
    while event==0 %check whether the thinnig process is manipulated
        pbku=plcmnt;
        x=floor(rand*Lengthx)+1;y=floor(rand*Lengthy)+1;
        plcmnt(y,x)=mod(1+plcmnt(y,x),3);
        if ScoreTable(y,x)==0%check whether the xth element is removed;if yes,then hop the estimation;if not ,then do
            S0=zeros(size(u));S1=zeros(size(u));S2=zeros(size(u));
            for m=1:Lengthy
                for n=1:Lengthx
                    if (plcmnt(m,n)==0)
                        S0=S0+exp(i*k(1)*((n-1)*d*u+(m-1)*d*v));
                    elseif(plcmnt(m,n)==1)
                        S1=S1+exp(i*k(2)*((n-1)*d*u+(m-1)*d*v));
                    else
                        S2=S2+exp(i*k(3)*((n-1)*d*u+(m-1)*d*v));
                    end
                end
            end
            
            S0=abs(S0); S1=abs(S1); S2=abs(S2);
            S0=S0/max(max(S0));S1=S1/max(max(S1));S2=S2/max(max(S2));
            S0=20*log10(S0);S1=20*log10(S1);S2=20*log10(S2);
            %find the peak side lobe level
            for m=1:length(phi)
                for n=res+1:-1:2
                    if S0(n-1,m)<S0(n,m),brk0=n;end
                    if S1(n-1,m)<S1(n,m),brk1=n;end
                    if S2(n-1,m)<S2(n,m),brk2=n;end
                end
                BS0(m)=max(S0(brk0:res+1,m));
                BS1(m)=max(S1(brk1:res+1,m));
                BS2(m)=max(S2(brk2:res+1,m));
            end
            sc=max([BS0,BS1,BS2]);
            ScoreTable(y,x)=sc;
            ArraysTested=ArraysTested+1;%a thinned array is estimated
        end %the end of the check about whether the xth element is removed
        sc=ScoreTable(y,x);
        Score=alpha*sc*sc+beta;
        BestScore=alpha*bsc*bsc+beta;
        fprintf(1,'probability of change=%f\n',exp((BestScore-Score)*MagicConstant/Temperature));
        
        if sc<visc,visc=sc;vbarray=plcmnt;end
        if sc<bsc
            ScoreTable=zeros(Lengthy,Lengthx);
            ScoreTable(y,x)=bsc;
            bsc=sc;event=1;NoEventCount=0;
            fprintf(1,'improvement.\n');      
        elseif rand>exp((BestScore-Score)*MagicConstant/Temperature)
            plcmnt=pbku;
            fprintf(1,'retaining old placement.\n')
            NoEventCount=NoEventCount+1;
        elseif bsc<sc
            ScoreTable=zeros(Lengthy,Lengthx);
            ScoreTable(y,x)=bsc;
            bsc=sc;event=1;NoEventCount=0;
            fprintf(1,'Random change.\n');
        else
            fprintf(1,'No change.\n');
            event=1;
        end
        if NoEventCount>=FrozenTest,event=1;disp('Frozen');plcmnt=pbku;end
        if visc<=MinSideLobeLevel,bsc=visc;plcmnt=vbarray;event=1;end
        fprintf('%x',plcmnt);
        fprintf('\n');
        fprintf(1,'Score=%f\n',bsc);
        fprintf(1,'Lowest score=%f\n',visc);
        fprintf(1,'Temperature=%f\n\n',Temperature);
    end
end
fprintf(1,'\n\n');
fprintf(1,'%d arrays were tested.\n',ArraysTested);
if visc<bsc,plcmnt=vbarray;end

step=200;
theta=linspace(-pi/2,pi/2,step);
phi=linspace(0,pi,step);
u=sin(theta')*cos(phi);
v=sin(theta')*sin(phi);
S0=zeros(size(u));S1=zeros(size(u));S2=zeros(size(u));
for m=1:Lengthy
    for n=1:Lengthx
        if (plcmnt(m,n)==0)
            S0=S0+exp(i*k(1)*((n-1)*d*u+(m-1)*d*v));
        elseif(plcmnt(m,n)==1)
            S1=S1+exp(i*k(2)*((n-1)*d*u+(m-1)*d*v));
        else
            S2=S2+exp(i*k(3)*((n-1)*d*u+(m-1)*d*v));
        end
    end
end
S0=abs(S0); S1=abs(S1); S2=abs(S2);
S0=S0/max(max(S0));S1=S1/max(max(S1));S2=S2/max(max(S2));
S0=20*log10(S0);S1=20*log10(S1);S2=20*log10(S2);
figure(1);
for m=1:step
    plot(theta*180/pi,S0(:,m),'k');
    hold on;
end
axis([min(theta*180/pi),max(theta*180/pi),-50,0]);
figure(2);
for m=1:step
    plot(theta*180/pi,S1(:,m),'k');
    hold on;
end
axis([min(theta*180/pi),max(theta*180/pi),-50,0]);
figure(3);
for m=1:step
    plot(theta*180/pi,S2(:,m),'k');
    hold on;
end
axis([min(theta*180/pi),max(theta*180/pi),-50,0]);
plc=zeros(5*Lengthy,5*Lengthx);
for m=1:Lengthy
    for n=1:Lengthx
        plc(5*(m-1)+1:5*m,5*(n-1)+1:5*n)=plcmnt(m,n)*ones(5,5);
    end
end
figure(4);
imshow(flipud(plc/2));
% 10*10,mrsl=
%plcmnt=[0	1	0	2	2	1	2	1	2	0;0	0	1	0	1	0	1	1	0	2;1	1	2	1	0	2	0	2	1	1;
        %0	2	1	1	2	0	0	0	0	2;1	2	0	1	1	1	2	1	2	0;1	0	1	0	2	0	0	2	0	1;
        %2	1	2	1	1	1	1	0	2	2;2	0	2	2	0	2	2	2	1	0;1	0	1	1	0	1	2	1	1	1;1	2	2	2	2	0	2	0	2	1];
%plcmnt=1	2	0	2	1	1	0	2	0	1;2	2	2	2	2	0	1	0	1	0;2	2	2	1	1	2	2	0	0	0;
      % 2	1	2	2	0	0	1	2	0	2;1	2	0	0	1	2	0	0	1	0;0	1	1	2	2	1	1	2	0	1;
      % 1	2	2	1	0	2	0	0	2	2;2	1	1	1	2	1	0	1	0	0;0	1	2	1	0	0	0	2	1	1; 1	0	1	0	2	0	2	1	0	0];
