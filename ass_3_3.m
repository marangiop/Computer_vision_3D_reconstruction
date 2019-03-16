% load rotation data from part 2
Data1 = load('rot_all.mat');
all_rot = Data1.rot_all;
% load transition data from part 2
Data2 = load('tran_all.mat');
all_tran = Data2.tran_all;
% Load the training data 
office = load('office1.mat');
office = office.pcl_train;
% Uncomment to load the test file
% office = load('office2.mat');
% office = office.pcl_test;
%
for i = 2:40
    rgb_i = office{i}.Color; % Extracting the colour data  
    point_i = office{i}.Location; % Extracting the xyz data
    %pc_i = pointCloud(point_1, 'Color', rgb_1); % Creating a current point-cloud variable
    % back to first coordinate
    for j = 1:(i-1)
        new_point = zeros(size(point_i));
        for k = 1:size(new_point,1)
            new_point(k,:) = point_i(k,:) * all_rot(:,:,j) + all_tran(:,:,j)';  % do translation and rotation iteratively
        end
    end
    
    new_pc = pointCloud(new_point, 'Color', rgb_i); % new pc moved from current coordinate to first coordinate
    
    if i == 2   % the case only happens for the second image
        rgb_1 = office{1}.Color; % Extracting the colour data 
        point_1 = office{1}.Location; % Extracting the xyz data
        pc_1 = pointCloud(point_1, 'Color', rgb_1); % Creating a point-cloud variable
        merge_pc = pcmerge(pc_1, new_pc, 1);   %merge two pcs
    else        
        merge_pc = pcmerge(merge_pc, new_pc, 1);   %merge two pcs
    end
    
end

% show the whole fused pc
figure()
pcshow(merge_pc); title('fused pc based on all point cloud');
% output pc to a mat file
save('fused_pc.mat', 'merge_pc');