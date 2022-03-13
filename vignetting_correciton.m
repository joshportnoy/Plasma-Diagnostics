%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This code calculates a background subtraction utilizing n background     %
%and plasma images in the input directories, and applies a vignetting     %
%correction based on an input vignetting curve for the camera setup in use%
%                                                                         %
%This requires input of both the folder locations, first image numbers    %
%of the sequential images to be analyzed, number of photos n to analyze,  %
%as well as the specific vignetting curve polynomial equation.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%% INPUT%%%%%%%%%%%%
%Single Folder location for all background images to be added
background_Folder = 'C:\Users\My LENOVO\Pictures\Wide Angle Vignetting\Background_Argon';
%First File name in background Folder
background_first_file = '17529184_1908140001_0000';

%Single Folder location for all Plasma images to be added
plasma_Folder = 'C:\Users\My LENOVO\Pictures\Wide Angle Vignetting\Argon_5e16_t2';
%First File name in background Folder
plasma_first_file = '17529184_1908140004_0000';

n= 5; %number of shots taken

angle=0;   % Place holder
vignetting_equation = (-316.67174834*angle^2 + 6005.19794325*angle + 11725.45230396)*(2.26897/1.3013)*10^-4;
%must be a function of variable 'angle'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Adding Background Images%%%%%%
L1 = strlength(background_first_file);  %Background File name length
i = str2num(background_first_file(L1-1:L1)); %background File name index for loop
background = zeros(2048,2448,'uint32');
if n<=10
    while i < n
        background_File = strcat(background_first_file(1:L1-1),num2str(i),'.tiff');
        backgroundshot = uint32(imread(fullfile(background_Folder,background_File)));
        background = background + backgroundshot;
        i = i + 1;
    end
elseif n<=100
    while i < 10
        background_File = strcat(background_first_file(1:L1-1),num2str(i),'.tiff');
        backgroundshot = uint32(imread(fullfile(background_Folder,background_File)));
        background = background + backgroundshot;
        i = i + 1;
    end
    while i < n
        background_File = strcat(background_first_file(1:L1-2),num2str(i),'.tiff');
        backgroundshot = uint32(imread(fullfile(background_Folder,background_File)));
        background = background + backgroundshot;
        i = i + 1;
    end
elseif n<=1000
    while i < n
        background_File = strcat(background_first_file(1:L1-1),num2str(i),'.tiff');
        backgroundshot = uint32(imread(fullfile(background_Folder,background_File)));
        background = background + backgroundshot;
        i = i + 1;
    end
    while i < 100
        background_File = strcat(background_first_file(1:L1-2),num2str(i),'.tiff');
        backgroundshot = uint32(imread(fullfile(background_Folder,background_File)));
        background = background + backgroundshot;
        i = i + 1;
    end
    while i < n
        background_File = strcat(background_first_file(1:L1-3),num2str(i),'.tiff');
        backgroundshot = uint32(imread(fullfile(background_Folder,background_File)));
        background = background + backgroundshot;
        i = i + 1;
    end
end

%%%ADDING Plasma Photos%%%%
L2 = strlength(plasma_first_file);  %Plasma File name length
i = str2num(plasma_first_file(L2-1:L2)); %background File name index for loop
plasma_raw = zeros(2048,2448,'uint32');
if n<10
    while i < n
        plasma_File = strcat(plasma_first_file(1:L2-1),num2str(i),'.tiff');
        plasmashot = uint32(imread(fullfile(plasma_Folder,plasma_File)));
        plasma_raw = plasma_raw + plasmashot;
        i = i + 1;
    end
elseif n<100
     while i < 10
        plasma_File = strcat(plasma_first_file(1:L2-1),num2str(i),'.tiff');
        plasmashot = uint32(imread(fullfile(plasma_Folder,plasma_File)));
        plasma_raw = plasma_raw + plasmashot;
        i = i + 1;
     end
     while i < n
        plasma_File = strcat(plasma_first_file(1:L2-2),num2str(i),'.tiff');
        plasmashot = uint32(imread(fullfile(plasma_Folder,plasma_File)));
        plasma_raw = plasma_raw + plasmashot;
        i = i + 1;
     end
elseif n<1000
     while i < 10
        plasma_File = strcat(plasma_first_file(1:L2-1),num2str(i),'.tiff');
        plasmashot = uint32(imread(fullfile(plasma_Folder,plasma_File)));
        plasma_raw = plasma_raw + plasmashot;
        i = i + 1;
     end
     while i < 100
        plasma_File = strcat(plasma_first_file(1:L2-2),num2str(i),'.tiff');
        plasmashot = uint32(imread(fullfile(plasma_Folder,plasma_File)));
        plasma_raw = plasma_raw + plasmashot;
        i = i + 1;
     end
     while i < n
        plasma_File = strcat(plasma_first_file(1:L2-3),num2str(i),'.tiff');
        plasmashot = uint32(imread(fullfile(plasma_Folder,plasma_File)));
        plasma_raw = plasma_raw + plasmashot;
        i = i + 1;
     end
    
end

fontSize = 16; 

a=1;   %set value to increase background subtraction
plasma = plasma_raw - background*a;


    subplot(1, 2, 1);
  imshow(uint32(plasma), []);  % Display image.
  caption = sprintf('Plasma with Background Subtraction');
  title(caption, 'FontSize', fontSize)
colormap(jet);
colorbar;

backgroundImage = (zeros(2048, 2448,'uint32')); % Preallocate.
  centerX = 2448/2;
  centerY = 2048/2;
  focalLength = 3478.26; % Units of pixels. (12mm FL/3.45micron pixel size)
  % NOTE: if the focal length is given in units of mm, then the rows and columns of the image 
  % must be given in terms of mm along the imaging sensor in the camera.
  for col = 1 : 2448
    for row = 1 : 2048
      radius = sqrt((col-centerX)^2 + (row-centerY)^2);
      angle = atan(radius/focalLength);  % Compute angle from optic axis.
        backgroundImage(row, col) = vignetting_equation;
    end
  end
  
  %Plasma correction application
  final_plasma = uint32(immultiply(plasma,backgroundImage));
  final_plasma = medfilt2(final_plasma,[3,3]);
  residual = final_plasma - plasma;
    subplot(1, 2, 2);
  imshow(final_plasma, []);  % Display image.
  colormap(jet);
  colorbar
  set(gcf, 'Units', 'Normalized', 'Position', [0, 0.05, 1, 0.85]); 
  caption = sprintf('Corrected Image');
  title(caption, 'FontSize', fontSize)