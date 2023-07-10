% 
% Copyright (C) 2009, 2010 Samuel Rivera, Liya Ding, Onur Hamsici, Paulo
%   Gotardo, Fabian Benitez-Quiroz and the Computational Biology and 
%   Cognitive Science Lab (CBCSL).
% 
% Contact: Samuel Rivera (sriveravi@gmail.com)


index = 1;


for i2 = 1:size(coordinateMatrix,1)
   x = double(round( [ real(coordinateMatrix(i2,index)), imag(coordinateMatrix(i2,index)) ] ));
    hold on
   text( x(1), x(2), int2str(i2), 'color', 'black');  
end

set( gca, 'ydir', 'reverse');
axis( [min(min(real(coordinateMatrix))) max(max(real(coordinateMatrix))) min(min(imag(coordinateMatrix))) max(max(imag(coordinateMatrix)))] );

