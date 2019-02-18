rgb = office{23}.Color; % Extracting the colour data
point = office{23}.Location; % Extracting the xyz data
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
