function [t, a] = gettime(StartDate)
%I took this from internet.  no warranty
%GETTIME - Returns the present computer in seconds and Matlab vector time
%  [t, clock] = gettime(StartDate)
%
%  INPUTS
%  1. StartDate - Starting date {Default: 1-Jan-1970}
%
%  OUPUTS
%  1. t     - the time in seconds since  00:00:00, Jan 1, 1970 (w.r.t. the computer time zone)
%  2. clock - the time as returned by the clock function       (w.r.t. the computer time zone)

%  Written by Greg Portmann

if nargin < 1
    % Days since 1970
    DateNumber = 719529;  %datenum('1-Jan-1970');
else
    if length(StartDate) == 6
        DateNumber = datenum(StartDate(1:3));
    else
        DateNumber = datenum(StartDate);
    end
end

days = datenum(date) - DateNumber;

a = clock;
t = 24*60*60*days + 60*60*a(4) + 60*a(5) + a(6);