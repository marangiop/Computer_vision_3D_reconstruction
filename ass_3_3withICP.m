% load tform data from part 2
Data = load('Tform.mat');
tform = Data.Tform;


office = load('office1.mat');
office = office.pcl_train;
% Uncomment to load the test file
% office = load('office2.mat');
% office = office.pcl_test;

for i = 2:40
    i
    if i == 27 || i ==25%|| i == 35 || i == 36 
        continue;
    else
        rgb_i = office{i}.Color; % Extracting the colour data  
        point_i = office{i}.Location; % Extracting the xyz data
        pc_i = pointCloud(point_i, 'Color', rgb_i); % Creating a current point-cloud variable
        pc_i = single_cleaning_function(pc_i);
        % back to first coordinate
        new_pc = pc_i;
        for j = (i-1) :-1 : 1
            if j ==27 || i ==25
                continue;
            else
                tform_i = affine3d(tform(:, :, j));
                new_pc = pctransform(new_pc,tform_i); 
            end
        end
        
%         if i == 28 %|| i ==30
%             current_tran = tform(:, :, i-2) * current_tran;
%             tform_i = affine3d(current_tran);
% %         elseif i == 38
% %             current_tran = current_tran * tform(:, :, i-4);
% %             tform_i = affine3d(current_tran);
%         else
%             current_tran = tform(:, :, i-1) * current_tran;
%             tform_i = affine3d(current_tran);
%         end    
%         new_pc = pctransform(pc_i,tform_i); % new pc moved from current coordinate to first coordinate
       
        if i == 2   % the case only happens for the second image
            rgb_1 = office{1}.Color; % Extracting the colour data 
            point_1 = office{1}.Location; % Extracting the xyz data
            pc_1 = pointCloud(point_1, 'Color', rgb_1); % Creating a point-cloud variable
        %remove noise
            % clean the data by single_cleaning_function
            pc_1 = single_cleaning_function(pc_1);
            %new_pc = single_cleaning_function(new_pc);
            merge_pc = pcmerge(pc_1, new_pc, 0.009);   %merge two pcs
        else
        %remove noise
            %pc_1 = single_cleaning_function(pc_1);
            %new_pc = single_cleaning_function(new_pc);
            merge_pc = pcmerge(merge_pc, new_pc, 0.009);   %merge two pcs
        end
    end
end

% show the whole fused pc
figure()
pcshow(merge_pc); title('fused pc based on all point cloud');
% output pc to a mat file
save('fused_pc.mat', 'merge_pc');