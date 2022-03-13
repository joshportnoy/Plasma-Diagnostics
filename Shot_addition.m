%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initial image processing for Tomography_loop                             %
%                                                                         %
%Adds up n images and crops to an roi of 'final_width', centered          %
%around max longitudinal pixel intensity. Also adds 2D median filter of   %
%size f.                                                                  %
%                                                                         %
%Requires input of image directory and first image number in a sequential %
%set of photos.                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% INPUT%%%%%%%%
%Single Folder location for all images to be added
Folder = 'C:\Users\My LENOVO\Documents\MATLAB\Plasma Photos\Plasma\1902010008';
%First File name in Folder
first_file = '17583372_1902010008_0000';

n = 99;    %Desired number of photos to add(Must not exceed folder contents)
f = 7;     %Desired filter size

initial_width = 500;    %image width for saving memory while loading MUST BE LESS THAN 768(x/y axis for 3D Reconstruction/y for 2D)
final_width = 300;   %Final crop width
%%%%%%%%%%%%%%%%%%%%%%


%Fixed Variables for cropping and loop operations
L = strlength(first_file);  %File name length
i = str2num(first_file(L-1:L)); %File name index for loop
Plasma_multishots = zeros(initial_width,2048,'uint64');

pixel_size = 6.19;

r = (initial_width-1)/2;    %image radius from center
r2 = (final_width-1)/2;   %Final Image radius

%%%%Initial Centeral Axis Finder%%%%%%
plasma = imread(fullfile(Folder,strcat(first_file,'.tiff')));
plasma = medfilt2(plasma,[3,3]);
left_slice1 = imcrop(plasma,[f 0 0 1944]);       %Leftmost Pixel Slice
right_slice1 = imcrop(plasma,[2048-2*f 0 0 1944]);   %Rightmost Pixel Slice   
left_max1 = max(max(left_slice1));
right_max1 = max(max(right_slice1));
left_index1 = round(mean(find(left_slice1 == left_max1)));    %Left Max pixel Location
right_index1 = round(mean(find(right_slice1 == right_max1))); %Right Max pixel Location
center = round((left_index1+right_index1)/2);

%%%Reading and Adding n Cropped Images%%%%%%
if n<=10
    while i < n
    File = strcat(first_file(1:L-1),num2str(i),'.tiff');
    Plasmashot = uint64(imread(fullfile(Folder,File),'PixelRegion',{[center-r,center+r],[0,2048]}));
    Plasma_multishots = Plasma_multishots + Plasmashot;
    i = i + 1;
    end
elseif n<=100
    while i < 10
    File = strcat(first_file(1:L-1),num2str(i),'.tiff');
    Plasmashot = uint64(imread(fullfile(Folder,File),'PixelRegion',{[center-r,center+r],[0,2048]}));
    Plasma_multishots = Plasma_multishots + Plasmashot;
    i = i + 1;
    end
    while i < n
    File = strcat(first_file(1:L-2),num2str(i),'.tiff');
    Plasmashot = uint64(imread(fullfile(Folder,File),'PixelRegion',{[center-r,center+r],[0,2048]}));
    Plasma_multishots = Plasma_multishots + Plasmashot;
    i = i + 1;
    end
elseif n<=1000
    while i < 10
    File = strcat(first_file(1:L-1),num2str(i),'.tiff');
    Plasmashot = uint64(imread(fullfile(Folder,File),'PixelRegion',{[center-r,center+r],[0,2048]}));
    Plasma_multishots = Plasma_multishots + Plasmashot;
    i = i + 1;
    end
    while i < 100
    File = strcat(first_file(1:L-2),num2str(i),'.tiff');
    Plasmashot = uint64(imread(fullfile(Folder,File),'PixelRegion',{[center-r,center+r],[0,2048]}));
    Plasma_multishots = Plasma_multishots + Plasmashot;
    i = i + 1;
    end
    while i < n
    File = strcat(first_file(1:L-3),num2str(i),'.tiff');
    Plasmashot = uint64(imread(fullfile(Folder,File),'PixelRegion',{[center-r,center+r],[0,2048]}));
    Plasma_multishots = Plasma_multishots + Plasmashot;
    i = i + 1;
    end
end

%%%%Final Centeral Axis Finder%%%%%%
left_slice2 = imcrop(plasma,[f 0 0 initial_width]);       %Leftmost Pixel Slice
right_slice2 = imcrop(plasma,[2048-2*f 0 0 initial_width]);   %Rightmost Pixel Slice   
left_max2 = max(max(left_slice2));
right_max2 = max(max(right_slice2));
left_index2 = round(mean(find(left_slice2 == left_max2)));    %Left Max pixel Location
right_index2 = round(mean(find(right_slice2 == right_max2))); %Right Max pixel Location
center2 = round((left_index2+right_index2)/2);

Plasma_multishots = imcrop(Plasma_multishots,[0 center2-r2 2048 final_width-1]);

%%%%Median Filtering%%%%%
Plasma_multishots = double(Plasma_multishots)/65535;
filteredPlasmashots = medfilt2(Plasma_multishots,[f,f]);

PlasmaMin = min(min(filteredPlasmashots));
PlasmaMax = max(max(filteredPlasmashots));


%%%%%%%Deviation Angle Code%%%%%%%%%%%%%%%%%%%
%Take Single Pixel Slice from Left and Rightmost sides of image
left_slice = imcrop(filteredPlasmashots,[f 0 0 final_width]);
right_slice = imcrop(filteredPlasmashots,[2048-2*f 0 0 final_width]);

%Find Max Pixel intensity location at each edge strip
left_max = max(max(left_slice));
right_max = max(max(right_slice));
left_index = mean(find(left_slice == left_max));
right_index = mean(find(right_slice == right_max));
%Average the locations to find central axis
center_filtered = round((left_index+right_index)/2);

%Trig to find angle of deviation based on left and righttmost intensity
%position
h = left_index - right_index;
w = 2048-2*f;
deviation_angle = 90-abs(atand(w/h));

%%%%%RMS Deviation%%%%%%%
z=f;
z_max = 2048-2*f;
index_matrix=[];
%loop to find max intensity position for each strip along longitudinal axis
while z < z_max
    slice = imcrop(filteredPlasmashots,[z 0 0 final_width]);
    slice_max = max(max(slice));
    slice_index = round(mean(find(slice == slice_max)));
    
    index_matrix = cat(1,index_matrix,slice_index);
    z = z+1;
end
%RMS determined based on deviation from centerline calculated above
max(index_matrix);
index_matrix;
rms_deviation = pixel_size*rms((index_matrix-center_filtered));

%%%%%%%Figure%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
imshow(filteredPlasmashots)
colormap('jet');
colorbar;
caxis([PlasmaMin, PlasmaMax]);
Ratio_MaxMin = PlasmaMax/PlasmaMin;
caption = sprintf('Shots: %d, Filter: %d, Angle: %f °, RMS Deviation: %f µm', n, f,deviation_angle, rms_deviation);
title(caption, 'FontSize', 20);