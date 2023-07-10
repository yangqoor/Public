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
此代码是分布式不保修。如果你用这个             你的研究请引用：             变形流形学习，             Samuel Rivera和Aleix M. Martinez，模式识别。             45卷，4期，2012年4月，页1792-1801             见的例子。M”为例，该参数的解释。             基本设置参数，称之为“M”maindsreyecenter。             该代码假设对象是一致的在旋转。如果你想旋转             的对象，你要检测的参考位置（人脸眼睛的位置）             和旋转图像，然后运行探测器再次对全脸。或者使用完整版本的代码。             这个版本是专为基本模块，你可以做出改变，             将其合并到其他算法中。             版权所有（C）为2009, 2010, 2011 Samuel Rivera，李亚丁，Onur Hamsici，Paulo             % gotardo、Fabian Benitez Quiroz和计算生物学和             认知科学实验室（cbcsl）%。             联系人：Samuel Rivera（sriveravi@gmail.com）% 