%����������ѵ�����̰���EM�㷨�Ļ���������ʵ�֣���ֹ���������������ε�����Ĳ�����
%��С�ڸ���ֵepsilon=1e-5������������С��masiter=300.�������ļ���ͨ������
%error_H�����С�
function [err]=Error(imPara,imParaN)
L=size(imPara,1);
err=0.0;
for n=1:L
    es=imPara(n).es;
    esn=imParaN(n).es;
    ps=imPara(n).ps;
    psn=imParaN(n).ps;
    si=imPara(n).si;
    sin=imParaN(n).si;
    u=imPara(n).u;
    un=imParaN(n).u;
    Band=size(si,1);
    err=err+sum(sum(abs(es-esn)));
    err=err+sum(abs(ps-psn));
    err=err+sum(sum(abs(si(:,:,1)-sin(:,:,1))))/(Band*Band);
    err=err+sum(sum(abs(si(:,:,2)-sin(:,:,2))))/(Band*Band);
    %         err=err+(abs(det(si(:,:,2))-det(sin(:,:,2))))^(1/4);
    err=err+sum(sum(sum(abs(u-un))));
    %         sum(sum(abs(es-esn)))
    %         sum(abs(ps-psn))
    %         (abs(det(si(:,:,1))-det(sin(:,:,1))))^(1/4)
    %         (abs(det(si(:,:,2))-det(sin(:,:,2))))^(1/4)
    %         sum(sum(sum(abs(u-un))))
end
end