function Retinex = retinex_frankle_mccann(L, nIterations)

global RR IP OP NP Maximum
RR = L;
Maximum = max(L(:));                                 % maximum color value in the image
[nrows, ncols] = size(L);

shift = 2^(fix(log2(min(nrows, ncols)))-1);          % initial shift
OP = Maximum*ones(nrows, ncols);                     % initialize Old Product

while (abs(shift) >= 1)
   for i = 1:nIterations
      CompareWith(0, shift);                         % horizontal step
      CompareWith(shift, 0);                         % vertical step
   end
   shift = -shift/2;                                 % update the shift
end
Retinex = NP;

function CompareWith(s_row, s_col)
global RR IP OP NP Maximum
IP = OP;
if (s_row + s_col > 0)
   IP((s_row+1):end, (s_col+1):end) = OP(1:(end-s_row), 1:(end-s_col)) + ...
   RR((s_row+1):end, (s_col+1):end) - RR(1:(end-s_row), 1:(end-s_col));
else
   IP(1:(end+s_row), 1:(end+s_col)) = OP((1-s_row):end, (1-s_col):end) + ...
   RR(1:(end+s_row),1:(end+s_col)) - RR((1-s_row):end, (1-s_col):end);
end
IP(IP > Maximum) = Maximum;                          % The Reset operation
NP = (IP + OP)/2;                                    % average with the previous Old Product
OP = NP;                                             % get ready for the next comparison
