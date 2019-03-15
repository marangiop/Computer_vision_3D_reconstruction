function[pc] = removing_points_outside_window_3_1_1(frame_id)

office = load('office1.mat');
office = office.pcl_train;
rgb = office{frame_id}.Color; % Extracting the colour data
point = office{frame_id}.Location; % Extracting the xyz data
z = point(:,3); %get the z dimension
z_new = z;

z_new(z > 4) = NaN;
point(:,3) = z_new;

indx_xyz_no = find(z>4);

rgb(indx_xyz_no,:)=NaN;

pc = pointCloud(point, 'Color', rgb); % Creating a point-cloud variable
figure(1)
pcshow(pc)
figure(2)
imag2d(rgb) % Shows the 2D image
