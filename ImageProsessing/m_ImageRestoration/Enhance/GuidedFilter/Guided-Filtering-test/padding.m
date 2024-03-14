%{
	Padding around the image by 0 gray level
	Para:
		in: input image to be padded
		len: length of pixels to add at one edge
%}

%%
function [ out ] = padding( in, len )

[Row, Col] = size(in);
out = zeros(Row+2*len, Col+2*len);

for i = len+1 : Row+len
	for j = len+1 : Col+len
		out(i, j) = in(i-len, j-len);
	end
end

end
%%

