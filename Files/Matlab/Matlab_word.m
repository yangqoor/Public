
clc
clear
f = [pwd '\����.docx'];% pwd ���ڵ�ǰ����Ŀ¼��·��
try    
    Word = actxGetRunningServer('Word.Application');  %����word����
catch    
    Word = actxserver('Word.Application'); 
end
Word.Visible = 1;    % ��set(Word, 'Visible', 1);   %���ÿɼ�
if exist(f,'file')    %�����ļ����ڵĻ�
    Document = Word.Documents.Open(f);      %����ĵ��Ķ���Document
else                %�������򴴽�����
    Document = Word.Documents.Add;       
    Document.SaveAs(f);        %�����ĵ�
end
Selection = Word.Selection;               %������ڴ�
Selection.Start=0;
a=[];
num=Document.Range.end;
ii=0;
while ii<=num
    ii=ii+1;
    a=[a,Selection.text];
    Selection.MoveRight;     %��������ƶ�һ��
end
a=a(1:num)             %ȡ�ı������ݵĲ��֣�Ҳ�����ں���ռ�������ֽڣ�����һ���ȡ��a�ĳ��ȶ����ı����ȵ��������ҡ�
