% Step 1
% Read data in

pc = pcread('Labs/bottles.ply') ; % Reading the point - cloud
showPointCloud(pc) % Showing the point - cloud
%pc has two properties: Location and Color

% Step 2
% Reconstruct the color image using the color property in the pointcloud. 
color_pc = pc.Color;
r = color_pc(:,1); %get the r color 
g = color_pc(:,2); %get the g color 
b = color_pc(:,3); %get the b color 
rec_r = reshape(r, [480, 640]); %reshape r into a matrix of size 480 x 640
rec_g = reshape(g, [480, 640]); %reshape g
rec_b = reshape(b, [480, 640]); %reshape b
new_rgb(:,:,1) = rec_r;
new_rgb(:,:,2) = rec_g;
new_rgb(:,:,3) = rec_b;
imshow(new_rgb) %display the reconstructed rgb image

% Step 3
% Segment the first bottle in the Colour space (2D space or color matrix) and find a mask.
double_rgb = im2double(new_rgb); 
hsv_double_rgb = rgb2hsv(double_rgb); 
s = hsv_double_rgb(:,:,2);

ed_canny = edge(s, 'Canny',0.6); 
SE2 = strel('square', 8);
dilation = imdilate(ed_canny , SE2);

filled_bottles = imfill(dilation, 'holes');
SE3 = strel('square', 15);
erode_bottles = imerode(filled_bottles, SE3);
imshow(erode_bottles);

new_masked_bottles = bsxfun(@times , new_rgb , cast(erode_bottles, 'like',new_rgb));
imshow(new_masked_bottles); % from this image we can seen that the first bottle has been segmented perfectly compared to the others

lbl = bwlabel(new_masked_bottles(:,:,1), 4); 
imshow(lbl==1); % this allows us to segment only the first bottle

new_masked_bottles_2 = bsxfun(@times , new_rgb , cast(lbl==1, 'like',new_rgb))
imshow(new_masked_bottles_2)

% Step 4
% After we segmented the bottle, we have to relate the pixels of the bottle in our 2D image to the points in our point-cloud.

indx_xyz_no = find(new_masked_bottles_2(:,:,1)<= 0); %find the indices of the pixels where our bottle is not located

xyz_pc = pc.Location;

% Eliminating the indices where our bottle is not located 
xyz_pc(indx_xyz_no,:)=[];
color_pc(indx_xyz_no,:)=[];

new_pc = pointCloud(xyz_pc, 'Color' , color_pc); % Creating a new point - cloud


pcwrite(new_pc, 'single_bottle.ply'); % Saving the new point - cloud
showPointCloud(new_pc)

