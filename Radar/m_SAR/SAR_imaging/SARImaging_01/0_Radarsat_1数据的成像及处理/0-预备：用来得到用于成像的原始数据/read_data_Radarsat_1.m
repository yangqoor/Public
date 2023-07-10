%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                   �������������е�����
%               ���ɿ���ֱ�����ڳ����ԭʼ����
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������  read_data_Radarsat_1.m
% �ó����Ŀ�ģ� 
%   ���������ӹ����ж������ݣ�
%   ���������±�Ƶ�õ��������źţ���ת���ɵ����ȸ�������
%   ��������AGC���油����
%   ���������ת��Ϊ˫���ȸ�����
%   �����õ����ǿ���ֱ�����ڳ����ԭʼ���ݣ���Ϊdata��   
% 
% ���ڵõ������ݵ�˵����
%   ���У� b = 1���Ǵӷ���1�������ݣ����Ǽ�Ϊ data_1
%          b = 2���Ǵӷ���2�������ݣ����Ǽ�Ϊ data_2
% 	���� data_1 �� data_2 �����ǿ��Էֱ�õ������������ĳ�������
% 	���⣬�����Խ� data_1 �� data_2 �ϲ�Ϊһ����������ݣ��õ���������ĳ�������
%   
% ����ĳ�����ǵõ����������� data_1 �� data_2��
%
% read_data_Radarsat_1.m
% ----------------------------------------------------------
% ʹ���ֳɵĳ���compute.azim.spectra.m���ж������ݵķ�����
% ���ú��� 'load_DATA_block.m'��ʵ��
%                - reads /loads data for a block 
%                - converts to floating point
%                - compansates for the receiver attenuation
% ���� b -- ��Ҫ��������ȡ���ĸ�����
%                - b = 1 , from CDdata1
%                - b = 2 , from CDdata2
% �õ�����Ҫ�����ݣ�Ҳ������ֱ�ӽ��к��� processing ������ data��
% ----------------------------------------------------------
%
% �ó����޸ģ���ֹ���� 2014.10.10.  14:51 p.m.

%%
% ----------------------------------------------------------
% �õ����Խ��к����źŴ����ԭʼ����data��s_echo��
% ----------------------------------------------------------
%  Load the parameters for this run
clear;
clc;
close all;
format compact
set( 0, 'DefaultTextFontSize',   12 )  % Plotting defaults
set( 0, 'DefaultLineLineWidth', 1.5 )
set( 0, 'DefaultAxesFontSize',    8 )
tfs = 13;    lfs = 11;
load CD_run_params

% ����b��ֵ�� 1����2 �������ǿ��Էֱ�õ���һ�������ߵڶ����������ݡ�
b = 1;                      % ��һ��������ȡ�� CDdata1 ���ݡ�

file_pre = strcat( output_path, output_prefix, '_', num2str(b) );   
disp ' '
disp (['Load or Extract AGC setting and Data for block ' num2str(b) ])
%  Load a block of 'AGC_values'
AGC_values = load_AGC_block( file_pre, first_rg_line, ...
                                      Nrg_lines_blk, b , UseMATfiles );                                     
%  Load a block of raw SAR data
data = load_DATA_block( file_pre, output_path, Nrg_lines_blk, ...
                           Nrg_cells, AGC_values, b, UseMATfiles );
% ��ʱ�õ��� data �Ǿ����±�Ƶ�Ļ������źţ����Ѿ�ת���ɵ����ȸ�������Ҳ������AGC���油����
data = double(data);    % �ٽ�dataת����˫���ȸ����������ڽ��к����źŴ���
% ��ʱ�����ǾͿɵõ��˿���ֱ�����ں��������ԭʼ���ݣ�data

% ��ͼ��ʾ
figure;
imagesc(abs(data));
title('ԭʼ����');     	% ԭʼ�ز����ݣ�δ�����ķ���ͼ��
% colormap(gray);




