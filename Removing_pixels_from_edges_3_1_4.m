%Removing points that come from edges of images, which cause wave-live
%patterns. These should be removed as they should not be used for
%generating SIFT points.

rgb = office{1}.Color; % Extracting the colour data
points = office{1}.Location; % Extracting the xyz data

%%
pc = pointCloud(points, 'Color', rgb);
color_pc = rgb;

%% Extracting the r, g, b colours
    r = color_pc(:,1);
    g = color_pc(:,2);
    b = color_pc(:,3);

%% reshaping each array (r, g, b) to obtain a [512x424] matrix 
    rec_r = reshape(r, [640, 480]);
    rec_g = reshape(g, [640, 480]);
    rec_b = reshape(b, [640, 480]);
    new_rgb = cat(3, rec_r', rec_g', rec_b');

%%eEliminate regions in the rgb image 
%left side
new_rgb(:,1:60,1)=255;
new_rgb(:,1:60,2)=255;
new_rgb(:,1:60,3)=255;

%right side
new_rgb(:,580:640,1)=255;
new_rgb(:,580:640,2)=255;
new_rgb(:,580:640,3)=255;

%% Extracting the x y and z
x = points(:,1);
y = points(:,2);
z = points(:,3);
    
%%
rec_x = reshape(x, [640, 480]);
rec_y = reshape(y, [640, 480]);
rec_z = reshape(z, [640, 480]);
new_xyz = cat(3, rec_x', rec_y', rec_z');

    
%% Eliminate regions in the xyz  
new_xyz(:,1:60,1)=0;
new_xyz(:,1:60,2)=0;
new_xyz(:,1:60,3)=0;
   
new_xyz(:,580:640,1)=0;
new_xyz(:,580:640,2)=0;
new_xyz(:,580:640,3)=0;
   
pc_new = pointCloud(new_xyz, 'Color', new_rgb); % Creating a point-cloud variable

figure(1)
pcshow(pc_new)
figure(2)
imshow(new_rgb) 
