function prob=filt_y(prob)
    if ~prob.filt_space
        return
    end
    prob.filty=[];
    ind=0;
    for j=1:size(prob.filts,3)
       for i=1:size(prob.y,3)
          ind=ind+1; 
          prob.filty(:,:,ind)=conv2(prob.y(:,:,i),prob.filts(:,:,j),'valid');
       end
    end