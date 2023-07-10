% demo 3
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
X1=randi([1,500],[100,1]);
X2=randi([1,500],[100,1]);
X3=randi([1,500],[100,1]);
X4=randi([1,500],[100,1]);
X5=randi([1,500],[100,1]);
X6=randi([1,500],[100,1]);
X7=randi([1,500],[100,1]);
XX={X1,X2,X3,X4,X5,X6,X7};


VN=venn(XX{1:7});
VN=VN.labels('AAA','BBB','CCC','DDD','EEE','FFF','GGG');
VN=VN.draw();

colorList=[78 101 155;
          138 140 191;
          184 168 207;
          231 188 198;
          253 207 158;
          239 164 132;
          182 118 108]./255;
for i=1:7
    VN.setPatchN(i,'FaceColor',colorList(i,:),'EdgeColor',colorList(i,:))
end