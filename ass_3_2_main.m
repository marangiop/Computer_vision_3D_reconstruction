% Load the training data 
office = load('office1.mat');
office = office.pcl_train;
% Uncomment to load the test file
% office = load('office2.mat');
% office = office.pcl_test;
%
%matches = zeros(1, length(office)-1);  % store the num of matching points for each pair
% load rotation data from part 2
Data1 = load('rot_all.mat');
rot_all = Data1.rot_all;
% load transition data from part 2
Data2 = load('tran_all.mat');
tran_all = Data2.tran_all;
for i = 1:39 % Reading 40 point-clouds	  
    %i = 26;    % frame starting point
    % _1 means left image, _2 means right image
    i
    rgb_1 = office{i}.Color; % Extracting the colour data   _1 means left image, _2 means right image
    point_1 = office{i}.Location; % Extracting the xyz data
    pc_1 = pointCloud(point_1, 'Color', rgb_1); % Creating a point-cloud variable
    % judge if you want to remove Bob
    figure();
    imag2d(rgb_1);
    answer1 = input('Do you want to remove Bob? (y/n) \n');
    if answer1 == 'y'
        [rgb_1, point_1, pc_1] = removebob(rgb_1, point_1, pc_1);
    end
    
    % read the next frame
    rgb_2 = office{i+1}.Color; % Extracting the colour data   _1 means left image, _2 means right image
    point_2 = office{i+1}.Location; % Extracting the xyz data
    pc_2 = pointCloud(point_2, 'Color', rgb_2); % Creating a point-cloud variable
    % judge if you want to remove Bob
    figure();
    imag2d(rgb_2);
    answer2 = input('Do you want to remove Bob? (y/n) \n');
    if answer2 == 'y'
        [rgb_2, point_2, pc_2] = removebob(rgb_2, point_2, pc_2);
    end
    
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
    [num, M, D] = match(new_rgb_1, new_rgb_2, i);
    %matches(i) = num;   % get the num of matches for wach pair
    
    % find the true 3D position point in the point cloud given sift
    % position from grey image
    M_index = [];
    D_index = [];
    for l = 1:size(M, 2)
        temp1 = 480 * (M(1,l) - 1) + M(2,l);   % used to use round causing error
        temp2 = 480 * (D(1,l) - 1) + D(2,l);
        if M(1,l) ~= 0
            M_index = [M_index, temp1];
            D_index = [D_index, temp2];
        end
    end
    new_M = zeros(length(M_index),3); % using M_index or D_index doesn't matter, the size corresponds to N in the paper
    new_D = zeros(length(D_index),3);  
    for j = 1:length(M_index)   
        if ~isnan(point_1(M_index(j),:)) & ~isnan(point_2(D_index(j),:))   % throw away nan matching
            new_M(j,:) = point_1(M_index(j),:);
            new_D(j,:) = point_2(D_index(j),:);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%Ransac
    count = 0; % give the initial a small number for the initial loop
    for m = 1:20000     % randomly pick 8 matching points(3 pairs) 20000 times to find the one giving smallest distance
        [sample_D, index] = datasample(new_D, 3,'Replace',false);  % randomly get matching pairs and their index
        sample_M = [new_M(index(1),:); new_M(index(2),:); new_M(index(3),:)]; % get the sample according to index
        % do SVD to find Translation matrix and Rotation matrix
        [R, T] = rot_tran(sample_M, sample_D); % this is the change from coordinate system D to M, which is from latter to the former
        % apply it to all matching pairs
        new_D_2 = zeros(size(new_D));
        for k = 1:size(new_D_2,1)
            new_D_2(k,:) = new_D(k,:) * R + T';
        end
        distance_vector = sum((new_D_2-new_M).^2, 2);    %euclidean distance
        if i == 26 || i == 27 || i == 36
            distance_threshold = 0.35;
        elseif i == 22 || i == 24 || i == 25 || i == 33 || i == 34
            distance_threshold = 0.1;
        else
            distance_threshold = 0.06;
        end
        count_temp = length(find(distance_vector < distance_threshold));   %threshold could be changed
        if count_temp > count
            count = count_temp;
            Best_R = R;
            Best_T = T;
        end 
    end
    % put all rots and trans in
    rot_all(:,:,i) = Best_R;
    tran_all(:,:,i) = Best_T;
    % saving the file by using save
    save('rot_all.mat', 'rot_all');
    save('tran_all.mat', 'tran_all');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % do SVD to find Translation matrix and Rotation matrix
    %[R, T] = rot_tran(new_M, new_D); % this is the change from coordinate system D to M, which is from latter to the former
    % apply it to second pc
    new_point_2 = zeros(size(point_2));
    for k = 1:size(new_point_2,1)
        new_point_2(k,:) = point_2(k,:) * Best_R + Best_T';
    end
    
    new_pc_2 = pointCloud(new_point_2, 'Color', rgb_2); % new pc2 moved from second coordinate to first coordinate
    merge_pcs = pcmerge(pc_1, pc_2, 1);   %merge two pcs
    figure();
    subplot(2, 2, 1), pcshow(pc_1), title('pc1');
    subplot(2, 2, 2), pcshow(pc_2), title('pc2');
    subplot(2, 2, 3), pcshow(new_pc_2), title('new pc2');
    subplot(2, 2, 4), pcshow(pc_1); hold on; pcshow(merge_pcs), title('pc1 and new pc2');
    
end
