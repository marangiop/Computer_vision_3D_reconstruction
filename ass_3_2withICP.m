% Load the training data 
office = load('office1.mat');
office = office.pcl_train;
% Uncomment to load the test file
% office = load('office2.mat');
% office = office.pcl_test;
%
%matches = zeros(1, length(office)-1);  % store the num of matching points for each pair
% load rotation data from part 2
Data = load('Tform.mat');
Tform = Data.Tform;
for i = 1:39 % Reading 40 point-clouds	  
   
    % _1 means left image, _2 means right image
    if i == 27 || i ==25 %|| i == 35 || i == 36 || i ==37  %let the frame 27 and frame 29 go
        continue;
    else
        i
        rgb_1 = office{i}.Color; % Extracting the colour data   _1 means left image, _2 means right image
        point_1 = office{i}.Location; % Extracting the xyz data
        pc_1 = pointCloud(point_1, 'Color', rgb_1); % Creating a point-cloud variable
        % clean the data by single_cleaning_function
        pc_1 = single_cleaning_function(pc_1);
        rgb_1 = pc_1.Color;   % rewrite the rgb and the location from cleaned data
        point_1 = pc_1.Location;
    
    % judge if you want to remove Bob
%     figure();
%     imag2d(rgb_1);
%     answer1 = input('Do you want to remove Bob? (y/n) \n');
%     if answer1 == 'y'
%         [rgb_1, point_1, pc_1] = removebob(rgb_1, point_1, pc_1);
%     end
   
    
    % read the next frame
        if i == 26 || i == 24
            j = i + 2;
%         elseif i == 34
%             j = j + 4;  % j = 38
        else
            j = i + 1;
        end
        rgb_2 = office{j}.Color; % Extracting the colour data   _1 means left image, _2 means right image
        point_2 = office{j}.Location; % Extracting the xyz data
        pc_2 = pointCloud(point_2, 'Color', rgb_2); % Creating a point-cloud variable
        % clean the data by single_cleaning_function
        pc_2 = single_cleaning_function(pc_2);
        rgb_2 = pc_2.Color;   % rewrite the rgb and the location from cleaned data
        point_2 = pc_2.Location;
%     % judge if you want to remove Bob
%     figure();
%     imag2d(rgb_2);
%     answer2 = input('Do you want to remove Bob? (y/n) \n');
%     if answer2 == 'y'
%         [rgb_2, point_2, pc_2] = removebob(rgb_2, point_2, pc_2);
%     end
    
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
        new_M_rgb = zeros(length(M_index),3); % need corresponding rgb to construct a new point cloud for icp
        new_D_rgb = zeros(length(D_index),3);
        for j = 1:length(M_index)   
            if ~isnan(point_1(M_index(j),:)) & ~isnan(point_2(D_index(j),:))   % throw away nan matching
                new_M(j,:) = point_1(M_index(j),:);
                new_D(j,:) = point_2(D_index(j),:);
                new_M_rgb(j,:) = rgb_1(M_index(j),:);
                new_D_rgb(j,:) = rgb_2(D_index(j),:);
            end
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%ICP
    %construct new matching pc for icp
        if i ~= 28 && i~=22 && i~=29
            temp_M_pc = pointCloud(new_M, 'Color', new_M_rgb);
            temp_D_pc = pointCloud(new_D, 'Color', new_D_rgb);
        %using matching points instead of sampling points(explained in matlab doc) to do icp
            tform = pcregrigid(temp_D_pc,temp_M_pc,'Extrapolate',true);
        else
            tform = pcregrigid(pc_2,pc_1,'Extrapolate',true);
        end
%         
        

    % put tform into mat file
        Tform(:,:,i) = tform.T;
    
    % saving the file by using save
        save('Tform.mat', 'Tform');
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % apply it to second pc by pctransform
    
        new_pc_2 = pctransform(pc_2,tform); % new pc2 moved from second coordinate to first coordinate
    
    
    % remove pc noise by pcdenoise for fused pc
%     pc_1 = pcdenoise(pc_1);
%     pc_2 = pcdenoise(pc_2);
%     new_pc_2 = pcdenoise(new_pc_2);
    
        figure();
        subplot(2, 2, 1), pcshow(pc_1), title('pc1');
        subplot(2, 2, 2), pcshow(pc_2), title('pc2');
        subplot(2, 2, 3), pcshow(new_pc_2), title('new pc2');
        subplot(2, 2, 4), pcshow(pc_1);hold on, pcshow(new_pc_2), title('pc1 and new pc2');
        %pause
    end
end