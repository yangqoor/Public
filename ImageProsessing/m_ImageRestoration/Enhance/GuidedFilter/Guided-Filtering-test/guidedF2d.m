%{
	Guided filtering
	Para:
		P: input image to be filtered
		I: guided image
		r: 2r+1 represents window size
		e: critial value of smoothing or enhancement
%}

function [ Q ] = guidedF2d( P, I, r, e )

P = padding(P, r);
I = padding(I, r);
[pRow, pCol] = size(P);
Q = zeros(pRow, pCol);

%% Compute coefficients for each area w
a = zeros(pRow, pCol);
b = zeros(pRow, pCol);

parfor i = r+1 : pRow-r
	for j = r+1 : pCol-r
		% get current window
		wP = P(i-r:i+r, j-r:j+r);
		wI = I(i-r:i+r, j-r:j+r);
		% culculate mean and var
		mP = mean2(wP);
		mI = mean2(wI);
		vI = std2(wI)^2;
		% calculate coefficients for each pixel
		a(i, j) = (mean2(wI.*wP) - mI*mP) / (vI+e);
		b(i, j) = mP - a(i, j) * mI;
	end
end
%%

%% Compute output Image
for i = r+1 : pRow-r
	for j = r+1 : pCol-r
		% compute mean for a and b cause of several computation
		ma = mean2(a(i-r:i+r, j-r:j+r));
		mb = mean2(b(i-r:i+r, j-r:j+r));
		% compute gray level
        value = ma .* I(i-r:i+r, j-r:j+r) + mb;
        value = max(value, 0);
        value = min(value, 255);
		Q(i-r:i+r, j-r:j+r) = value;
	end
end
%%

Q = rePadding(Q, r);

end

