%% Load the training data 
office = load('office1.mat');
office = office.pcl_train;
%% Uncomment to load the test file
% office = load('office2.mat');
% office = office.pcl_test;
%%
matches = zeros(1, length(office)-1);  % store the num of matching points for each pair
for i = 1:(length(office)-1) % Reading the 40 point-clouds	  
    % _1 means left image, _2 means right image
    rgb_1 = office{i}.Color; % Extracting the colour data   _1 means left image, _2 means right image
    point_1 = office{i}.Location; % Extracting the xyz data
    pc_1 = pointCloud(point_1, 'Color', rgb_1); % Creating a point-cloud variable
    rgb_2 = office{i+1}.Color; % Extracting the colour data   _1 means left image, _2 means right image
    point_2 = office{i+1}.Location; % Extracting the xyz data
    pc_2 = pointCloud(point_2, 'Color', rgb_2); % Creating a point-cloud variable
    %construct image by rgb
    r_1 = rgb_1(:,1);
    g_1 = rgb_1(:,2);
    b_1 = rgb_1(:,3);
    r_2 = rgb_2(:,1);
    g_2 = rgb_2(:,2);
    b_2 = rgb_2(:,3);
    % reshaping each array (r, g, b) to obtain a [512x424] matrix 
    rec_r_1 = reshape(r_1, [640, 480]);
    rec_g_1 = reshape(g_1, [640, 480]);
    rec_b_1 = reshape(b_1, [640, 480]);
    new_rgb_1 = cat(3, rec_r_1', rec_g_1', rec_b_1');
    rec_r_2 = reshape(r_2, [640, 480]);
    rec_g_2 = reshape(g_2, [640, 480]);
    rec_b_2 = reshape(b_2, [640, 480]);
    new_rgb_2 = cat(3, rec_r_2', rec_g_2', rec_b_2');
    % get matching point
    num = match(new_rgb_1,new_rgb_2);
    matches(i) = num;
end
