%MYCLOCK 3D Clock with gear train.
%   MYCLOCK() generates and plots a 3D graphical representation of a
%   clock, complete with a transparent face and a working gear train.
%
%   This file implements a simple 3D graphics engine with support for
%   three basic primitive objects: shafts, hands (of a clock), and gears
%   The clock is made exclusively of these three types of objects.
%
%   Functionality is broken into sections: parameter loading, object
%   creation and visualization, and object updating.
%      Parameter Loading and object creation: 
%         This subsystem is responsible for loading the macroscopic 
%         1information for each primitive object (object thickness,
%         initial position, diameter, etc.) and converting that into
%         object data that MATLAB needs to render the objects of interest.
%      Object visualization:
%         Plots object data to a figure window.
%      Object updating:
%         Each object is capable of undergoing general motion, including
%         translation and rotation about an arbitrary fixed point.  The
%         object updating routines are responsible for moving the objects
%         every time step.  This is accomplished via access to the x,y,z
%         surface data accessible from the object graphics.
%
%   Future work will involve creating (or implementing an existing) higher
%   level gear connectivity over the existing low level object motion
%   commands currently available.  This would allow the operator to interact
%   with a gear train, rather than create rotating objects that happen to
%   look like gears.

% Michael Agostini
% (c) The MathWorks 2005
% This is provided as an example only.

% --------------------------------------------------------------------------
% myclock()
% --------------------------------------------------------------------------
% Main entry point to the program
% --------------------------------------------------------------------------
function myclock

% Create a clock, if one does not exist

   objectData          = loadObject('myclock.xml')     ;%filename meaningless
   canvas.figurehandle = figure                        ;
   canvas.axis         = [-12 12 -12 12   0 10]        ;

% Set a new close request handle, which will also stop the timer object

   set(canvas.figurehandle, 'CloseRequestFcn', @myclosereq);

% Splash the object onto a figure window, if a window does not exist

  [objectData,canvas]  = drawObject(objectData,canvas) ;

   setappdata(0, 'objectData', objectData   );
   setappdata(0,  'updateFcn', @updateObject);
   
% Set the view

   view([0 0 90])
   axis square
   axis off

% Create and start a timer

   mytimer     = timer('TimerFcn'     ,@timerUpdate , ...
                       'StartDelay'   , 0           , ...
                       'Period'       , 1           , ...
                       'Name'         ,'objectTimer', ...
                       'ExecutionMode','fixedrate'       );

   start(mytimer);



% --------------------------------------------------------------------------
% timerUpdate()
% --------------------------------------------------------------------------
% Function for timer object to call.
% --------------------------------------------------------------------------
function timerUpdate(varargin)

   objectData = getappdata(0, 'objectData')  ;
   fcnHandle  = getappdata(0, 'updateFcn' )  ;
   objectData = fcnHandle (objectData, 1  )  ;

   setappdata(0, 'objectData', objectData )  ;


% --------------------------------------------------------------------------
% myclosereq()
% --------------------------------------------------------------------------
% Deletes the timer when the figure is closed 
% --------------------------------------------------------------------------
function myclosereq(varargin)

% Stop and delete timer

   mytimer = timerfind('Name', 'objectTimer') ;

   if ~isempty(mytimer)
      stop  (mytimer)                         ;
      delete(mytimer)                         ;
   end

% Call normal close request

   closereq                                   ;


% ***************************************************************************
% Object loading/creation subroutines
% ***************************************************************************

% ---------------------------------------------------------------------------
% function object = createObject
% ---------------------------------------------------------------------------
% Loads object parameters from file and calls the appropriate creation
% function.
% 
% Currently the 'filename' variable is not used.  Eventually the object
% features will be loaded from an xml file.
% ---------------------------------------------------------------------------
function object = loadObject(filename)

% Load object feature array

   feature = clockFeatures;
%  feature = readobjectxml(filename);
 
% Create the 3d Objects from the paramaterized data
 
   for n = 1:length(feature)
      switch feature(n).type
       case {'shaft'}
         object.(feature(n).name) = createShaft (feature(n));
       case {'gear'}
         object.(feature(n).name) = createGear  (feature(n));
       case {'hand'}
         object.(feature(n).name) = createHand  (feature(n));
       case {'spring'}
         object.(feature(n).name) = createSpring(feature(n));
       otherwise
         disp(['Ignoring invalid feature type: ' feature(n).type])
      end
   end
 
% ---------------------------------------------------------------------------
% createGear()
% ---------------------------------------------------------------------------
% Creates a gear object
% ---------------------------------------------------------------------------
function gear = createGear(gearObject)

% Define local variables for constructing the gear

   gearRad         = gearObject.contactRad       ;
   toothHeight     = gearObject.toothheight      ;
   numTeeth        = gearObject.numTeeth         ;

   toothMin        = gearRad - toothHeight/2     ;
   toothMax        = gearRad + toothHeight/2     ;
   numEdges        = numTeeth*4                  ;

   inner           = gearRad - toothHeight*1.5   ;

% Create two cylinders of differing diameters

   [x,y,z]         = cylinder([inner inner toothMax toothMax inner], numEdges);
   [xp,yp,zp]      = cylinder([inner inner toothMin toothMin inner], numEdges);

   thickness       = gearObject.thickness            ;
   z(5,:)          =  ones(size(z(5,:)))*thickness   ;%set the correct length
   z(4,:)          =  ones(size(z(4,:)))*thickness   ;%set the correct length
   z(3,:)          = zeros(size(z(3,:)))             ;%set the bottom
   z(2,:)          = zeros(size(z(2,:)))             ;%set the bottom
   z(1,:)          =  ones(size(z(1,:)))*thickness   ;%set the wrap around

% Weave the two outer cylinders together to create the teeth

   for n = 1:size(x,2)
       type = rem(n,4);
       switch type
        case 0
          x(:,n) = xp(:,n);
          y(:,n) = yp(:,n);
        case 1
          x(:,n) = xp(:,n);
          y(:,n) = yp(:,n);
       end
   end

% Create the gear object
 
   gear.teeth.xdata     = x                        ;
   gear.teeth.ydata     = y                        ;
   gear.teeth.zdata     = z                        ;
   gear.teeth.handle    = []                       ;
   gear.teeth.facecolor = gearObject.facecolor     ;
   gear.teeth.center    = [ 0 0 0 ]                ;
   gear.teeth.location  = [ 0 0 0 ]                ;
   gear.teeth.rotAngle  = gearObject.angularVel    ;
   gear.teeth.translate = gearObject.linearVel     ;
 
% Set the optional data

   gear.teeth.static    = myset(gearObject,'static'   , 0     );
   gear.teeth.edgecolor = myset(gearObject,'edgecolor', 'k'   );
   gear.teeth.edgealpha = myset(gearObject,'edgealpha', 1     );
   gear.teeth.facecolor = myset(gearObject,'facecolor', 'k'   );
   gear.teeth.facealpha = myset(gearObject,'facealpha', 1     );
   gear.teeth.edgewidth = myset(gearObject,'edgewidth', 0.0001);

% Orient the object

   gear.teeth      = translateObject(gear.teeth, gearObject.location   );
   gear.teeth      = rotateObject   (gear.teeth, gearObject.orientation);

% Create the spokes of the gear

   hole            = gearObject.innerRad             ;
   hub             = hole*1.5                        ;
   [x,y,z]         = cylinder([hole  hole  hub   hub   hole  ], 36);
   [xb,yb,zb]      = cylinder([hole  hole  inner inner hole  ], 36);

   thickness       = gearObject.thickness            ;
   z(5,:)          =  ones(size(z(5,:)))*thickness   ;%set the correct length
   z(4,:)          =  ones(size(z(4,:)))*thickness   ;%set the correct length
   z(3,:)          = zeros(size(z(3,:)))             ;%set the bottom
   z(2,:)          = zeros(size(z(2,:)))             ;%set the bottom
   z(1,:)          =  ones(size(z(1,:)))*thickness   ;%set the wrap around

% Weave the two outer cylinders together to create the spokes

   for n = 1:size(x,2)
       type = rem(n,9);
       switch type
        case 4
          x(:,n) = xb(:,n);
          y(:,n) = yb(:,n);
        case 5
          x(:,n) = xb(:,n);
          y(:,n) = yb(:,n);
       end
   end

% Create the spoke object

   gear.spoke.xdata     = x                        ;
   gear.spoke.ydata     = y                        ;
   gear.spoke.zdata     = z                        ;
   gear.spoke.handle    = []                       ;
   gear.spoke.facecolor = gearObject.facecolor     ;
   gear.spoke.center    = [ 0 0 0 ]                ;
   gear.spoke.location  = [ 0 0 0 ]                ;
   gear.spoke.rotAngle  = gearObject.angularVel    ;
   gear.spoke.translate = gearObject.linearVel     ;

% Set the optional data

   gear.spoke.static    = myset(gearObject,'static'   , 0   );
   gear.spoke.edgecolor = myset(gearObject,'edgecolor', 'k' );
   gear.spoke.edgealpha = myset(gearObject,'edgealpha', 1   );
   gear.spoke.facecolor = myset(gearObject,'facecolor', 'k' );
   gear.spoke.facealpha = myset(gearObject,'facealpha', 1   );
   gear.spoke.edgewidth = myset(gearObject,'edgewidth', 0.01);

% Position the object

   gear.spoke  = translateObject(gear.spoke, gearObject.location   );
   gear.spoke  = rotateObject   (gear.spoke, gearObject.orientation);


% ---------------------------------------------------------------------------
% createShaft()
% ---------------------------------------------------------------------------
% Creates a shaft.
% ---------------------------------------------------------------------------
function shaft = createShaft(shaftObject)

% Create a basic cylinder

   inner           = shaftObject.innerRad             ;
   outer           = shaftObject.outerRad             ;
   numSides        = shaftObject.numSides             ;
   [x,y,z]         = cylinder([inner inner  outer  outer  inner], numSides);

% Cylinders are hollow, fill in the inside of the shaft

   length          = shaftObject.length              ;
   z(5,:)          =  ones(size(z(5,:)))*length      ;%set the correct length
   z(4,:)          =  ones(size(z(4,:)))*length      ;%set the correct length
   z(3,:)          = zeros(size(z(3,:)))             ;%set the bottom
   z(2,:)          = zeros(size(z(2,:)))             ;%set the bottom
   z(1,:)          =  ones(size(z(1,:)))*length      ;%set the wrap around

% Fill in the shaft data
 
   shaft.xdata     = x                        ;
   shaft.ydata     = y                        ;
   shaft.zdata     = z                        ;
   shaft.handle    = []                       ;
   shaft.facecolor = shaftObject.facecolor    ;
   shaft.center    = [ 0 0 0 ]                ;
   shaft.location  = [ 0 0 0 ]                ;
   shaft.rotAngle  = shaftObject.angularVel   ;
   shaft.translate = shaftObject.linearVel    ;

% Set the optional data

   shaft.static    = myset(shaftObject,'static'   , 0   );
   shaft.edgecolor = myset(shaftObject,'edgecolor', 'k' );
   shaft.edgealpha = myset(shaftObject,'edgealpha', 1   );
   shaft.facecolor = myset(shaftObject,'facecolor', 'k' );
   shaft.facealpha = myset(shaftObject,'facealpha', 1   );
   shaft.edgewidth = myset(shaftObject,'edgewidth', 0.01);

% Give it the correct orientation

   shaft           = translateObject(shaft, shaftObject.location)   ;
   shaft           = rotateObject   (shaft, shaftObject.orientation);


% ---------------------------------------------------------------------------
% createHand()
% ---------------------------------------------------------------------------
% Creates a clock hand
% ---------------------------------------------------------------------------
function hand = createHand(handObject)

% Create collar 'ring'

   ringData            = handObject               ;
   ringData.length     = ringData.thickness       ;

   hand.ring           = createShaft(ringData)    ;

% Create 'arm' of the hand

   offset              = handObject.innerRad      ;
   width               = handObject.thickness     ;
   [x,y,z]             = cylinder([width/2 width/2 0], 4);

   z(2,:)              = z(2,:)*handObject.length/2 ;
   z(3,:)              = z(3,:)*handObject.length   ;

   hand.arm.xdata      = x                        ;
   hand.arm.ydata      = y                        ;
   hand.arm.zdata      = z                        ;
   hand.arm.handle     = []                       ;
   hand.arm.facecolor  = handObject.facecolor     ;
   hand.arm.center     = [ 0 0 0 ]                ;
   hand.arm.location   = [ 0 0 0 ]                ;
   hand.arm.rotAngle   = handObject.angularVel    ;
   hand.arm.translate  = handObject.linearVel     ;

% Set the optional data

   hand.arm.static     = myset(handObject,'static'   , 0   );
   hand.arm.edgecolor  = myset(handObject,'edgecolor', 'k' );
   hand.arm.edgealpha  = myset(handObject,'edgealpha', 1   );
   hand.arm.facecolor  = myset(handObject,'facecolor', 'k' );
   hand.arm.facealpha  = myset(handObject,'facealpha', 1   );
   hand.arm.edgewidth  = myset(handObject,'edgewidth', 0.01);

% Orient the arm to point parallel to the face

   hand.arm            = translateObject(hand.arm, handObject.location   );
   hand.arm            = rotateObject   (hand.arm, [-pi/2 0 0]           );
   hand.arm            = translateObject(hand.arm, [0  offset width/2 ]  );
   hand.arm.center     = [ 0  offset 0 ]                                  ;
   hand.arm            = rotateObject   (hand.arm, handObject.orientation);

% ---------------------------------------------------------------------------
% myset()
% ---------------------------------------------------------------------------
% A utility function for assigning data to an object field
% ---------------------------------------------------------------------------
function outdata = myset(object, fieldname, altdata)

   if isfield(object, fieldname) && ~isempty(object.(fieldname))
      outdata = object.(fieldname) ;
   else
      outdata = altdata            ;
   end


% *************************************************************************
% Object drawing subroutines
% *************************************************************************

% --------------------------------------------------------------------------
% drawObject()
% --------------------------------------------------------------------------
% A recursive function that decends into a structure and draws 3d graphics
% objects using draw3d().
% At one point, each object was going to have its own drawing function. 
% Future versions may go to that model for maximum flexibility.  Currently
% all objects can be drawn with the draw3d() function.
% --------------------------------------------------------------------------
function [imageData, canvas] = drawObject(imageData, canvas)

% If this is a graphic3d object, use draw it using its 'draw' method

   if isfield(imageData,'handle')
      imageData = draw3d(imageData, canvas) ;%all objects use draw3d()
      return;
   end

% Otherwise, assume the oject is a collection of sub-objects

   nodes = fields(imageData) ;

   for n = 1:length(nodes)
      leaf                      = char(nodes(n))                      ;
     [imageData.(leaf), canvas] = drawObject(imageData.(leaf), canvas);
   end


% ---------------------------------------------------------------------------
% draw3d()
% ---------------------------------------------------------------------------
% Default rendering code for all objects
% --------------------------------------------------------------------------
function this = draw3d(this, canvas)

% Set the correct figure

   figure(canvas.figurehandle)

% Draw the surface of interest and set the color

   this.handle = surf (this.xdata , this.ydata , this.zdata     );
                 set  (this.handle, 'FaceColor', this.facecolor );
                 set  (this.handle, 'EdgeColor', this.edgecolor );
                 set  (this.handle, 'FaceAlpha', this.facealpha );
                 set  (this.handle, 'EdgeAlpha', this.edgealpha );
                 set  (this.handle, 'LineWidth', this.edgewidth );

% Set the axis to the correct dimensions

   axis manual
   axis(canvas.axis)

   hold on

% *************************************************************************
% Object updating subroutines
% *************************************************************************

% ---------------------------------------------------------------------------
% updateObject()
% ---------------------------------------------------------------------------
% A recursive function that decends into a structure and updates 3d graphics
% objects using update3d().
% At one point, each object was going to have its own updating function. 
% Future versions may go to that model for maximum flexibility.  Currently
% all objects can be updated with the update3d() function.
% --------------------------------------------------------------------------
function [imageData] = updateObject(imageData, updateFreq)

% If this is an object3d, update

   if isfield(imageData,'handle')
      imageData = update3d(imageData, updateFreq);
      return;
   end

% Otherwise, assume the oject is a collection of sub-objects

   nodes = fields(imageData)                     ;

   for n = 1:length(nodes)
      leaf = char(nodes(n))                      ;
      imageData.(leaf) = updateObject(imageData.(leaf), updateFreq);
   end


% ---------------------------------------------------------------------------
% update3d()
% ---------------------------------------------------------------------------
% Default updating code for all objects.
% --------------------------------------------------------------------------
function [this] = update3d(this, updateFreq)

% Do nothing if the object has been labeled 'static'

   if(this.static)
      return;
   end

% Rotate then translate the object as required

   transAmount  =  this.translate*updateFreq  ;
   rotateAmount =  this.rotAngle *updateFreq  ;

   this = translateObject(this, transAmount  );
   this = rotateObject   (this, rotateAmount );

   set(this.handle, 'XData', this.xdata, ...
                    'YData', this.ydata, ...
                    'ZData', this.zdata      );


% ---------------------------------------------------------------------------
% translateObject()
% ---------------------------------------------------------------------------
% Translates an object through space
% ---------------------------------------------------------------------------
function object  = translateObject(object, transAmount)

   object.xdata    =  object.xdata    + transAmount(1)   ;
   object.ydata    =  object.ydata    + transAmount(2)   ;
   object.zdata    =  object.zdata    + transAmount(3)   ;

   object.location =  object.location + transAmount      ;


% ---------------------------------------------------------------------------
% rotateObject
% ---------------------------------------------------------------------------
% Rotates an object in space using an X,Y,Z Euler Angle rotation
% ---------------------------------------------------------------------------
function object  = rotateObject(object, rotateAmount)

% Get the current shape

   [x,y]         =  size(object.xdata)                             ;

% Find location of center of rotation

   xPos          =  object.location(1) - object.center(1)          ;
   yPos          =  object.location(2) - object.center(2)          ;
   zPos          =  object.location(3) - object.center(3)          ;

% Reshape data into a vector for the math operation of choice

   xdata         =  reshape(object.xdata,1,[]) - xPos              ;
   ydata         =  reshape(object.ydata,1,[]) - yPos              ;
   zdata         =  reshape(object.zdata,1,[]) - zPos              ;

% Create the rotation matrix (dcm)

   xAng          =  rotateAmount(1)                                ;
   yAng          =  rotateAmount(2)                                ;
   zAng          =  rotateAmount(3)                                ;
   dcm           =  zRotate(zAng)*yRotate(yAng)*xRotate(xAng)      ;

% Transform the orientation using the dcm (direction cosine matrix)

   tmp           =  dcm*[xdata; ydata; zdata ]                     ;
   xdata         =  tmp(1,:) + xPos                                ;
   ydata         =  tmp(2,:) + yPos                                ;
   zdata         =  tmp(3,:) + zPos                                ;

% Put the transformed data back into the correct shape

   object.xdata  =  reshape(xdata,x,y)                             ;
   object.ydata  =  reshape(ydata,x,y)                             ;
   object.zdata  =  reshape(zdata,x,y)                             ;


% ---------------------------------------------------------------------------
% xRotate
% ---------------------------------------------------------------------------
% Rotate an object about the 'x' axis
% ---------------------------------------------------------------------------
function dcm = xRotate(ang)

   dcm = [         1,         0,         0 ; ...
                   0,  cos(ang), -sin(ang) ; ...
                   0,  sin(ang),  cos(ang)       ] ;
         
% ---------------------------------------------------------------------------
% yRotate
% ---------------------------------------------------------------------------
% Rotate an object about the 'y' axis
% ---------------------------------------------------------------------------
function dcm = yRotate(ang)

   dcm = [  cos(ang),         0,  sin(ang) ; ...
                   0,         1,         0 ; ...
           -sin(ang),         0,  cos(ang)       ] ;

% ---------------------------------------------------------------------------
% zRotate
% ---------------------------------------------------------------------------
% Rotate an object about the 'z' axis
% ---------------------------------------------------------------------------
function dcm = zRotate(ang)

   dcm = [  cos(ang), -sin(ang),         0 ; ...
            sin(ang),  cos(ang),         0 ; ...
                   0,         0,         1       ] ;

