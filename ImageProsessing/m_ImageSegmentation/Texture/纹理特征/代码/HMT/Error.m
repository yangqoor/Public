%参数的整个训练过程按照EM算法的基本过程来实现，终止条件有两个：两次迭代间的参数误
%差小于给定值epsilon=1e-5；最大迭代次数小于masiter=300.参数误差的计算通过函数
%error_H来进行。
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