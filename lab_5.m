% Read the data
pc = pcread('coffee_mug.ply');
pc_T = pcread('coffee_mug_transformed.ply');

% Plot the data
figure();
subplot(2, 2, 1), pcshow(pc), title('Original point cloud');
subplot(2, 2, 2), pcshow(pc_T), title('Transformed point cloud');
subplot(2, 2, [3, 4]), pcshow(pc); hold on; pcshow(pc_T);

% Get the xyz positions of the point clouds
xyz = pc.Location;
xyz_T = pc_T.Location;

% Create [nx4] matrix
p = horzcat(xyz, ones(size(xyz, 1), 1) )'; %[nx4]
p_T = horzcat(xyz_T , ones(size(xyz_T, 1), 1))'; %[nx4]
% Find A in:
t_xyz = @(tx, ty, tz) [1, 0, 0, tx; 0, 1, 0, ty; 0, 0, 1, tz; 0, 0, 0, 1];
A = t_xyz(0.884, 0.442, 0.765) * rot_x_y_z(pi/3, 0, pi/4);  % what I measure
new_p = A*p; %A is the transformation matrix

% Creates a new point cloud
new_p = pointCloud(new_p(1:3, :)');

%comparasion
% Plot the data
figure();
subplot(2, 2, 1), pcshow(new_p), title('new point cloud');
subplot(2, 2, 2), pcshow(pc_T), title('Transformed point cloud');
subplot(2, 2, [3, 4]), pcshow(new_p); hold on; pcshow(pc_T);

% Euclidean distance
% x 
x_T = pc_T.Location(:, 1);
x_new = new_p.Location(:, 1);
x_euclidean = sqrt(sum((x_T - x_new) .^ 2));
fprintf('Euclidean distance for x = %.2f\n', x_euclidean);
% y 
y_T = pc_T.Location(:, 2);
y_new = new_p.Location(:, 2);
y_euclidean = sqrt(sum((y_T - y_new) .^ 2));
fprintf('Euclidean distance for y = %.2f\n', y_euclidean);
% x 
z_T = pc_T.Location(:, 3);
z_new = new_p.Location(:, 3);
z_euclidean = sqrt(sum((z_T - z_new) .^ 2));
fprintf('Euclidean distance for z = %.2f\n', z_euclidean);
