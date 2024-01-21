function im=flat3DArray(arr,n)
arr=reshape(arr,size(arr,1),size(arr,2),size(arr,3)*size(arr,4));
tim=reshape(arr,size(arr,1),size(arr,2)*size(arr,3));
si=ceil(size(arr,3)/n);

arr(:,:,size(arr,3)+1:si*n)=0;



tim=reshape(arr,size(arr,1),size(arr,2)*size(arr,3));

si=ceil(size(tim,2)/n);

im=[];
for i=1:n
   im=[im;tim(:,si*(i-1)+1:si*i)];
end
