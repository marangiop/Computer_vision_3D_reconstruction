% Load the training data 
office = load('office1.mat');
office = office.pcl_train;
% Uncomment to load the test file
% office = load('office2.mat');
% office = office.pcl_test;
%
matches = zeros(1, length(office)-1);  % store the num of matching points for each pair
for i = 1:2 % Reading 40 point-clouds	  
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
    [num, M, D] = match(new_rgb_1,new_rgb_2);
    matches(i) = num;   % get the num of matches for wach pair
    
    % find the true 3D position point in the point cloud given sift
    % position from grey image
    M_index = [];
    D_index = [];
    for l = 1:size(M, 2)
        temp1 = 480 * (M(1,l) - 1) + M(2,l);
        temp2 = 480 * (D(1,l) - 1) + D(2,l);
        if M(1,l) ~= 0
            M_index = [M_index, temp1];
            D_index = [D_index, temp2];
        end
    end
    new_M = zeros(length(M_index),3); % using M_index or D_index doesn't matter, the size corresponds to N in the paper
    new_D = zeros(length(D_index),3);  
    for j = 1:length(M_index)   
        new_M(j,:) = point_1(M_index(j),:);
        new_D(j,:) = point_2(D_index(j),:);
    end
    
    % do SVD to find Translation matrix and Rotation matrix
    [R, T] = rot_tran(new_M, new_D); % this is the change from coordinate system D to M, which is from latter to the former
    % apply it to second pc
    new_point_2 = zeros(size(point_2));
    for k = 1:size(new_point_2,1)
        new_point_2(k,:) = point_2(k,:) * R + T';
    end
    new_pc_2 = pointCloud(new_point_2, 'Color', rgb_2); % Creating a point-cloud variable
    figure();
    subplot(2, 2, 1), pcshow(pc_1), title('pc1');
    subplot(2, 2, 2), pcshow(pc_2), title('pc2');
    subplot(2, 2, 3), pcshow(new_pc_2), title('new pc2');
    subplot(2, 2, 4), pcshow(pc_1); hold on; pcshow(new_pc_2), title('pc1 and new pc2');

end
