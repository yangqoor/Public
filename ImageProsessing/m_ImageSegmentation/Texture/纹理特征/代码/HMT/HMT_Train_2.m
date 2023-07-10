function [imPara] = HMT_Train_2(f,L)
% 初始化
imPara = Initialization(f,L);
% HMT训练
P = repmat(struct('P1',[],'P2',[]),[L,1]);
maxiter = 300;epsilon = 1e-5;iter = 0;err = Inf;%迭代次数？ epsilon=10^(-5)

P=Expectation(f,imPara,P);%EM算法 E
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