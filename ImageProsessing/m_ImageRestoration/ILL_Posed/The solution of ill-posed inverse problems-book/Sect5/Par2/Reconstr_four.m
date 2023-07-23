%  Reconstr_four
clear all;close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ������������� ����������� � ������� ������������ ��������� � �������������
%  �������� � ������. ����������: �������������� ����� + �������������� �� ����� 
%  ��������������� �������. �������� ������������� -- ������������.

disp(' ');disp(' ������������� ����������� � ������� ������������ ���������');
disp(' � ������������� �������� � ������ � ��������������� �� R_{+}.');
disp('       �������� ����� -- ��. �.250 - 251');
disp(' ');

%disp(' ');
num_zad=input('     ������� ����� ������ (1 -- 3):  ');disp(' ');
if isempty(num_zad)|abs((num_zad-2))>1;
    disp('     ����� ��������. ��������� ����!');return;end

if num_zad==2;% �������
   load model1;
   n=min(size(M1));A=M1(1:n,1:n);alfa=1e-8;
   u=M1(n+1:2*n,1:n);
   figure(1);h1=subplot(2,2,1);imagesc(A);
   set(h1,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   axis square;title('����')
   h2=subplot(2,2,2);imagesc(u);axis square;
   set(h2,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   title('������ �����')
   title('������ �����');set(gcf,'Name',' ������ ������','NumberTitle','off')
elseif num_zad==1;% EL
   num_podzad=input('     delta=1.5% (1) ��� delta=8.5% (2)?:  ');disp(' ');
   if num_podzad==1;load model2;alfa=3e-8;else load datAuEL;alfa=5e-7;end;
   n=min(size(M1));A=M1(1:n,1:n);
   u=M1(n+1:2*n,1:n);
   figure(1);h1=subplot(2,2,1);imagesc(A);
   set(h1,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   axis square;title('����')
   h2=subplot(2,2,2);imagesc(u);axis square;
   set(h2,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   title('������ �����');set(gcf,'Name',' ������ ������','NumberTitle','off')
else
   load datAu;%  ����� ���������
   n=min(size(M1));A=M1(1:n,1:n);alfa=0.05;
   u=M1(n+1:2*n,1:n);
   figure(1);h1=subplot(2,2,1);imagesc(A);
   set(h1,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   axis square;title('����')
   h2=subplot(2,2,2);imagesc(u);axis square;
   set(h2,'XTickLabel',[],'YTickLabel',[],'FontName',FntNm);
   title('������ �����')
   title('������ �����');set(gcf,'Name',' ������ ������','NumberTitle','off')
end        


%disp('    ');disp(' ');
disp('    ������ ������� �� ��������� ������� �������:');disp(' ');
tikhpls(n,A,u,alfa,2);         
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%  ����� ������������  %%%%%%%%%%%%%%%%%%%%%%%%%%%');
%disp(' ');disp(' ');