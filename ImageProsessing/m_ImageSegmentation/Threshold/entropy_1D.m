%   一维直方图最大熵法
function [th,segImg] = entropy_1D(cX,map)
    vHist=imhist(cX,map);
    [m,n]=size(cX);
%     p=vHist/(m*n);	 	%求各个灰度出现的概率
    p=vHist(find(vHist>0))/(m*n);   %求每一不为零的灰度值的概率
    Pt=cumsum(p);			%计算出选择不同ｔ值时,A区域的概率
    Ht=-cumsum(p.*log(p));	%计算出选择不同ｔ值时,A区域的熵
	HL=-sum(p.*log(p));		%计算出全图的熵
	Yt=log(Pt.*(1-Pt))+Ht./Pt+(HL-Ht)./(1-Pt);%计算出选择不同ｔ值时,判别函数的值
	[ans,th]=max(Yt);		%th即为最佳阈值
    segImg=(cX>th);
