function pc_z_thresholded = single_cleaning_function(pc)


rgb = pc.Color; % Extracting the colour data
point = pc.Location; % Extracting the xyz data

%% Removing points outside window-------------------------------------------
z = point(:,3); %get the z dimension

indx_xyz_no = z>4 | z < -4;
rgb(indx_xyz_no,:)=0;
point(indx_xyz_no,:)=0;
% do the same for x and y
x = point(:,1); %get the z dimension
indx_xyz_no = x > 4 | x < -4;
rgb(indx_xyz_no,:)=0;
point(indx_xyz_no,:)=0;

y = point(:,2); %get the z dimension

indx_xyz_no = y > 4 | y < -4;
rgb(indx_xyz_no,:)=0;
point(indx_xyz_no,:)=0;


pc_z_thresholded = pointCloud(point, 'Color', rgb);% Creating a point-cloud variable - remove

%% Removing flying pixels---------------------------------------------------
% points_reshaped= point.'; %transpose of points array
% 
% idx= isnan(points_reshaped); 
% points_reshaped(idx)= 0;
% 
% rgb_reshaped= rgb.';
% 
% K_neighbours=27; %Number of neighbours for which we calculate the distance from a given point
% number_points_checked=307200; %Total number of points we check in the loop below
% distance_threshold = 1.1; 
% number_neighbours_threshold = 1; 
% 
% for i = 1:number_points_checked
%    single_point = [points_reshaped(1,i) points_reshaped(2,i) points_reshaped(3,i)];
%    [indices(:,i),dists(:,i)] = findNearestNeighbors(pc_z_thresholded,single_point,K_neighbours);
%    filtered_distance = dists(:,i)<distance_threshold;
%    number_neighbours_within_distance=sum(filtered_distance(:) == 1);
%    if number_neighbours_within_distance<number_neighbours_threshold
%        rgb_reshaped(1,i)=0;
%        rgb_reshaped(2,i)=0;
%        rgb_reshaped(3,i)=0; 
%        
%        points_reshaped(1,i)=0;
%        points_reshaped(2,i)=0;
%        points_reshaped(3,i)=0;
%        
%    end
%         
% end
%  
% rgb_reshaped_back=rgb_reshaped.'; %transpose
% point_reshaped_back=points_reshaped.'; %transpose
% 
% pc_z_thresholded_no_flying_pixels = pointCloud(point_reshaped_back, 'Color', rgb_reshaped_back); % Creating a point-cloud variable
