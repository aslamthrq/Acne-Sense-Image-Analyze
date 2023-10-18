function varargout = tampilanDeteksiJerawat(varargin)
% TAMPILANDETEKSIJERAWAT MATLAB code for tampilanDeteksiJerawat.fig
%      TAMPILANDETEKSIJERAWAT, by itself, creates a new TAMPILANDETEKSIJERAWAT or raises the existing
%      singleton*.
%
%      H = TAMPILANDETEKSIJERAWAT returns the handle to a new TAMPILANDETEKSIJERAWAT or the handle to
%      the existing singleton*.
%
%      TAMPILANDETEKSIJERAWAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TAMPILANDETEKSIJERAWAT.M with the given input arguments.
%
%      TAMPILANDETEKSIJERAWAT('Property','Value',...) creates a new TAMPILANDETEKSIJERAWAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tampilanDeteksiJerawat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tampilanDeteksiJerawat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tampilanDeteksiJerawat

% Last Modified by GUIDE v2.5 11-Oct-2022 20:39:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tampilanDeteksiJerawat_OpeningFcn, ...
                   'gui_OutputFcn',  @tampilanDeteksiJerawat_OutputFcn, ...
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


% --- Executes just before tampilanDeteksiJerawat is made visible.
function tampilanDeteksiJerawat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tampilanDeteksiJerawat (see VARARGIN)
% Choose default command line output for tampilanDeteksiJerawat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes tampilanDeteksiJerawat wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tampilanDeteksiJerawat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.jpg;*.jpeg;*.png;*.tif');
 
try
    Img = imread(fullfile(pathname,filename));
    [~,~,m] = size(Img);
    if m == 3
        axes(handles.axes1)
        imshow(Img)
        handles.Img = Img;
        guidata(hObject, handles)
    end
catch
    msgbox('Please insert RGB Image')
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

citra=handles.Img;

%Resize Citra
    % Ukuran Citra Semula
[bar, kol, dlm] = size(citra);

if (bar > kol)
    maxLength = bar;
    if (maxLength >= 480);
        citra = imresize(citra, [480 NaN]);
    end;
else
    maxLength = kol;
    if (maxLength >= 480);
        citra = imresize(citra, [NaN 480]);
    end;
end;

%Segmentasi Kulit

citraG = rgb2gray(citra);
level = graythresh(citraG);

citraB = im2bw(citraG, level);
citraB = imfill(citraB, 'holes');

citraCC = bwconncomp(citraB);
citraL = labelmatrix(citraCC);


    % Ukuran Citra Setelah Resize
[bar, kol, dlm] = size(citra);
    % Cari Connected Component Terbanyak
terluas = 0;
for i = 1 : length(citraCC.PixelIdxList)
    if (length(citraCC.PixelIdxList{i})) > terluas
        terluas = length(citraCC.PixelIdxList{i});
        index = i;
    end;
end;

    % Ambil Label
wajah = uint8(zeros(bar, kol, dlm));
for i = 1 : bar
    for j = 1 : kol
        if citraL(i, j) == index;
            wajah(i, j, :) = citra(i, j, :);
        end;
    end;
end;

axes(handles.axes3);
imshow(wajah);

%Perbaikan Citra
    % Sharpening
wajahG = rgb2gray(wajah);
h = fspecial('log', [9 9], 2);
m = imfilter(wajahG, h, 'circular', 'same', 'conv');
    
    % Labeling
candidate = logical(m);
[labeledCandidate, numberOfCandidates] = bwlabel(candidate, 8);

axes(handles.axes4);
imshow(candidate);

%Ekstrasi Ciri Luas dan Bentuk

    % Eliminasi Berdasarkan Luas Dan Bentuk
blobMeasurements = regionprops(labeledCandidate, 'Area', 'Eccentricity');

allArea = [blobMeasurements.Area];
allEccentricity = [blobMeasurements.Eccentricity];

meanArea = mean(allArea);
stdArea = std(allArea);

indexBlob = find(allArea >= 24 & allArea <= (meanArea + stdArea) & allEccentricity < 0.81);

ambilBlob = ismember(labeledCandidate, indexBlob);
blobBW = ambilBlob > 0;
[labeledBlob, numberOfBlobs] = bwlabel(blobBW);

axes(handles.axes5);
imshow(blobBW);

%Ekstrasi Ciri Warna
    % Eliminasi Berdasarkan Warna
red = citra(:, :, 1);
green = citra(:, :, 2);
blue = citra(:, :, 3);

r = regionprops(labeledBlob, red, 'MeanIntensity');
g = regionprops(labeledBlob, green, 'MeanIntensity');
b = regionprops(labeledBlob, blue, 'MeanIntensity');

fiturR = [r.MeanIntensity]';
fiturG = [g.MeanIntensity]';
fiturB = [b.MeanIntensity]';
fitur = [fiturR fiturG fiturB];

meanR = mean(fiturR);
meanG = mean(fiturG);
meanB = mean(fiturB);
stdR = std(fiturR);
stdG = std(fiturG);
stdB = std(fiturB);

indexJerawat = [];
for i = 1 : numberOfBlobs
    if(fiturR(i) >= (meanR-stdR*1.75) && fiturR(i) <= (meanR+stdR*1.75) && fiturG(i) >= (meanG-stdG*1.75) && fiturG(i) <= (meanG+stdG*1.75) && fiturB(i) >= (meanB-stdB*1.75) && fiturB(i) <= (meanB+stdB*1.75))indexJerawat = [indexJerawat i];
    end;
end;

jumlahJerawat = length(indexJerawat);
jerawatBW = ismember(labeledBlob, indexJerawat);

axes(handles.axes6);
imshow(jerawatBW); 



%Marking

jerawatEdge = edge(jerawatBW, 'canny');
hasil = citra;

for i = 1 : bar
    for j = 1 : kol
        if jerawatEdge(i, j) == 1;
             hasil(i, j, 1) = 0;
             hasil(i, j, 2) = 255;
             hasil(i, j, 3) = 0;
        end;
    end;
end;


hasil = uint8(hasil);

axes(handles.axes2);
imshow(hasil);


print = strcat(num2str(jumlahJerawat),severity(jumlahJerawat));
disp(print);

function [stringOut] = severity(amount_acne)

Severity = {' Mild', ' Moderate', ' Severe', ' Very Severe'};

if(amount_acne<=5)
    i = 1;
else
    if(amount_acne<=20)
        i=2;
        else0
        if(amount_acne<=50)
            i=3;
        else
            i=4;
        end
    end
end

stringOut = Severity{i};
set(handles.edit1,'String',jumlahJerawat);




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
