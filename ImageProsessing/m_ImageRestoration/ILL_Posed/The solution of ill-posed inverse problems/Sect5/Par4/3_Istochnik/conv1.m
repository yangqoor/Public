function [cons,dc]=Conv1(c,AA,U,u_k);

u_in=u_k*c;UU=AA*c;
%  min(diff(u_in(1:llll)))>0  max(diff(u_in(llll:end)))<0
%[mmmm,llll]=max(u_in);
%if (llll==1);llll=3;elseif(llll==length(u_in));llll=length(u_in)-2;end
%cons=[max(diff(u_in(llll:end)));-min(diff(u_in(1:llll)))];

cons=[max(diff(diff(diff(u_in'))))];
dc=[];
