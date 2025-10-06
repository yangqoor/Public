% 对chatGPT:
% 使用matlab构造一组数据，为2018第一天到2024年最后一天的数据，要求具有季节性

clc;clear
% 创建日期向量
t = datetime(2018,1,1):days(1):datetime(2024,12,31);
n = length(t);

% 将日期转换为一年中的位置（1 到 365/366）
day_of_year = day(t, 'dayofyear');
year_length = year(t);  % 判断闰年时有用
is_leap = eomday(year(t),2) == 29;

% 构造季节性数据：例如正弦函数，每年重复一次（周期365）
% 基本模式：sin(2*pi * day_of_year / 365)
% 添加噪声 + 趋势（可选）
seasonal = 10 * sin(2*pi * day_of_year ./ 365);   % 季节性（年周期）
noise = randn(1, n).*5;                           % 噪声
trend = 0.01 * (1:n);                             % 微小上升趋势

% 最终数据
v = seasonal + noise + trend;

% 可视化
plot(t, v)
xlabel('Date')
ylabel('Value')
title('Synthetic Seasonal Data (2018–2024)')

Data.t = t;
Data.v = v;
save test.mat Data
