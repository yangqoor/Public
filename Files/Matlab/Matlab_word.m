
clc
clear
f = [pwd '\测试.docx'];% pwd 用于当前工作目录的路径
try    
    Word = actxGetRunningServer('Word.Application');  %启动word引擎
catch    
    Word = actxserver('Word.Application'); 
end
Word.Visible = 1;    % 或set(Word, 'Visible', 1);   %设置可见
if exist(f,'file')    %测试文件存在的话
    Document = Word.Documents.Open(f);      %获得文档的对象Document
else                %不存在则创建添加
    Document = Word.Documents.Add;       
    Document.SaveAs(f);        %保存文档
end
Selection = Word.Selection;               %光标所在处
Selection.Start=0;
a=[];
num=Document.Range.end;
ii=0;
while ii<=num
    ii=ii+1;
    a=[a,Selection.text];
    Selection.MoveRight;     %光标向右移动一格
end
a=a(1:num)             %取文本有内容的部分，也许由于汉字占有两个字节，所以一般读取后a的长度都是文本长度的两倍左右。
