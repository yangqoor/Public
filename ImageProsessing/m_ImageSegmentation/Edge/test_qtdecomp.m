% 四叉树分解
I = [1  1  1  1  2  3  6  6
     1  1  2  1  4  5  6  8
     1  1  1  1  10 15 7  7
     1  1  1  1  20 25 7  7
     20 22 20 22 1  2  3  4
     20 22 22 20 5  6  7  8
     20 22 20 20 9  10 11 12
     22 22 20 20 13 14 15 16];
S = qtdecomp(I, 5);
full(S)

I = imread('liftingbody.png');
S = qtdecomp(I,.27);
blocks = repmat(uint8(0),size(S));

for dim = [512 256 128 64 32 16 8 4 2 1]    
  numblocks = length(find(S==dim));    
  if (numblocks > 0)        
    values = repmat(uint8(1),[dim dim numblocks]);
    values(2:dim,2:dim,:) = 0;
    blocks = qtsetblk(blocks,S,dim,values);
  end
end

blocks(end,1:end) = 1;
blocks(1:end,end) = 1;

imshow(I)
figure
imshow(blocks,[])
