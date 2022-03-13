%RUN SHOT_ADDITION FIRST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Shot_addition code may be Copy/Pasted here. However,                     %
%due to length of tomographic_loop execution, kept seperate.              %
%                                                                         %
%Utilizing the processed image data from shot_addition in the Workspace,  %
%this code creates single pixel width strips to analyze as projection data%
%and apply an inverse randon transform around 90 projection angles.       %
%The resulting 2D slices are then concatenated as a loop applies this     %
%procedure to each strip along the longitudinal length of the plasma image%
%3D isosurfaces are created from the final concatenated matrices for      %
%intensity contours at 25%,50%, and 75%.                                  %
%                                                                         %
%WARNING TAKES ~11min to execute.                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pixel_size = 6.19;      %resolved pixel size

i = 1;
i_max = 2048-2*f;     %number of slices
z = 1;     %starting z coordinate
f3d = 7;    %3D FILTER SIZE
Slice_matrix=[];
pstrip=[];
R=[];
theta=[];
I=[];

while i < i_max+1
    %Image Strip Selection
    Plasma = imcrop(filteredPlasmashots,[z 0 0 final_width]);
    pstrip = (Plasma(:,:,1));
    
    %Setup Projection data/angle matrix
    R = repmat( pstrip, [1,90]);
    theta = 0:2:178;

    %Inverse Radon Reconstruction
    I = iradon(R,theta,'linear','Hann');
    Slice_matrix=cat(3,Slice_matrix,I);
      i= i+1;
      z= z+1;
end

%3D Median Filtering and Cropping Filter Boundary Effects
filtered_matrix=medfilt3(Slice_matrix,[f3d,f3d,f3d]);
sz1 = size(filtered_matrix,1);
sz2 = size(filtered_matrix,2);
sz3 = size(filtered_matrix,3);
half_f3d = round(f3d/2);
filtered_matrix = filtered_matrix(half_f3d:sz1-half_f3d, half_f3d:sz2-half_f3d, half_f3d:sz3-half_f3d);

%Calculating 25%, 50%, 75% Contours
Max = max(max(max(filtered_matrix)));
Contour_25 = Max*(0.25);
Contour_50 = Max*(.50);
Contour_75 = Max*(.75);

%3D Isosurface for 25% and 50% Contours
f2 = figure(2);
fv1 = patch((isosurface(filtered_matrix,Contour_25)));
set(fv1,'FaceColor','blue','EdgeColor','none','FaceAlpha',0.2);
fv2 = patch((isosurface(filtered_matrix,Contour_50)));
set(fv2,'FaceColor','magenta','EdgeColor','none','FaceAlpha',0.3);
caption2 = sprintf('25/50 Contours, Shots: %d, 2DFilter: %d, 3DFilter: %d', n,f, f3d);
title(caption2, 'FontSize', 12);
%Axis Info
axis on
 xticks(20:final_width/2-20:final_width/2)
 xticklabel = string(round(pixel_size*linspace(0,final_width/2,2)));
 xticklabels(xticklabel)
 xtickangle(-45)
 zticks(0:final_width/2:final_width/2)
 zticklabel = string(round(pixel_size*linspace(0,final_width/2,2)));
 zticklabels(zticklabel)
 %ztickangle(45)
 ylim([0 2048])
 yticks(0:256:2048)
 yticklabel = string(round(pixel_size*linspace(2048,0,9)));
 yticklabels(yticklabel)
 camlight
lighting gouraud
daspect([1 1 1])   %Aspect Ratio
%Camera Angle Manipulation
rotate_direction = [1 0 0];
rotate(fv2,rotate_direction,90)
rotate(fv1,rotate_direction,90)
view(3)

%3D Isosurface for 50% and 75% Contours
f3= figure(3);
fv1 = patch((isosurface(filtered_matrix,Contour_50))); % 50% Contour
set(fv1,'FaceColor','magenta','EdgeColor','none','FaceAlpha',0.2);
fv2 = patch((isosurface(filtered_matrix,Contour_75)));
set(fv2,'FaceColor','red','EdgeColor','none','FaceAlpha',0.3); % 75%Contour
caption3 = sprintf('50/75 Contours, Shots: %d, 2DFilter: %d, 3DFilter: %d', n,f, f3d);
title(caption3, 'FontSize', 12);
%Axis Info
axis on
 xticks(20:final_width/2-20:final_width/2)
 xticklabel = string(round(pixel_size*linspace(0,final_width/2,2)));
 xticklabels(xticklabel)
 xtickangle(-45)
 zticks(0:final_width/2:final_width/2)
 zticklabel = string(round(pixel_size*linspace(0,final_width/2,2)));
 zticklabels(zticklabel)
 %ztickangle(45)   %If ticks need to be tilted for visuals
 ylim([0 2048])
 yticks(0:256:2048)
 yticklabel = string(round(pixel_size*linspace(2048,0,9)));
 yticklabels(yticklabel)
camlight
lighting gouraud
daspect([1 1 1])   %Aspect Ratio
%Camera Angle Manipulation
rotate(fv2,rotate_direction,90)
rotate(fv1,rotate_direction,90)
view(3)
