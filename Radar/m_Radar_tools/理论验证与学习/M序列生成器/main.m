%--------------------------------------------------------------------------
%   初始化
%--------------------------------------------------------------------------
clear;clc;

%--------------------------------------------------------------------------
%   m序列反馈系数表
%--------------------------------------------------------------------------
%   级数N     周期P         反馈系数(八进制)
%--------------------------------------------------------------------------
%   3           7           13
%   4           15          23
%   5           31          45 67 75
%   6           63          103 147 155
%   7           127         203 211 217 235 277 313 325 345
%   8           255         435 453 537 543 545 551 703 747
%   9           511         1021 1055 1131 1157 1167 1175
%   10          1023        2011 2033 2157 2443 2745 3471
%   11          2047        4005 4445 5023 5263 6211 7363
%   12          4095        10123 11417 12515 13505 14127 15053
%   13          8191        20033 23261 24633 30741 32535 37505
%   14          16383       42103 51761 55753 60153 71147 67401
%   15          32765       10003 110013 120265 133663 142305
%--------------------------------------------------------------------------
[seq] = mseq([1 1 0 1])