%{
	Guided filtering for color image
	Process each coverage respecively
	Para:
		P: input image to be filtered
		I: guided image
		r: 2r+1 represents window size
		e: critial value of smoothing or enhancement
%}

%%
function [ Q ] = guidedF3d( P, I, r, e )

Q(:, :, 1) = guidedF2d(P(:, :, 1), I(:, :, 1), r, e);
Q(:, :, 2) = guidedF2d(P(:, :, 2), I(:, :, 2), r, e);
Q(:, :, 3) = guidedF2d(P(:, :, 3), I(:, :, 3), r, e);

end
%%

