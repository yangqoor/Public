function y=array_core(h1,h2)

% array plot   author: Mohamed Hamed awida

% in general AFn= 1/N * sin(N/2*epsi)/sin(epsi/2)
% where epsi=k*d*cos(theta)+beta   but k=2*pi/lamda
%       epsi=2*pi*dn*cos(theta)+beta where dn=d/lamda

switch h1
    
    case 0
        array_main                     % Main Array Function
    case 1
        array_ctrl(h2)                 % Array Control Functions 
end

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                                   Main Array Functions
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------



%------------------------------------------------------
function array_main                                   
 
% Main array functions                                
%------------------------------------------------------        

% Initialization
%--------------------
syms theta phi real;         % Set theta and phi as symbolic variables 

                   
h_dim=findobj(gcbf,'tag','array_dim');
dim=get(h_dim,'value');                    % dim     : array dimension

if dim==1
    
%------------------------------------------------------        
%                   1-D Array
%------------------------------------------------------   

    %--------------------
    % 1-D Array Inputs
    %--------------------
    % n       : number of elements in case 
    % dn      : normalized spacing
    % theta_m : angle of maximum radiation
    % R0_dB   : side lobe level in dB(Tschebyscheff case only)
    % type    : array type 
    % config  : linear array configuration

     

    h_n=findobj(gcbf,'tag','no_elem');
    n=str2num(get(h_n,'string'));                     
 
    h_dn=findobj(gcbf,'tag','spacing');
    dn=str2num(get(h_dn,'string'));                   

    h_theta_m=findobj(gcbf,'tag','theta_m');
    theta_m=str2num(get(h_theta_m,'string'));  

    h_R0_dB=findobj(gcbf,'tag','R0');
    R0_dB=str2num(get(h_R0_dB,'string'));             

    h_type=findobj(gcbf,'tag','array_type');     
    type=get(h_type,'value');                       

    h_config=findobj(gcbf,'tag','config_list');
    config=get(h_config,'value');
    
    h_type=findobj(gcbf,'tag','type_list');
    type=get(h_type,'value');                  % type    : array type


    
    % Determine beta(progressive phase), depend on the array configuration

    switch config
    
        case 1                                    
        % Broadside Array
        %------------------------------------------------------
            beta=0;
            set(h_theta_m,'string','90','enable','off');
   
        case 2
        % Ordinary End-Fire Array with 0 degree
        %------------------------------------------------------   
             beta=-2*pi*dn;
             set(h_theta_m,'string','0','enable','off');
   
        case 3
        % Ordinary End-Fire Array with 180 degree
        %------------------------------------------------------
             beta=2*pi*dn;
             set(h_theta_m,'string','180','enable','off');
   
        case 4
        % Hansen Woodyard End-Fire Array with 0 degree
        %------------------------------------------------------    
              beta=-(2*pi*dn+2.94/n); 
              set(h_theta_m,'string','0','enable','off');
   
        case 5
        % Hansen Woodyard End-Fire Array with 180 degree
        %------------------------------------------------------
              beta=(2*pi*dn+2.94/n);
              set(h_theta_m,'string','180','enable','off');
    
        case 6
        % Phased(scanning) Array
        %------------------------------------------------------
              beta=-2*pi*dn*cos(deg2rad(theta_m)); 
              set(h_theta_m,'enable','on');
   
    end
                   
    
    epsi= 2*pi*dn*cos(theta)+beta;
    

    switch type
        
        case 1
        % Call linear array function, will return AF
        %-----------------------------------------------------
               AF=lin_array(n,dn,theta_m,epsi,beta);   
   
        case 2
        % Call non-linear array function, will return AF  
        %------------------------------------------------------
               AF=nlin_array(n,dn,theta_m,epsi,beta);
   
        case 3
        % Call binomial array function, will return AF
        %------------------------------------------------------
               AF=bin_array(n,dn,theta_m,epsi,beta); 
   
        case 4
        % Call tschebysceff array function, will return AF
        %------------------------------------------------------
               AF=tsch_array(n,dn,theta_m,R0_dB,epsi,beta);
        end
        
    %--------------------   
    % Plot
    %--------------------
    
    figure
    
    % 2-D polar Plot
    subplot(2,1,1)
    ezpolar(AF,[0 2*pi])                        
    %title('x-2D')

    % 3-D surface plot
    subplot(2,1,2)
    x= AF*sin(theta)*cos(phi);
    y= AF*sin(theta)*sin(phi);
    z= AF*cos(theta);
    ezsurf(x,y,z,[0,2*pi,0,pi],150)              
    title('3D')
    shading interp
    
    %--------------------
    % Calculations
    %--------------------
    
        % Zeros Calculations
        %--------------------
        %zeros_AF=zeros_AF(AF)
    
%------------------------------------------------------        
%               End 1-D Array
%------------------------------------------------------        

else

%------------------------------------------------------        
%                   2-D Array
%------------------------------------------------------    

    %--------------------
    % 2-D Array Inputs
    %--------------------
    % n_x       : number of elements along the x-axis
    % n_y       : number of elements along the y-axis 
    % dn_x      : normalized spacing along the x-axis
    % dn_y      : normalized spacing along the y-axis
    % theta_m   : angle of maximum radiation
    % phi_m     : angle of maximum radiation
    % type      : array type 
  
    
    h_n_x=findobj(gcbf,'tag','no_elem_x');
    n_x=str2num(get(h_n_x,'string'));                     

    h_n_y=findobj(gcbf,'tag','no_elem_y');
    n_y=str2num(get(h_n_y,'string'));

    h_dn_x=findobj(gcbf,'tag','spacing_x');
    dn_x=str2num(get(h_dn_x,'string'));                     

    h_dn_y=findobj(gcbf,'tag','spacing_y');
    dn_y=str2num(get(h_dn_y,'string')); 
    
    h_theta_m=findobj(gcbf,'tag','theta_m');
    theta_m=str2num(get(h_theta_m,'string'));
    
    h_phi_m=findobj(gcbf,'tag','phi_m');
    phi_m=str2num(get(h_phi_m,'string'));
    
    h_type=findobj(gcbf,'tag','type_list');
    type=get(h_type,'value');                  
  
  
    
    % Determine beta(progressive phase)
    
    beta_x=-2*pi*dn_x*sin(theta_m)*cos(phi_m);
    beta_y=-2*pi*dn_x*sin(theta_m)*sin(phi_m);
    
    epsi_x=2*pi*dn_x*sin(theta)*cos(phi)+beta_x;
    epsi_y=2*pi*dn_y*sin(theta)*sin(phi)+beta_y;
    
    switch type
    
        case 1
        % Call planer array function, will return AF
        %------------------------------------------------------
            AF=pl_array(n_x,n_y,dn_x,dn_y,epsi_x,epsi_y);       
   
        case 2
        % Call circular array function, will return AF
        %------------------------------------------------------
            AF=cir_array(n);      
           
    end
    
    %--------------------
    % Plot
    %--------------------
    warning off
    figure
    x= AF*sin(theta)*cos(phi);
    y= AF*sin(theta)*sin(phi);
    z= AF*cos(theta);
    ezsurf(x,y,z,[0,2*pi,0,pi],150)              
    title('3D')
    shading interp
    
%------------------------------------------------------        
%                   2-D Array
%------------------------------------------------------   

end


%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function AF=lin_array(n,dn,theta_m,epsi,beta)

% Linear array                                
%------------------------------------------------------ 

AF= 1/n*sin(n/2*epsi)/sin(epsi/2);

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function AF=nlin_array(n,dn,theta_m,epsi,beta);

% Non-Linear array                                
%------------------------------------------------------ 

    
syms theta real    
u=pi*dn*cos(theta);

f1=mod(n,2);                % flag to no of elements

if f1==0        % n is even

    m=n/2;
    
    AF=0;
    for i=1:m
        h_a(i)=findobj(gcbf,'tag',strcat('a',num2str(i)));
        a(i)=str2num(get(h_a(i),'string')); 
        f(i)=a(i)*cos((2*i-1)*u);
        AF=AF+f(i);
    end
   

     
elseif f1==1     % n is odd
    
    m=(n-1)/2;
    AF=0;
    for i=1:m+1
        h_a(i)=findobj(gcbf,'tag',strcat('a',num2str(i)));
        a(i)=str2num(get(h_a(i),'string')); 
        f(i)=a(i)*cos(2*(i-1)*u);
        AF=AF+f(i);  
    end
    
end


%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function AF=bin_array(n,dn,theta_m,epsi,beta)

% Binomial array function  
%------------------------------------------------------


AF=cos(epsi/2)^(n-1);


%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function AF=tsch_array(n,dn,theta_m,R0_dB,epsi,beta);

% Tschebysceff array function  
%------------------------------------------------------

theta0=deg2rad(theta_m);

% Initialization
%--------------------
syms theta u real;                    % theta,u,a is variables type real

% u=pi*dn*cos(theta);

% Calculation
%--------------------

 
R0_VR=10^(R0_dB/20);         % R0 as a voltage ratio

p=n-1 ;                      % Tschebysceff polynomial order

z0=cosh(1/p*acosh(R0_VR));   %

a=ex_coeff(n,z0);            % Excitation coefficients , Array factor

f=1+0.636*(2/R0_VR*cosh(sqrt(acosh(R0_VR)^2-pi^2)))^2;
                             % Beam broadening factor
                            
HPBW=rad2deg(acos(cos(theta0)-2.782/(n*2*pi*dn))-acos(cos(theta0)+2.782/(n*2*pi*dn)));
                            % HPBW of a linear array
      
HPBW_Tsch=HPBW*f;           % HPBW of a tschebysceff array

dn_max=1/pi*acos(-1/z0);    % Max spacing

D0=2*R0_VR^2/(1+(R0_VR^2-1)*f/(n*dn));
                            % Directivity 

D0_dB=10*log10(D0);         % Directivity in dB

Minor_lobes=n-2;            % No of minor lobes 0<theta<90

an=a/a(length(a));          % Normalized excitatiom coefficients

AF=AF_Tsch(n,dn,theta_m,beta,an);         % Array factor

%--------------------------------------------------------------------------------------------

function a=ex_coeff(n,z0)


% exitation coefficients calculation

f1=mod(n,2);                % flag to no of elements


if f1==0        % n is even
   
    m=n/2;
    
    for i=1:m
        a(i)=0;
        for q=i:m
            aq(q)=(-1)^(m-q)*z0^(2*q-1)*factorial(q+m-2)*(2*m-1)/(factorial(q-i)*factorial(q+i-1)*factorial(m-q));
            a(i)=a(i)+aq(q);    
        end    
    end

     
elseif f1==1     % n is odd
    
    m=(n+1)/2;
    
    if n==1
        en=2;
    else
        en=1;
    end
    
    for i=1:m
        a(i)=0;
        for q=i:m 
           aq(q)=(-1)^(m-q)*z0^(2*(q-1))*factorial(q+m-3)*(2*(m-1))/(en*factorial(q-i)*factorial(q+i-2)*factorial(m-q));
           a(i)=a(i)+aq(q);      
        end
    end    
end



%--------------------------------------------------------------------------------------------

function AF=AF_Tsch(n,dn,theta_m,beta,an)


% Initialization
%----------------
syms  theta u real;                    % theta,u,a is variables type real


u=pi*dn*cos(theta)+beta/2;
AF=0;


% Array factor printing

f1=mod(n,2);                % flag to no of elements


if f1==0        % n is even
    m=n/2;
    for i=1:m
        AF_even(i)=vpa(an(i),5)*cos((2*i-1)*u);
        AF=AF+AF_even(i);
    end

     
elseif f1==1     % n is odd
    m=(n+1)/2;
    for i=1:m
        AF_odd(i)=vpa(an(i),5)*cos(2*(i-1)*u);
        AF=AF+AF_odd(i);
    end    
end

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function AF=pl_array(n_x,n_y,dn_x,dn_y,epsi_x,epsi_y); 

% planar array                                
%------------------------------------------------------ 


AF=(1/n_x*sin(n_x/2*epsi_x)/sin(1/2*epsi_x))*(1/n_y*sin(n_y/2*epsi_y)/sin(1/2*epsi_y));



%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                                  End of Main Array Function
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                                  Array Calculations Functions
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function zeros_AF=zeros_AF(AF)    

% Zeros of Array Factor Calculatioms
%------------------------------------------------------

zeros_AF=vpa(solve(char(AF),'theta')*180/pi,5);
i=1;
while i<=length(zeros_AF)
    if isreal(zeros_AF(i))==0
       zeros_AF(i)=[];
    else
        i=i+1;
    end
end


%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                              End of Array Calculations Function
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------


%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                                    Array Control Functions
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------


function array_ctrl(h2)

switch h2
    
    case 0
        ctrl_dim        % Array dimension control 
        
    case 1
        ctrl_type       % Array type control               
    
    case 2
        ctrl_config     % Array configuration control
        
    
end

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function ctrl_dim    

% Array dimension control
%------------------------------------------------------  

h_dim=findobj(gcbf,'tag','array_dim');
dim=get(h_dim,'value');  
h_type=findobj(gcbf,'tag','type_list');
h_config=findobj(gcbf,'tag','config_list');

% Default
%--------------------
set(h_config,'enable','on');

if dim==1

    set(h_type,'string', {'Linear Array (Uniform Spacing & Amplitude)'...
    'Linear Array (Uniform Spacing & Non Uniform Amplitude)'...
    'Linear Array (Binomial Array)'...
    'Linear Array (Dolph-Tscebyscheff Array)'},'value',1);
     
else

    set(h_type,'string',{'Planar Array' },'value',1 );
    set(h_config,'enable','off');
    
end
ctrl_type

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function ctrl_type    

% Array type control
%------------------------------------------------------        

h_dim=findobj(gcbf,'tag','array_dim');
dim=get(h_dim,'value');  

h_type=findobj(gcbf,'tag','type_list');
type=get(h_type,'value');   

h_config=findobj(gcbf,'tag','config_list');

h_no_elem_ok=findobj(gcbf,'tag','no_elem_ok');

h_n=findobj(gcbf,'tag','no_elem');
h_dn=findobj(gcbf,'tag','spacing');
h_theta_m=findobj(gcbf,'tag','theta_m');
h_phi_m=findobj(gcbf,'tag','phi_m');
h_n_x=findobj(gcbf,'tag','no_elem_x');
h_n_y=findobj(gcbf,'tag','no_elem_y');
h_dn_x=findobj(gcbf,'tag','spacing_x');
h_dn_y=findobj(gcbf,'tag','spacing_y');
h_R0_dB=findobj(gcbf,'tag','R0');

h_n_x_str=findobj(gcbf,'tag','n_x_str');
h_dn_x_str=findobj(gcbf,'tag','dn_x_str');
h_dn_y_str=findobj(gcbf,'tag','dn_y_str');
h_R0_str=findobj(gcbf,'tag','R0_str');
h_theta_m_str=findobj(gcbf,'tag','theta_m_str');
h_phi_m_str=findobj(gcbf,'tag','phi_m_str');



h_a(1)=findobj(gcbf,'tag','a1');
h_a(2)=findobj(gcbf,'tag','a2');
h_a(3)=findobj(gcbf,'tag','a3');
h_a(4)=findobj(gcbf,'tag','a4');
h_a(5)=findobj(gcbf,'tag','a5');
h_a(6)=findobj(gcbf,'tag','a6');
h_a(7)=findobj(gcbf,'tag','a7');
h_a(8)=findobj(gcbf,'tag','a8');
h_a(9)=findobj(gcbf,'tag','a9');
h_a(10)=findobj(gcbf,'tag','a10');

h_a_str(1)=findobj(gcbf,'tag','a1_str');
h_a_str(2)=findobj(gcbf,'tag','a2_str');
h_a_str(3)=findobj(gcbf,'tag','a3_str');
h_a_str(4)=findobj(gcbf,'tag','a4_str');
h_a_str(5)=findobj(gcbf,'tag','a5_str');
h_a_str(6)=findobj(gcbf,'tag','a6_str');
h_a_str(7)=findobj(gcbf,'tag','a7_str');
h_a_str(8)=findobj(gcbf,'tag','a8_str');
h_a_str(9)=findobj(gcbf,'tag','a9_str');
h_a_str(10)=findobj(gcbf,'tag','a10_str');

% Default
%--------------------
set(h_config,'enable','on');

set(h_no_elem_ok,'visible','off');

set(h_n,'visible','on');
set(h_dn,'visible','on');
set(h_theta_m,'visible','on','enable','off');
set(h_phi_m,'visible','off');
set(h_n_x,'visible','off');
set(h_dn_x,'visible','off');
set(h_n_y,'visible','off');
set(h_dn_y,'visible','off');
set(h_R0_dB,'visible','off','string','20');

set(h_a(1),'visible','off');
set(h_a(2),'visible','off');
set(h_a(3),'visible','off');
set(h_a(4),'visible','off');
set(h_a(5),'visible','off');
set(h_a(6),'visible','off');
set(h_a(7),'visible','off');
set(h_a(8),'visible','off');
set(h_a(9),'visible','off');
set(h_a(10),'visible','off');


set(h_n_x_str,'string','No of Elements');
set(h_dn_x_str,'string','Normalized Spacing');
set(h_R0_str,'string','R0_dB','visible','off');
set(h_dn_y_str,'string','y_Spacing','visible','off');
set(h_theta_m_str,'visible','on');
set(h_phi_m_str,'visible','off');
set(h_R0_str,'visible','off');

set(h_a_str(1),'visible','off');
set(h_a_str(2),'visible','off');
set(h_a_str(3),'visible','off');
set(h_a_str(4),'visible','off');
set(h_a_str(5),'visible','off');
set(h_a_str(6),'visible','off');
set(h_a_str(7),'visible','off');
set(h_a_str(8),'visible','off');
set(h_a_str(9),'visible','off');
set(h_a_str(10),'visible','off');


if dim==1
    switch type
        
        case 2      % Non-Linear Array
            
            set(h_config,'enable','off');
            
            set(h_no_elem_ok,'visible','on');

            h_n=findobj(gcbf,'tag','no_elem');
            n=str2num(get(h_n,'string')); 
            
            try
                
                f1=mod(n,2);    % flag to the number of inputs 
            
                if f1==0        % n is even
                m=n/2;
                    for i=1:m
                        set(h_a_str(i),'visible','on');
                        set(h_a(i),'visible','on');
                    end

     
                elseif f1==1     % n is odd
                m=(n-1)/2;
                    for i=1:m+1
                        set(h_a_str(i),'visible','on');
                        set(h_a(i),'visible','on');
                    end    
                end
                
            catch
                if n>20
                errordlg('Number of inputs is limited to 20');
                end
            end
        
            
            
        case 4
            set(h_R0_dB,'visible','on','string','20');
            set(h_R0_str,'visible','on');
            
            
    end
    
else
    switch type
        
        case 1
            set(h_config,'enable','off');
            set(h_n,'visible','off');
            set(h_dn,'visible','off');
            set(h_theta_m,'enable','on');
            set(h_phi_m,'visible','on');
            set(h_n_x,'visible','on');
            set(h_dn_x,'visible','on');
            set(h_n_y,'visible','on');
            set(h_dn_y,'visible','on');
        
            set(h_n_x_str,'string','No of x_Elements');
            set(h_dn_x_str,'string','x_Spacing');
            set(h_R0_str,'string','No of y_Elements','visible','on');
            set(h_dn_y_str,'string','y_Spacing','visible','on');
            set(h_phi_m_str,'visible','on');
    end
end
        

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------

%------------------------------------------------------
function ctrl_config    

% Array configuration control
%------------------------------------------------------        
    
h_config=findobj(gcbf,'tag','config_list');
config=get(h_config,'value'); 

h_theta_m=findobj(gcbf,'tag','theta_m');
theta_m=str2num(get(h_theta_m,'string'));              % theta_m:     angle of maximum radiation

switch config
    case 1  
           set(h_theta_m,'string','90','enable','off');
    case 2
           set(h_theta_m,'string','0','enable','off');
    case 3
           set(h_theta_m,'string','180','enable','off');
    case 4
           set(h_theta_m,'string','0','enable','off');
    case 5
           set(h_theta_m,'string','180','enable','off');
    case 6
           set(h_theta_m,'enable','on');
           
 end

%--------------------------------------------------------------------------------------------
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                               End of Array Control Functions
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%--------------------------------------------------------------------------------------------


