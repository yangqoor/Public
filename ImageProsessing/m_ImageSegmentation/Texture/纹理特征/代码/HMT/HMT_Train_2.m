function [imPara] = HMT_Train_2(f,L)
% ��ʼ��
imPara = Initialization(f,L);
% HMTѵ��
P = repmat(struct('P1',[],'P2',[]),[L,1]);
maxiter = 300;epsilon = 1e-5;iter = 0;err = Inf;%���������� epsilon=10^(-5)

P=Expectation(f,imPara,P);%EM�㷨 E
[imParaN]=Maximization(f,P,imPara);% M
err1=Error(imPara,imParaN);
while(iter<maxiter)&&(err>epsilon)
    P=Expectation(f,imPara,P);
    [imParaN]=Maximization(f,P,imPara);
    err=Error(imPara,imParaN);
    imPara=imParaN;
%     iter=iter+1;
%     
%    rate = (err1-err)/(err1-epsilon);
%     if whichone == 0
%         whichone = 'query';
%     else
%         whichone = num2str(whichone);
%     end
%     waitbar(rate,hWaitbar,['Training the model(' whichone ')' num2str(rate*100) '%']);
    
end
%disp(num2str(iter));

% if ishandle(hWaitbar)
%     delete(hWaitbar)
%     clear hWaitbar
% end

end