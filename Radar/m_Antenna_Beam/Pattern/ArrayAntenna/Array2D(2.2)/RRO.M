function qph=rro(iph,nel,nstates,bitsize,xsi)
%
% subroutine to quantize phase slope using random roundoff
% iph=2 regular random roundoff
%    =3 weighted random roundoff
%
	rnd = 0;

	for i=1:nel
   	nsteps=floor((xsi(i)+1.e-4)/bitsize);
      plo=nsteps*bitsize;
      phi=plo+bitsize;
      qph(i)=plo;
      xn=rand;
		% criteria for regular random roundoff
      if iph==3 & xn>0.5, qph(i)=phi;, end
		% criteria for weighted random roundoff
      if iph==4
         pnorm=(xsi(i)-plo)/bitsize;
         rnd=pnorm+xn;
         if rnd>1, qph(i)=phi;, end
      end
      if rnd==1, qph(i)=phi;, end
   end
