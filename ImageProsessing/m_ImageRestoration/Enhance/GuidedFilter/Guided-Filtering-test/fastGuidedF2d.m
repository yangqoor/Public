%{
	An optimization of guided filter:
	Sampling by step s in the filtering window
	Para:
		P: input image to be filtered
		I: guided image
		r: 2r+1 represents window size
		e: critial value of smoothing or enhancement
		s: step length of sampling
%}

function [ Q ] = fastGuidedF2d( P, I, r, e, s )

P = padding(P, r);
I = padding(I, r);
[pRow, pCol] = size(P);
Q = zeros(pRow, pCol);

%% Compute coefficients for each area w
a = zeros(pRow, pCol);
b = zeros(pRow, pCol);

wNum = (2*r+1)^2;
parfor i = r+1 : pRow-r
	for j = r+1 : pCol-r
		% get current window and reshape to vector
		wP = P(i-r:i+r, j-r:j+r); wP = wP'; wP = wP(:);
		wI = I(i-r:i+r, j-r:j+r); wI = wI'; wI = wI(:);
		% sample pixels to culculate mean and var
		sampleP = []; sampleI = [];
        index = 1;
		for k = 1 : s : wNum
				sampleP(index) = wP(k);
				sampleI(index) = wI(k);
                index = index + 1;
		end
		% calculate mean and var
		mP = mean(sampleP);
		mI = mean(sampleI);
        vI = std(sampleI)^2;
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

