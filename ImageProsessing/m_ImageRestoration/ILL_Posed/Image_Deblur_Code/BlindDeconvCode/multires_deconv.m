function [prob,kListItr]=multires_deconv(prob,ret,sig_noise_v,dispOn,outname)

if (exist('outname','var')&(~isempty(outname)))
    writeOn=1;
else
    writeOn=0;
end


k1=prob.k_sz1; k2=prob.k_sz2; 
%choose number of pyramid layers
maxitr=max(floor(log(5/min(k1,k2))/log(ret)),0);

retv=ret.^[0:maxitr];
%set kernel sizes in each pyramid level, but make sure they are all odd 
k1list=ceil(k1*retv);
k1list=k1list+(mod(k1list,2)==0);
k2list=ceil(k2*retv);
k2list=k2list+(mod(k2list,2)==0);

cret=retv(end);
k=resizeKer(prob.k,cret,k1list(end),k2list(end));

for itr=maxitr+1:-1:1
  cret=retv(itr);
  sy=downSmpImC(prob.y,cret);
  tprob=prob;
  tprob.y=sy; tprob.k=k; 
  tprob=set_sizes(tprob);
  tprob.filtx=[];
  tprob.x=[]; 
  tprob=filt_y(tprob);

  [tprob,kList,freeeng]=deconv1(tprob,sig_noise_v);
  
  %for debugging and monitoring, save output of this iter to the
  %disk and optionally display them to the screen.
  kListItr{itr}=kList;
  if (dispOn|writeOn)
     freeeng;
     stp=max(1,floor(size(kList,3)/20));
     for j=1:size(kList,3)
         kListsum(j)=sum(sum(kList(:,:,j)));
         kList(:,:,j)=kList(:,:,j)/max(max(kList(:,:,j)))*1.3;
         
     end 
  
     tKimg=imresize(flat3DArray(kList(:,:,[1:stp:end,end]),4),10, ...
                    'nearest');
     if dispOn
         %figure, plot(freeeng(:)); drawnow;
         figure, imshow(tKimg), drawnow;
     end
     if writeOn
       imwrite(tKimg,sprintf('%s_itr%02d.bmp',outname,itr))
     end
  end
 
  %resize kernel for next iteration.
  if (itr>1)
    k=resizeKer(tprob.k,1/ret,k1list(itr-1),k2list(itr-1));
  end
 
end

prob=tprob;