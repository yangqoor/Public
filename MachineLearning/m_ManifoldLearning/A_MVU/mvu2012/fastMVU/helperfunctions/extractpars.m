function pars=extractpars(vars,default,optional);
% function pars=extractpars(vars,default,optional);
%
% returns a stract pars with fieldnames defined in vars
% 
% copyright 2006 by Kilian Q. Weinberger

% check if optional parameter should be considered
if(exist('optional') & isstr(optional))
 for i=length(vars):-1:1
   vars{i+1}=vars{i};
 end;
 vars{1}=optional;
end;


if(nargin<2)
  default=[];
end;
pars=default;
if(length(vars)==1)
 p=vars{1};
 s=fieldnames(p);
 for i=1:length(s)
   eval(['pars.' s{i} '=p.' s{i} ';']);
 end;     

else

 for i=1:2:length(vars)
  if(isstr(vars{i}))
    if(i+1>length(vars)) error(sprintf('Parameter %s has no value\n',vars{i}));else val=vars{i+1};end;
    if(isstr(val))
     eval(['pars.' vars{i} '=''' val ''';']);
    else
     eval(['pars.' vars{i} '=val;']);
    end;
  end;
 end;

end;

