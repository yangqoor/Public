% clc,clear all
% t = tcpclient('www.mathworks.com', 80)
% t = tcpclient('172.28.154.231', 4012, 'Timeout', 20)
t1 = tcpclient('localhost', 60000)

% Create a variable called data
data = uint8(1:10);
% Write the data to the object t
write(t1, data)
read(t1)

A = char(read(t1))
A(end)
%%
t2 = tcpip('192.168.0.105', 60000,'NetworkRole','client','Timeout', 2)
fopen(t2)
% fwrite(t2,65:74)
A = char(fread(t2))
fclose(t2)
% echotcpip("¹Ø±Õ")