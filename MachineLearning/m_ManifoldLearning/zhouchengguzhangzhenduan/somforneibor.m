% clear all;
% close all;
% %% SOM for graduate %% load swissroll
function [mappedX,M,conn] = somforneibor(X,k,d)

speed_up = 1; 
[N,D] = size(X);
f  = 1;  
% --> f is width of neighborhood function (neurons are one unit separated)
if d==1;        
    gr = [1:k]';
elseif d > 1;
    [x,y]=meshgrid(1:k,1:k);  
    gr = [ x(:) y(:)];  
end
%% ��ά���ֵ 1,1 1,2 1,3 2,1 ,2,2 ,2,3 3,1, 3,2 ,3,3


%%������ڵ������distance
dd = L2_distance(gr',gr') ;
H = exp(-dd/(2*(f*k)^2)) ; %%ͳ�Ƹ���ķֲ��ʣ�����Խ����HԽ��
k = size(gr,1);
H  = H ./repmat(sum(H,1),k,1); %%%��һ��
conn =  (dd<=1); %%���Ӿ��� ��������
entr = sum(-H.*log(H+realmin),1); %% -exp(x) * x  ÿһ��ľ�����ֵ֮��

%��ʼ����Ԫ
W = floor (rand(N,1)*k) + 1; %%��H�����ѡ��Ȩֵ���
q = H(:,W); %% q  k2�� N ��  
M = diag(sum(q,2).^-1) * q * X ; 
sd = L2_distance(X',M') ;%% ���� ���е㵽��ʼȨ�ľ���
SigmaS = mean(min(sd,[],2)); % ÿһ���㵽���г�ʼȨ����С�ľ��룬�����ֵ
%��ʼ������
iter = 0 ;
old_obj  = -sum(sd.*q',2)/(2*SigmaS)+ entr(W)' - D*log(SigmaS)/2;
F = [0]; first_bunch = 1 ;rate = 1.1; 
% fig = figure; aviobj = avifile('S����1.avi','compression','none');
while H(1,1) < .9999
    iter = iter +1 ;
    %����
    N = length(W) ;
    [tmp , order] = min(sd,[],2); 
    J = find(order~=W);
    order = order(J);%�ҳ����е�Գ�ʼȨֵ�ľ�������С�ĵ㲻��W�ĵ� 
    tmp_obj=  -sum(sd(J,:) .* H(:,order)',2) / (2*SigmaS) +entr(order)'-D*log(SigmaS)/2;
  %old_obj  = -sum(sd.*q',2)/(2*SigmaS)+ entr(W)' - D*log(SigmaS)/2; ����󣿣�
    I  = find( tmp_obj >= old_obj(J) );
     obj = old_obj ; 
     obj(J(I)) = tmp_obj(I);
    W(J(I))   = order(I); %%  W�ı�
   
    if abs(sum(obj)/sum(old_obj)-1)<1e-5; 
            H    = H.^rate;    % --> �������� nh-function rate = 1.1
            H    = H./repmat(sum(H),k,1)+realmin;
           entr = -sum(H.*log(H+realmin),1);fprintf('|');
            q    = H(:,W);
            obj  = -sum(sd.*q',2)/(2*SigmaS)+ entr(W)' - D*log(SigmaS)/2;
            F    = [F; -sum(obj)];  
    end
      %%�����ʤ��Ԫ
      q = H(:,W); % q �ı�
     %���� M, sigmaS, sd, obj 
       M = diag(sum(q,2).^-1)*  q * X ;
       sd  = sqdist(X',M');
       SigmaS = sum(sum(sd'.*q))/(D*N);       
       if first_bunch & length(F)>2;
          F=F(2:end) ;
          first_bunch=0;
      end  % throw away first two values of F (possibly very high) since they may screw-up the plot
       %%��ͼ
  plot_it(X,M,1*sqrt(SigmaS),conn); 
  %%���ɶ���
%   MM = getframe(fig);aviobj = addframe(aviobj,MM);
  old_obj = obj ;
end
%    aviobj = close(aviobj);
disp('construct the neigbor matrix...');
  neigbor = neigborselect(X,M,conn,d);
  disp('som ltsa ...');
  mappedX = somltsa(X,d,neigbor,'JDQR');
  disp('finished');
figure;
plot(mappedX(:,1),mappedX(:,2),'.');title('�����νṹ');

 