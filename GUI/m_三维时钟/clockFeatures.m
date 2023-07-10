% ---------------------------------------------------------------------------
% function features = clockFeatures
% ---------------------------------------------------------------------------
% Eventually this data will come from a text file.
% At the moment, the geometry is defined in MATLAB.  But with a little
% work it could come out of an xml-style format.
% ---------------------------------------------------------------------------
function feature = clockFeatures;

% Get the current time

   current_time            =  clock                                      ;

   second_ratio            =  round(current_time(6)/60)                  ;
   minute_ratio            =        current_time(5)/60                   ;

   second_angle            =                  -second_ratio     * 2*pi   ;
   minute_angle            = -(current_time(5)+second_ratio)/60 * 2*pi   ;
   hour_angle              = -(current_time(4)+minute_ratio)/12 * 2*pi   ;

% Main rates

   second_hand_rate        = -1/60 * 2*pi                                ;
   minute_hand_rate        =  second_hand_rate/60                        ;
   hour_hand_rate          =  minute_hand_rate/12                        ;

% Coupling rates

   sec_to_min_driver1      = -second_hand_rate/2                         ;
   sec_to_min_driver2      =  second_hand_rate/4                         ;
   sec_to_min_driver3      = -second_hand_rate/12                        ;
   min_to_hour_driver      = -minute_hand_rate/3                         ;

% Initialize the part count to zero

   n                       = 0                                           ;

% Define the shaft objects
% ------------------------

   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'secondshaft'                               ;
   feature(n).location     = [ 0     0     0.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  second_hand_rate]             ;
   feature(n).facecolor    = [ 1     1     0   ]                         ;
   feature(n).innerRad     =   0.27                                      ;
   feature(n).outerRad     =   0.30                                      ;
   feature(n).length       =   10.0                                      ;
   feature(n).numSides     =   16                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'minuteshaft'                               ;
   feature(n).location     = [ 0     0     3.3 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  minute_hand_rate]             ;
   feature(n).facecolor    = [ 1     0     1   ]                         ;
   feature(n).innerRad     =   0.32                                      ;
   feature(n).outerRad     =   0.35                                      ;
   feature(n).length       =   6.3                                       ;
   feature(n).numSides     =   16                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'hourshaft'                                 ;
   feature(n).location     = [ 0     0     5.8 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    hour_hand_rate]             ;
   feature(n).facecolor    = [ 0     1     1   ]                         ;
   feature(n).innerRad     =   0.37                                      ;
   feature(n).outerRad     =   0.40                                      ;
   feature(n).length       =   3.2                                       ;
   feature(n).numSides     =   16                                        ;

   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'secondtominuteshaft1'                      ;
   feature(n).location     = [-6.0   0     0.25]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    sec_to_min_driver1]         ;
   feature(n).facecolor    = [ 0     1     1   ]                         ;
   feature(n).innerRad     =   0.25                                      ;
   feature(n).outerRad     =   0.30                                      ;
   feature(n).length       =   7.5                                       ;
   feature(n).numSides     =   16                                        ;

   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'secondtominuteshaft2'                      ;
   feature(n).location     = [-5.0   5     0.25]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    sec_to_min_driver2]         ;
   feature(n).facecolor    = [ 0     1     1   ]                         ;
   feature(n).innerRad     =   0.25                                      ;
   feature(n).outerRad     =   0.30                                      ;
   feature(n).length       =   7.5                                       ;
   feature(n).numSides     =   16                                        ;

   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'secondtominuteshaft3'                      ;
   feature(n).location     = [ 0     6     0.25]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    sec_to_min_driver3]         ;
   feature(n).facecolor    = [ 0     1     1   ]                         ;
   feature(n).innerRad     =   0.25                                      ;
   feature(n).outerRad     =   0.30                                      ;
   feature(n).length       =   7.5                                       ;
   feature(n).numSides     =   16                                        ;

   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'minutetohourshaft'                         ;
   feature(n).location     = [ 6     0     0.25]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    min_to_hour_driver]         ;
   feature(n).facecolor    = [ 0     1     1   ]                         ;
   feature(n).innerRad     =   0.25                                      ;
   feature(n).outerRad     =   0.30                                      ;
   feature(n).length       =   7.5                                       ;
   feature(n).numSides     =   16                                        ;
 
% Define the fore and back plates objects
% ---------------------------------------

   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'faceplate'                                 ;
   feature(n).location     = [ 0     0     7.5 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  0.00]                         ;
   feature(n).facecolor    = [ 0     0.5   1   ]                         ;
   feature(n).edgecolor    = [ 0     0.7   1   ]                         ;
   feature(n).facealpha    =   0.5                                       ;
   feature(n).edgealpha    =   0.1                                       ;
   feature(n).innerRad     =   0.42                                      ;
   feature(n).outerRad     =  12.00                                      ;
   feature(n).length       =   0.5                                       ;
   feature(n).numSides     =   120                                       ;
   feature(n).static       =   1                                         ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'backplate'                                 ;
   feature(n).location     = [ 0     0     0.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  0.00]                         ;
   feature(n).facecolor    = [ 0     0.5   1   ]                         ;
   feature(n).edgecolor    = [ 0     0.7   1   ]                         ;
   feature(n).edgealpha    =   0.5                                       ;
   feature(n).innerRad     =   0.32                                      ;
   feature(n).outerRad     =  12.00                                      ;
   feature(n).length       =   0.5                                       ;
   feature(n).numSides     =   120                                       ;
   feature(n).static       =   1                                         ;
 
% Define the hands of the clock
% -----------------------------

   n                       = n+1                                         ;
   feature(n).type         = 'hand'                                      ;
   feature(n).name         = 'secondhand'                                ;
   feature(n).location     = [ 0     0.00  9.7 ]                         ;
   feature(n).orientation  = [ 0     0     second_angle    ]             ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  second_hand_rate]             ;
   feature(n).facecolor    = [ 1     1     0.1 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).outerRad     =   0.40                                      ;
   feature(n).thickness    =   0.2                                       ;
   feature(n).length       =   8.0                                       ;
   feature(n).numSides     =   12                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'hand'                                      ;
   feature(n).name         = 'minutehand'                                ;
   feature(n).location     = [ 0     0.00  9.2 ]                         ;
   feature(n).orientation  = [ 0     0     minute_angle    ]             ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  minute_hand_rate]             ;
   feature(n).facecolor    = [ 1     0.1   1   ]                         ;
   feature(n).innerRad     =   0.35                                      ;
   feature(n).outerRad     =   0.45                                      ;
   feature(n).thickness    =   0.3                                       ;
   feature(n).length       =   7.0                                       ;
   feature(n).numSides     =   12                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'hand'                                      ;
   feature(n).name         = 'hourhand'                                  ;
   feature(n).location     = [ 0     0.00  8.5 ]                         ;
   feature(n).orientation  = [ 0     0     hour_angle    ]               ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  hour_hand_rate]               ;
   feature(n).facecolor    = [ 0.1   1     1   ]                         ;
   feature(n).innerRad     =   0.40                                      ;
   feature(n).outerRad     =   0.50                                      ;
   feature(n).thickness    =   0.4                                       ;
   feature(n).length       =   4.0                                       ;
   feature(n).numSides     =   12                                        ;
 
% Define the gear train
% ---------------------

   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'hourmaingear'                              ;
   feature(n).location     = [ 0     0.00  6.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    hour_hand_rate]             ;
   feature(n).facecolor    = [ 0     0.9   0.9 ]                         ;
   feature(n).innerRad     =   0.40                                      ;
   feature(n).contactRad   =  24/5                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   96                                        ;
   feature(n)              = gearTweak(feature(n), 0.75, 3)              ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'drivertohourgear'                          ;
   feature(n).location     = [ 6     0.00  6.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    min_to_hour_driver]         ;
   feature(n).facecolor    = [ 0     0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   6/5                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   24                                        ;

   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'driverfromminutegear'                      ;
   feature(n).location     = [ 6     0.00  5.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00    min_to_hour_driver]         ;
   feature(n).facecolor    = [ 0.0   0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   4.5                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =  144                                        ;
   feature(n)              = gearTweak(feature(n), 0.75, 3)              ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'minutetodrivergear'                        ;
   feature(n).location     = [ 0     0.00  5.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  minute_hand_rate]             ;
   feature(n).facecolor    = [ 0.9   0     0.9 ]                         ;
   feature(n).innerRad     =   0.35                                      ;
   feature(n).contactRad   =   1.5                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   48                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'minutefromdriver3gear'                     ;
   feature(n).location     = [ 0     0.00  4.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  minute_hand_rate]             ;
   feature(n).facecolor    = [ 0.9   0     0.9 ]                         ;
   feature(n).innerRad     =   0.35                                      ;
   feature(n).contactRad   =   5.0                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   120                                       ;
   feature(n)              = gearTweak(feature(n), 0.75, 3)              ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'driver3tominutegear'                       ;
   feature(n).location     = [ 0     6     4.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  sec_to_min_driver3]           ;
   feature(n).facecolor    = [ 0     0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   1.0                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   24                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'driver3fromdriver2gear'                    ;
   feature(n).location     = [ 0     6     3.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  sec_to_min_driver3]           ;
   feature(n).facecolor    = [ 0     0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   sqrt(26)*3/4                              ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   72                                        ;
   feature(n)              = gearTweak(feature(n), 0.75, 3)              ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'driver2todriver3gear'                      ;
   feature(n).location     = [-5     5     3.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  sec_to_min_driver2]           ;
   feature(n).facecolor    = [ 0     0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   sqrt(26)*1/4                              ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   24                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'driver2fromdriver1gear'                    ;
   feature(n).location     = [-5     5     2.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  sec_to_min_driver2]           ;
   feature(n).facecolor    = [ 0     0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   sqrt(26)*2/3                              ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   120                                       ;
   feature(n)              = gearTweak(feature(n), 0.025, 3)             ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'driver1todriver2gear'                      ;
   feature(n).location     = [-6     0     2.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  sec_to_min_driver1]           ;
   feature(n).facecolor    = [ 0     0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   sqrt(26)*1/3                              ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   60                                        ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'driver1fromsecondgear'                     ;
   feature(n).location     = [-6     0     1.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  sec_to_min_driver1]           ;
   feature(n).facecolor    = [ 0     0.5   0.5 ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   4.0                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   150                                       ;
   feature(n)              = gearTweak(feature(n), 0.25, 3)              ;
 
   n                       = n+1                                         ;
   feature(n).type         = 'gear'                                      ;
   feature(n).name         = 'secondtodriver1gear'                       ;
   feature(n).location     = [ 0     0     1.0 ]                         ;
   feature(n).orientation  = [ 0     0     0.0 ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  second_hand_rate]             ;
   feature(n).facecolor    = [ 0.9   0.9   0   ]                         ;
   feature(n).innerRad     =   0.30                                      ;
   feature(n).contactRad   =   2.0                                       ;
   feature(n).thickness    =   0.5                                       ;
   feature(n).toothheight  =   0.2                                       ;
   feature(n).numTeeth     =   75                                        ;

% Create the markers for the hours
% --------------------------------

   numbers                 = [1:12]                                      ;
   number_radius           = 11                                          ;
   numbers_angles          = numbers/12*2*pi + pi/2                      ;
   numbers_xpos            = number_radius*cos(numbers_angles)           ;
   numbers_ypos            = number_radius*sin(numbers_angles)           ;
   numbers_zpos            = 7.9*ones(size(numbers))                     ;
   numbers_location        = [ numbers_xpos' numbers_ypos' numbers_zpos'];
   numbers_xang            = pi/2*ones(size(numbers))                    ;
   numbers_yang            =     zeros(size(numbers))                    ;
   numbers_zang            = numbers_angles + 3*pi/2                     ;
   numbers_orientation     = [ numbers_xang' numbers_yang' numbers_zang'];
   numbers_length          = [ 2.0 2.0 3.5, ...
                               2.0 2.0 3.5, ...
                               2.0 2.0 3.5, ...
                               2.0 2.0 3.1                               ];

% Create a template for the numbers

   defaultnum              = feature(n)                                  ;
   defaultnum.type         = 'shaft'                                     ;
   defaultnum.linearVel    = [ 0     0     0   ]                         ;
   defaultnum.angularVel   = [ 0.00  0.00  0.00]                         ;
   defaultnum.facecolor    = [ 0.2   0.2   0.2 ]                         ;
   defaultnum.innerRad     =   0.00                                      ;
   defaultnum.outerRad     =   0.20                                      ;
   defaultnum.numSides     =  10                                         ;
   defaultnum.static       =   1                                         ;

% Create markers for one through noon

   for m = 1:length(numbers)
      n                       = n+1                                      ;
      feature(n)              = defaultnum                               ;
      feature(n).name         = ['oclock_' num2str(m)]                   ;
      feature(n).location     = numbers_location(m,:)                    ;
      feature(n).orientation  = numbers_orientation(m,:)                 ;
      feature(n).length       = numbers_length(m)                        ;
   end

% Add a custom icon at noon
 
   n                       = n+1                                         ;
   feature(n).type         = 'shaft'                                     ;
   feature(n).name         = 'noon_oclock'                               ;
   feature(n).location     = [ 0      7.7  7.9 ]                         ;
   feature(n).orientation  = [ pi/2  pi/4  0   ]                         ;
   feature(n).linearVel    = [ 0     0     0   ]                         ;
   feature(n).angularVel   = [ 0.00  0.00  0.00]                         ;
   feature(n).facecolor    = [ 0.2   0.2   0.2 ]                         ;
   feature(n).innerRad     =   0.00                                      ;
   feature(n).outerRad     =   0.20                                      ;
   feature(n).length       =   0.20                                      ;
   feature(n).numSides     =   4                                         ;
   feature(n).static       =   1                                         ;


% ---------------------------------------------------------------------------
% gearTweak()
% ---------------------------------------------------------------------------
% Reorients the gear so that the teeth mesh.  Values are tuned by hand
% All this should not be necessary once a proper gear object is defined
% (or implimented).
% ---------------------------------------------------------------------------
function gear = gearTweak(gear, toothAmount, axisNum)

% Compute the radians per tooth

   rad_per_tooth             = 2*pi / gear.numTeeth                      ;

% Find the number of radians to tweak the gear

   tweak                     = rad_per_tooth*toothAmount                 ;

% Tweak the orientation

   gear.orientation(axisNum) = gear.orientation(axisNum) + tweak         ;
 
