%%Removing Bob from frame 27
rgb = office{27}.Color; % Extracting the colour data
point = office{27}.Location; % Extracting the xyz data
imag2d(rgb)

rect = getrect

hold on
rectangle('Position', rect, 'EdgeColor','r', 'LineWidth', 3)

new_rgb =[];
color_pc = rgb;
r = color_pc(:,1);
g = color_pc(:,2);
b = color_pc(:,3);
rec_r = reshape(r, [640, 480]);
rec_g = reshape(g, [640, 480]);
rec_b = reshape(b, [640, 480]);
new_rgb = cat(3, rec_r', rec_g', rec_b');

x_coord_lower = rect(2);
y_coord_lower = rect(1);
height= rect(3);
width= rect(4);

new_rgb(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, : )= 0;   
%imshow(new_rgb)
%pause(0.1)

%% Extracting the x y and z
x = point(:,1);
y = point(:,2);
z = point(:,3);
    
%% reshaping x y and z
rec_x = reshape(x, [640, 480]);
rec_y = reshape(y, [640, 480]);
rec_z = reshape(z, [640, 480]);
new_xyz = cat(3, rec_x', rec_y', rec_z');

    
%% Eliminate region containg Bob in the xyz  
new_xyz(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, 1 )=0;
new_xyz(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, 2 )=0;
new_xyz(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, 3 )=0;
   

%% Generate new pc
pc= pointCloud(new_xyz, 'Color', new_rgb); % Creating a point-cloud variable

figure(1)
pcshow(pc)
figure(2)
imshow(new_rgb) 







