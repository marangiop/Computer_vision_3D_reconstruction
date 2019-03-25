
function[updated_pc] = removing_points_window_flying_pixels(frame_id)

office = load('office1.mat');
office = office.pcl_train;
rgb = office{frame_id}.Color; % Extracting the colour data
points = office{frame_id}.Location; % Extracting the xyz data

pc = pointCloud(points, 'Color', rgb); % Creating a point-cloud variable

z = points(:,3); %get the z dimension
z_new = z;

z_new(z > 4) = NaN;
points(:,3) = z_new;

indx_xyz_no = find(z>4);

rgb(indx_xyz_no,:)=NaN;




points_reshaped= points.'; %transpose of points array

idx= isnan(points_reshaped); %replacing Nan by 0...is this correct?
points_reshaped(idx)= 0;

rgb_reshaped= rgb.';

K_neighbours=27; %Number of neighbours for which we calculate the distance from a given point
number_points_checked=307200; %Total number of points we check in the loop below
%distance_threshold = 1; %This is the distance threshold we want to apply to the calculated distances for a given point
%number_neighbours_threshold = 5; %  This is the number of neighbours we expect to find within a given distance threshold; for example, if the distance threshold is 1, then the number_neighbours_threshold should be very small, like 0, for a flying pixel

%Set 2
%distance_threshold = 1;
%number_neighbours_threshold = 1; 

%set 3
%distance_threshold = 2; 
%number_neighbours_threshold = 1; 

%set 4
%distance_threshold = 1.5; 
%number_neighbours_threshold = 1; 

%set 5
distance_threshold = 1.1; 
number_neighbours_threshold = 1; 

for i = 1:number_points_checked
   point = [points_reshaped(1,i) points_reshaped(2,i) points_reshaped(3,i)];
   [indices(:,i),dists(:,i)] = findNearestNeighbors(pc,point,K_neighbours);
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

updated_pc = pointCloud(point_reshaped_back, 'Color', rgb_reshaped_back); % Creating a point-cloud variable
figure(1)
pcshow(updated_pc)
figure(2)
imag2d(rgb_reshaped_back) 




