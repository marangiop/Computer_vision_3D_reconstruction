function [new_rgb, new_point, new_pc] = removebob(rgb, point, pc)

%%Removing Bob from frame 27
%rgb = office{27}.Color; % Extracting the colour data
%point = office{27}.Location; % Extracting the xyz data
figure()
imag2d(rgb)

rect = getrect

hold on
rectangle('Position', rect, 'EdgeColor','r', 'LineWidth', 3)

%new_rgb =[];
%color_pc = rgb;
r = rgb(:,1);
g = rgb(:,2);
b = rgb(:,3);
rec_r = reshape(r, [640, 480]);
rec_g = reshape(g, [640, 480]);
rec_b = reshape(b, [640, 480]);
new_rgb = cat(3, rec_r', rec_g', rec_b');

x_coord_lower = rect(2);
y_coord_lower = rect(1);
height= rect(3);
width= rect(4);

new_rgb(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, : )= 0;   

imshow(new_rgb)


%% Extracting the x y and z
x = point(:,1);
y = point(:,2);
z = point(:,3);
    
%% reshaping x y and z
rec_x = reshape(x, [640, 480]);
rec_y = reshape(y, [640, 480]);
rec_z = reshape(z, [640, 480]);
new_point = cat(3, rec_x', rec_y', rec_z');

    
%% Eliminate region containg Bob in the xyz  
new_point(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, 1 )=0;
new_point(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, 2 )=0;
new_point(x_coord_lower:width+x_coord_lower, y_coord_lower:height+y_coord_lower, 3 )=0;
   

%% Generate new pc
% shape rgb and point back to 307200x3 format for new_pc
new_r = reshape((new_rgb(:,:,1))',[307200,1]);    % there is transpose when using 'cat', so transpose back here
new_g = reshape((new_rgb(:,:,2))',[307200,1]);
new_b = reshape((new_rgb(:,:,3))',[307200,1]);
new_rgb = [new_r, new_g, new_b];

new_x = reshape((new_point(:,:,1))',[307200,1]);
new_y = reshape((new_point(:,:,2))',[307200,1]);
new_z = reshape((new_point(:,:,3))',[307200,1]);
new_point = [new_x, new_y, new_z];
new_pc= pointCloud(new_point, 'Color', new_rgb); % Creating a point-cloud variable




