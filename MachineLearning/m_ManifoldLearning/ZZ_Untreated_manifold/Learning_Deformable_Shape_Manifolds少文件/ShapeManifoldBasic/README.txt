This code is distributed as is without warranty.  If you use this
for your research, please cite:
Learning deformable shape manifolds,
Samuel Rivera and Aleix M. Martinez, Pattern Recognition.
Volume 45, Issue 4, April 2012, Pages 1792-1801
See 'example.m'  for an example and the paramter explanation.
It basically sets up the parameters and calls 'mainDSREyeCenter.m'
This code assumes the objects are aligned in rotation.  If you would like to rotate
 the objects, you should detect the reference positions (eye positions for face) 
and rotate the images, then run the detector again on the whole face.  Or use the full version of the code.
This version is designed to be basic and modular so that you can make changes and 
incorporate it into other algorithms.
%   Copyright (C) 2009, 2010, 2011 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
%  Contact: Samuel Rivera (sriveravi@gmail.com)
�˴����Ƿֲ�ʽ�����ޡ�����������             ����о������ã�             ��������ѧϰ��             Samuel Rivera��Aleix M. Martinez��ģʽʶ��             45��4�ڣ�2012��4�£�ҳ1792-1801             �������ӡ�M��Ϊ�����ò����Ľ��͡�             �������ò�������֮Ϊ��M��maindsreyecenter��             �ô�����������һ�µ�����ת�����������ת             �Ķ�����Ҫ���Ĳο�λ�ã������۾���λ�ã�             ����תͼ��Ȼ������̽�����ٴζ�ȫ��������ʹ�������汾�Ĵ��롣             ����汾��רΪ����ģ�飬����������ı䣬             ����ϲ��������㷨�С�             ��Ȩ���У�C��Ϊ2009, 2010, 2011 Samuel Rivera�����Ƕ���Onur Hamsici��Paulo             % gotardo��Fabian Benitez Quiroz�ͼ�������ѧ��             ��֪��ѧʵ���ң�cbcsl��%��             ��ϵ�ˣ�Samuel Rivera��sriveravi@gmail.com��% 