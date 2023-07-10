function sakura
hold on,axis equal
axis(0.5+[-10,50,0,50])
set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w')
set(gca,'color',[0.5020    0.5020    0.5020])

length_trunk=6;
width_trunk=4;
k1=0.9;
k2=0.8;
number_branch=15;
alp=pi/10;
length_branch=k1*length_trunk;
width_branch=k2*width_trunk;
trunk=[12,0;12,length_trunk];
plot(trunk(:,1),trunk(:,2),'color',[0 0 0],'Linewidth',width_trunk)
begins=[trunk(2,:),pi/2,1];
grow=begins;
plotdata=[0 0 0 0 0 0 0 0];
plotdata(1,:)=[];
for i=1:number_branch
    control=randi(25,[length(grow(:,1)),1])>=10;
    ag=grow(:,3);
    l=length(ag);
    parta=[length_branch.*k1.^grow(:,4).*cos(ag+ones(l,1)*alp),length_branch.*k1.^grow(:,4).*sin(ag+ones(l,1)*alp),ones(l,1)*alp,ones(l,1)];
    partb=[length_branch.*k1.^grow(:,4).*cos(ag-ones(l,1)*alp),length_branch.*k1.^grow(:,4).*sin(ag-ones(l,1)*alp),-ones(l,1)*alp,ones(l,1)];
    parta2=[0.8.*length_branch.*k1.^grow(:,4).*cos(ag),0.8.*length_branch.*k1.^grow(:,4).*sin(ag),zeros(l,1),ones(l,1)];
    partb2=[0.8.*length_branch.*k1.^grow(:,4).*cos(ag),0.8.*length_branch.*k1.^grow(:,4).*sin(ag),zeros(l,1),ones(l,1)];
    parta=control.*parta+(~control).*parta2;
    partb=control.*partb+(~control).*partb2;
    parta=parta+grow;
    partb=partb+grow;
    congress=[parta;partb];
    grow=[grow;grow];
    judge=[grow,congress];
    judge=unique(judge,'rows');
    grow=judge(:,5:end);
    plotdata=[plotdata;judge];
end
for i=1:number_branch
    temp_w=width_branch*0.8^i;
    temp_branch=plotdata(plotdata(:,4)==i,:);
    plx=[temp_branch(:,1),temp_branch(:,5)];
    ply=[temp_branch(:,2),temp_branch(:,6)];
    plx=plx';ply=ply';
    plot(plx,ply,'color',[0 0 0]+i*[0.3020 0.3020 0.3020]./number_branch,'Linewidth',temp_w)
end

bloom_pos=plotdata(plotdata(:,8)==number_branch+1,[5,6]);
scatter(bloom_pos(:,1),bloom_pos(:,2),10,'CData',[0.8549    0.6824    0.6824])
bloom_pos=plotdata(plotdata(:,8)==number_branch,[5,6]);
scatter(bloom_pos(:,1),bloom_pos(:,2),8,'CData',[0.7451    0.5961    0.5961].*0.97)




end
