function tikhpls(n,A,u0,alfa,NOM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  hx=1/(n-1);hy=hx;
  AF = ext2d(A,2*n);B=AF./ (abs(AF).^2 + alfa/hx/hy);
  z= conv2d(u0,conj(B));o=2*pi*[n-1:-1:0]./n;[ox,oy]=meshgrid(o,o);
  om=ox.^2+oy.^2;om2=[fliplr(om) om ];om1=[flipud(om2);om2];
  B=AF./ (abs(AF).^2 + alfa/hx/hy*(1+om1));
  z1= conv2d(u0,conj(B));
  B=AF./ (abs(AF).^2 + alfa/hx/hy*(1+om1.^2));
  z2= conv2d(u0,conj(B));
  z=0.5*(z+abs(z));z1=0.5*(z1+abs(z1));z2=0.5*(z2+abs(z2));
  %save varinter.mat z z1 z2;% Для дальнейших расчетов
%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(NOM);subplot(2,2,1);imagesc(u0);axis square;
set(gca,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
title('Исходные данные');colorbar
subplot(2,2,2);imagesc(z);axis square;
set(gca,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
title('Тихоновское решение в L_2+');colorbar
subplot(2,2,3);imagesc(z1);axis square;
set(gca,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
title('Тихоновское решение в W_2^1+');colorbar
subplot(2,2,4);imagesc(z2);axis square;
set(gca,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
title('Тихоновское решение в W_2^2+');colorbar
set(gcf,'Name',' Решения','NumberTitle','off')
%%%%%%%%%%%%%%%%%%%%%%%%%%%
  nru=norm(u0,2);u=conv2d(z,AF);nevL2=norm(u-u0,2)/nru;
  u=conv2d(z1,AF);nevW12=norm(u-u0,2)/nru;
  u=conv2d(z2,AF);nevW22=norm(u-u0,2)/nru;
  disp([' Ошибка решения в пространстве L_2 (%)= ' num2str(nevL2)]);  
  disp([' Ошибка решения в пространстве W_2^1 (%) = ' num2str(nevW12)]);  
  disp([' Ошибка решения в пространстве W_2^2 (%) = ' num2str(nevW22)]); 
  disp(' ');

