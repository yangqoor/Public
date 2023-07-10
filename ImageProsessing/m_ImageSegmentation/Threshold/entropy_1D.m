%   һάֱ��ͼ����ط�
function [th,segImg] = entropy_1D(cX,map)
    vHist=imhist(cX,map);
    [m,n]=size(cX);
%     p=vHist/(m*n);	 	%������Ҷȳ��ֵĸ���
    p=vHist(find(vHist>0))/(m*n);   %��ÿһ��Ϊ��ĻҶ�ֵ�ĸ���
    Pt=cumsum(p);			%�����ѡ��ͬ��ֵʱ,A����ĸ���
    Ht=-cumsum(p.*log(p));	%�����ѡ��ͬ��ֵʱ,A�������
	HL=-sum(p.*log(p));		%�����ȫͼ����
	Yt=log(Pt.*(1-Pt))+Ht./Pt+(HL-Ht)./(1-Pt);%�����ѡ��ͬ��ֵʱ,�б�����ֵ
	[ans,th]=max(Yt);		%th��Ϊ�����ֵ
    segImg=(cX>th);
