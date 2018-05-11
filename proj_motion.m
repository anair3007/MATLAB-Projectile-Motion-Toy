function varargout = proj_motion(varargin)
% PROJ_MOTION MATLAB code for proj_motion.fig
%      PROJ_MOTION, by itself, creates a new PROJ_MOTION or raises the existing
%      singleton*.
%
%      H = PROJ_MOTION returns the handle to a new PROJ_MOTION or the handle to
%      the existing singleton*.
%
%      PROJ_MOTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJ_MOTION.M with the given input arguments.
%
%      PROJ_MOTION('Property','Value',...) creates a new PROJ_MOTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before proj_motion_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to proj_motion_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help proj_motion

% Last Modified by GUIDE v2.5 24-Feb-2014 22:45:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @proj_motion_OpeningFcn, ...
                   'gui_OutputFcn',  @proj_motion_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before proj_motion is made visible.
function proj_motion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to proj_motion (see VARARGIN)

%Max Dimensions of Plot
plot_xmax = 110.;
plot_ymax = 60.;
axis equal;
axis( [0, plot_xmax, 0, plot_ymax ] );
title('Projectile Motion: Hit the Target','FontSize',12);
xlabel('x (meters)', 'FontSize',11);
ylabel('y (meters)','FontSize',11);

%Default Target Difficulty + Draw Target
set(handles.target_difficulty,'selectedobject',handles.easy);
target_width = 4.5; target_height = 4.5;

%Default Motion to none
set(handles.target_motion_button,'selectedobject',handles.none);
handles.fall=0;

handles.target_width = target_width;
handles.target_height = target_height;
handles.plot_ymax = plot_ymax;
handles.plot_xmax = plot_xmax;

% Choose default command line output for proj_motion
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

randomize_target(hObject, handles);
draw_target(hObject, handles);

% UIWAIT makes proj_motion wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = proj_motion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%- varargout{1} = handles.output;

function randomize_target(hObject, handles)
%Read updated handles structure
handles = guidata(hObject);
target_x = 29. + randi(71,1);
target_y = randi(55);
set(handles.display_targetx, 'String', target_x);
set(handles.display_targety, 'String', target_y);
handles.target_x = target_x;
handles.target_y = target_y;
%Save updated handles structure
guidata(hObject, handles);

function draw_target(hObject, handles)
%Read updated handles structure
handles = guidata(hObject);
target_xmin = handles.target_x - handles.target_width/2.;
target_ymin = handles.target_y - handles.target_height/2.;
handles.target = rectangle('Position',[target_xmin,target_ymin,...
    handles.target_width,handles.target_height],'FaceColor','r');
handles.target_xmin = target_xmin;
handles.target_ymin = target_ymin;
%Save updated handles structure
guidata(hObject, handles);

function controls_visibility(hObject, handles, x)
%Read updated handles structure
handles = guidata(hObject);
if x==1
    set(handles.pushbutton1, 'Enable', 'on');
    set(handles.randomize_target_button,'Enable', 'on');
    set( findall(handles.target_difficulty, '-property', 'Enable'), 'Enable', 'on');
    set( findall(handles.target_motion_button, '-property', 'Enable'), 'Enable', 'on');
    
elseif x==0
    set(handles.pushbutton1, 'Enable', 'off');
    set(handles.randomize_target_button,'Enable', 'off');
    set( findall(handles.target_difficulty, '-property', 'Enable'), 'Enable', 'off');
    set( findall(handles.target_motion_button, '-property', 'Enable'), 'Enable', 'off');
end
%Save updated handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)  
cla;
num_points = 112;
g = 9.81;

x = [];y = [];t = []; p = zeros(num_points);
x_init = 0; y_init = 0; t_init = 0;
x(1)=x_init;y(1)=y_init;t(1)=t_init;

handles.target_x = str2double(get(handles.display_targetx, 'String'));
handles.target_y = str2double(get(handles.display_targety, 'String'));

target_xmax = handles.target_x+handles.target_width/2.;
target_ymax = handles.target_y+handles.target_height/2.;

%Redraw Target
draw_target(hObject, handles);
handles = guidata(hObject);


%Check for Valid Input
if( isnan( str2double(get(handles.enter_velocity, 'String'))) || ...
    isnan( str2double(get(handles.enter_angle, 'String'))) )
    h = warndlg('Please recheck the VELOCITY (m/s) and ANGLE (degrees) you have entered. Only enter numbers and not the units.') 
    return;
elseif( str2double(get(handles.enter_angle, 'String'))>90 || ...
        str2double(get(handles.enter_angle, 'String'))<=0)
    h = warndlg('Make sure the angle value is a positive number between 0 and 90.') 
    return;        
else
    velocity = str2double(get(handles.enter_velocity, 'String'));
    theta = degtorad( str2double(get(handles.enter_angle, 'String')));
end


%t_end - full range
t_end_full = (2./g)*velocity*sin(theta);
%t_end - till edge of plot in either x or y
%in x direction, simple
t_end_x = (handles.plot_xmax+2)/(velocity*cos(theta));
%pick minimum of leaving x-axis or if it falls to ground
t_end = min(t_end_x,t_end_full) ;

dt = t_end/num_points;
%dt = 0.03;
%num_points = t_end/dt;
t_half = velocity*sin(theta)/g;
x_max = velocity*cos(theta)*t_end;
y_max = velocity*sin(theta)*t_half-0.5*g*t_half.^2;
    
hit = 0;
hold on;
for i = 1:num_points+1
    controls_visibility(hObject, handles, 0);
    handles = guidata(hObject);
    x(i) = velocity*cos(theta)*t(i);
    y(i) = velocity*sin(theta)*t(i)-0.5*g*t(i).^2;
    p(i) = plot(x(i),y(i),'b*','MarkerSize',8 );
    %Draw Trail of past points
    if i>1
        set( p(i-1), 'Marker', '.' , 'Color', [0.2, 0.2, 0.2], 'MarkerSize', 5 );
    end 
    
    if(handles.fall==0)
        %If not falling, don't do anything
    elseif(handles.fall==1)
        target_motion_tend = sqrt(  (2/g)*(handles.target_y-handles.target_height/2)  );
        handles.target_motion_num_points = round(target_motion_tend/dt);
        if(i<=(handles.target_motion_num_points+1))
            handles.target_y = handles.target_y-0.5*g*t(i).^2;
            
            handles.target_xmin = handles.target_x-handles.target_width/2.;
            handles.target_ymin = handles.target_y-handles.target_height/2.;
            target_xmax = handles.target_x+handles.target_width/2.;
            target_ymax = handles.target_y+handles.target_height/2.;
            set(handles.target, 'Position', [handles.target_xmin, handles.target_ymin, ...
                handles.target_width, handles.target_height]);
        elseif(i > (handles.target_motion_num_points+1))
            hit=0;
            break;
        end
    end
    
    %Successful Hit Detection
    if( x(i)>=handles.target_xmin && x(i)<=target_xmax ...
            && y(i)>=handles.target_ymin && y(i)<=target_ymax)
        hit = 1;
        set(handles.target, 'FaceColor','g' );
        text(55,40,'Target Hit!', 'FontSize', 50, 'HorizontalAlignment', 'center', ...
       'Color', 'green', 'BackgroundColor', [0.9,0.9,0.9], 'EdgeColor', 'black');
        break;
    end        
    %axis equal;
    t(i+1) = t(i)+dt;
    M(i)=getframe;
end
controls_visibility(hObject, handles, 1);
handles = guidata(hObject);
if(hit == 0)
   text(55,40,'You Missed...', 'FontSize', 50, 'HorizontalAlignment', 'center', ...
       'Color', 'blue', 'BackgroundColor', [0.9,0.9,0.9], 'EdgeColor', 'black');
   display(handles.target_y);
end

hold off;
handles.g = g;
handles.dt = dt;
guidata(hObject, handles);


% --- Executes on button press in randomize_target_button.
function randomize_target_button_Callback(hObject, eventdata, handles)
% hObject    handle to randomize_target_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla;
randomize_target(hObject, handles);
draw_target(hObject, handles);
handles = guidata(hObject);
guidata(hObject, handles);

% --- Executes when selected object is changed in target_difficulty.
function target_difficulty_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in target_difficulty 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'easy'
        handles.target_width =4.5; handles.target_height = 4.5;
    case 'medium'
        handles.target_width =3.; handles.target_height = 3.;
    case 'hard'    
        handles.target_width =1.5; handles.target_height = 1.5;
end
%Output handle data back into guidata
guidata(hObject, handles);
cla;
draw_target(hObject, handles);


% --- Executes when selected object is changed in target_motion_button.
function target_motion_button_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in target_motion_button 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'none'
        handles.fall=0;
    case 'falling'
        handles.fall=1;
end
guidata(hObject, handles);


function enter_angle_Callback(hObject, eventdata, handles)
% hObject    handle to enter_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_angle as text
%        str2double(get(hObject,'String')) returns contents of enter_angle as a double

% --- Executes during object creation, after setting all properties.
function enter_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function enter_velocity_Callback(hObject, eventdata, handles)
% hObject    handle to enter_velocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_velocity as text
%        str2double(get(hObject,'String')) returns contents of enter_velocity as a double


% --- Executes during object creation, after setting all properties.
function enter_velocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_velocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function display_targety_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_targety (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function display_targetx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_targetx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function randomize_target_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to randomize_target_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

