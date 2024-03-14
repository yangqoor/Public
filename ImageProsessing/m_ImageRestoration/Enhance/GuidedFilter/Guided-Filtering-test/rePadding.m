%{
	Repadding the image from a padded one
	Para:
		in: input image to be repadded
		len: length of pixels to remove at one edge
%}

%%
function [ out ] = rePadding( in, len )

[Row, Col] = size(in);
out = zeros(Row-2*len, Col-2*len);

for i = 1 : Row-2*len
	for j = 1: Col-2*len
		out(i, j) = in(i+len, j+len);
	end
end

end
%%

