function patches = im2patches2(im,m,n)
%     assert(rem(size(im,1),m)==0)
%     assert(rem(size(im,2),n)==0)
    
    patches = [];
    for i=1:m:size(im,1)-m
        for u=1:n:size(im,2)-n
             patch = im(i:i+m-1,u:u+n-1);
             patches = [patches patch(:)];
        end
    end
    patches = patches';
end