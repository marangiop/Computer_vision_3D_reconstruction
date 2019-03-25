function[new_xyz, new_rgb, pc_final] = single_cleaning_function(frame_id)
%% loading stuff 
office = load('office1.mat');
office = office.pcl_train;

rgb = office{frame_id}.Color; % Extracting the colour data
point = office{frame_id}.Location; % Extracting the xyz data

%% Removing points outside window-------------------------------------------
z = point(:,3); %get the z dimension
z_new = z;
z_new(z > 4) = 0;

point(:,3) = z_new;
indx_xyz_no = find(z>4);
rgb(indx_xyz_no,:)=0;

pc_z_thresholded = pointCloud(point, 'Color', rgb);% Creating a point-cloud variable - remove

%% Removing flying pixels---------------------------------------------------
points_reshaped= point.'; %transpose of points array

idx= isnan(points_reshaped); 
points_reshaped(idx)= 0;

rgb_reshaped= rgb.';

K_neighbours=27; %Number of neighbours for which we calculate the distance from a given point
number_points_checked=307200; %Total number of points we check in the loop below
distance_threshold = 1.1; 
number_neighbours_threshold = 1; 

for i = 1:number_points_checked
   single_point = [points_reshaped(1,i) points_reshaped(2,i) points_reshaped(3,i)];
   [indices(:,i),dists(:,i)] = findNearestNeighbors(pc_z_thresholded,single_point,K_neighbours);
   filtered_distance = dists(:,i)<distance_threshold;
   number_neighbours_within_distance=sum(filtered_distance(:) == 1);
   if number_neighbours_within_distance<number_neighbours_threshold
       rgb_reshaped(1,i)=0;
       rgb_reshaped(2,i)=0;
       rgb_reshaped(3,i)=0; 
       
       points_reshaped(1,i)=0;
       points_reshaped(2,i)=0;
       points_reshaped(3,i)=0;
       
   end
        
end
 
rgb_reshaped_back=rgb_reshaped.'; %transpose
point_reshaped_back=points_reshaped.'; %transpose

pc_z_thresholded_no_flying_pixels = pointCloud(point_reshaped_back, 'Color', rgb_reshaped_back); % Creating a point-cloud variable


%% Removing points from egdes-----------------------------------------------
%Extracting the r, g, b colours
    r = rgb_reshaped_back(:,1);
    g = rgb_reshaped_back(:,2);
    b = rgb_reshaped_back(:,3);

% reshaping each array (r, g, b) to obtain a [512x424] matrix 
    rec_r = reshape(r, [640, 480]);
    rec_g = reshape(g, [640, 480]);
    rec_b = reshape(b, [640, 480]);
    new_rgb = cat(3, rec_r', rec_g', rec_b');

%%Eliminate regions in the rgb image 
%left side
new_rgb(:,1:60,1)=0;
new_rgb(:,1:60,2)=0;
new_rgb(:,1:60,3)=0;

%right side
new_rgb(:,580:640,1)=0;
new_rgb(:,580:640,2)=0;
new_rgb(:,580:640,3)=0;

% Extracting the x y and z
x = point_reshaped_back(:,1);
y = point_reshaped_back(:,2);
z = point_reshaped_back(:,3);
    
%
rec_x = reshape(x, [640, 480]);
rec_y = reshape(y, [640, 480]);
rec_z = reshape(z, [640, 480]);
new_xyz = cat(3, rec_x', rec_y', rec_z');

    
% Eliminate regions in the xyz  
new_xyz(:,1:60,1)=0;
new_xyz(:,1:60,2)=0;
new_xyz(:,1:60,3)=0;
   
new_xyz(:,580:640,1)=0;
new_xyz(:,580:640,2)=0;
new_xyz(:,580:640,3)=0;
%% Saving final pc
pc_final = pointCloud(new_xyz, 'Color', new_rgb); % Creating a point-cloud variable

figure(1)
pcshow(pc_final)
figure(2)
%imag2d(new_rgb)
imshow(new_rgb) 