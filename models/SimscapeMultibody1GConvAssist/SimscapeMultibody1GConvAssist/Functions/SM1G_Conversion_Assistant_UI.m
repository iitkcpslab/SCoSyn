function varargout = SM1G_Conversion_Assistant_UI(varargin)
% SM1G_CONVERSION_ASSISTANT_UI MATLAB code for SM1G_Conversion_Assistant_UI.fig
%      SM1G_CONVERSION_ASSISTANT_UI, by itself, creates a new SM1G_CONVERSION_ASSISTANT_UI or raises the existing
%      singleton*.
%
%      H = SM1G_CONVERSION_ASSISTANT_UI returns the handle to a new SM1G_CONVERSION_ASSISTANT_UI or the handle to
%      the existing singleton*.
%
%      SM1G_CONVERSION_ASSISTANT_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SM1G_CONVERSION_ASSISTANT_UI.M with the given input arguments.
%
%      SM1G_CONVERSION_ASSISTANT_UI('Property','Value',...) creates a new SM1G_CONVERSION_ASSISTANT_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SM1G_Conversion_Assistant_UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SM1G_Conversion_Assistant_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SM1G_Conversion_Assistant_UI

% Last Modified by GUIDE v2.5 14-Nov-2014 13:09:39

% Copyright 2014-2019 The MathWorks Inc.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SM1G_Conversion_Assistant_UI_OpeningFcn, ...
    'gui_OutputFcn',  @SM1G_Conversion_Assistant_UI_OutputFcn, ...
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


% --- Executes just before SM1G_Conversion_Assistant_UI is made visible.
function SM1G_Conversion_Assistant_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SM1G_Conversion_Assistant_UI (see VARARGIN)

% Choose default command line output for SM1G_Conversion_Assistant_UI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SM1G_Conversion_Assistant_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

Srcfile.name = [];
Srcfile.path = [];
set(handles.SourceModel_edit,'UserData',Srcfile);

% --- Outputs from this function are returned to the command line.
function varargout = SM1G_Conversion_Assistant_UI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function SourceModel_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SourceModel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SourceModel_edit as text
%        str2double(get(hObject,'String')) returns contents of SourceModel_edit as a double


% --- Executes during object creation, after setting all properties.
function SourceModel_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SourceModel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GetSourceModel_pushbutton.
function GetSourceModel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GetSourceModel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mdl;*.slx','Models (*.slx, *.mdl)'}, 'Pick a file');

if(filename~=0)
    Srcfile.name = filename;
    Srcfile.path = pathname;
    [pathstr,name,ext] = fileparts(filename);
    
    set(handles.SourceModel_edit,'String',filename);
    set(handles.DestModel_edit,'String',[name '_2GBlks' ext]);
    
    set(handles.SourceModel_edit,'UserData',Srcfile);
end

function DestModel_edit_Callback(hObject, eventdata, handles)
% hObject    handle to DestModel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DestModel_edit as text
%        str2double(get(hObject,'String')) returns contents of DestModel_edit as a double


% --- Executes during object creation, after setting all properties.
function DestModel_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DestModel_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ReportType_menu.
function ReportType_menu_Callback(hObject, eventdata, handles)
% hObject    handle to ReportType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ReportType_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ReportType_menu


% --- Executes during object creation, after setting all properties.
function ReportType_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReportType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ReportFile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ReportFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ReportFile_edit as text
%        str2double(get(hObject,'String')) returns contents of ReportFile_edit as a double


% --- Executes during object creation, after setting all properties.
function ReportFile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReportFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReportOnly_checkbox.
function ReportOnly_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ReportOnly_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ReportOnly_checkbox

if(get(hObject,'Value'))
    set(handles.DestModel_edit,'Enable','off');
    set(handles.DestModel_text,'Enable','off');
else
    set(handles.DestModel_edit,'Enable','on');
    set(handles.DestModel_text,'Enable','on');
end

% --- Executes on button press in Run_pushbutton.
function Run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Src_mdl_str  = get(handles.SourceModel_edit,'String');
[Src_p, Src_mdl] = fileparts(Src_mdl_str);
if(isempty(Src_p))
    Srcfiledata=get(handles.SourceModel_edit,'UserData');
    Src_p=Srcfiledata.path;
end
Dst_mdl_str  = get(handles.DestModel_edit,'String');
[~, Dst_mdl] = fileparts(Dst_mdl_str);
report_only  = get(handles.ReportOnly_checkbox,'Value');
report_choice = get(handles.ReportType_menu, 'Value');

if(~isempty(Src_p))
    Src_mdl_full = [Src_p filesep Src_mdl];
else
    Src_mdl_full = Src_mdl;
end

if (report_only)
    if (report_choice==1)
        convertSM1G2G(Src_mdl_full)
    elseif (report_choice==2)
        convertSM1G2G(Src_mdl_full,'file')
    elseif (report_choice==3)
        convertSM1G2G(Src_mdl_full,'both')
    end
else
    if (report_choice==1)
        convertSM1G2G(Src_mdl_full,Dst_mdl)
    elseif (report_choice==2)
        convertSM1G2G(Src_mdl_full,Dst_mdl,'file')
    elseif (report_choice==3)
        convertSM1G2G(Src_mdl_full,Dst_mdl,'both')
    end
end


% --- Executes on button press in Help_pushbutton.
function Help_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Help_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('SM1G2G_Process_Help.html');
