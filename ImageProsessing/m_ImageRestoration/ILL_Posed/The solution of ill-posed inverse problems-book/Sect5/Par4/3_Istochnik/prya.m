function [q,g,h,r]=prya(p,e,u,time)
%PRYA	Boundary condition data.
%  ���������� ������� ������� �� ������� � ������ �����
%  ��������������; ���������� ������� ������� �� �����
%  � ������ �����

%
%
%
bl=[
1 1 1 1
1 0 1 0
1 1 1 1
1 1 1 1
1 48 1 48
1 48 1 48
48 48 48 48
48 48 48 48
49 49 49 49
48 48 48 48
];

if any(size(u))
  [q,g,h,r]=pdeexpd(p,e,u,time,bl);
else
  [q,g,h,r]=pdeexpd(p,e,time,bl);
end
