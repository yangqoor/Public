function [fitresult, gof] = createFit(f, t)
%CREATEFIT1(F,T)
%  Create a fit.
%
%  Data for 'poly5_rate2angle' fit:
%      X Input : f
%      Y Output: t
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 07-Apr-2021 15:23:46 自动生成


%% Fit: 'poly5_rate2angle'.
[xData, yData] = prepareCurveData( f, t );

% Set up fittype and options.
ft = fittype( 'poly5' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );

% Plot fit with data.
figure( 'Name', 'poly5_rate2angle' );
h = plot( fitresult, xData, yData );
legend( h, 't vs. f', 'poly5_rate2angle', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'f', 'Interpreter', 'none' );
ylabel( 't', 'Interpreter', 'none' );
grid on


