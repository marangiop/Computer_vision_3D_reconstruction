%% Load the training data 
office = load('office1.mat');
office = office.pcl_train;
%% Uncomment to load the test file
% office = load('office2.mat');
% office = office.pcl_test;
%%
matches = zeros(1, length(office)-1);  % store the num of matching points for each pair
for i = 1:2 % Reading the 40 point-clouds	  
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

    
 %%
    % get matching points using SIFT
[im1, des1, loc1] = sift(new_rgb_1);
[im2, des2, loc2] = sift(new_rgb_2);


% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
      
      
   else
      match(i) = 0;
   end
   
   
end



A= size(des1,1);

% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);

% Show a figure with lines joining the accepted matches.
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);
for i = 1: size(des1,1)
  if (match(i) > 0)
    line([loc1(i,2) loc2(match(i),2)+cols1], ...
         [loc1(i,1) loc2(match(i),1)], 'Color', 'c');   
     
   
  end
end
hold off;
num = sum(match > 0);

end
%%
B(:,1:3)=loc2(:,1:3); % TRhis stores the 3D coordinates of the SIFT points in the FIRST image that have a matching SIFT point in the SECOND image 

%% For every descriptor in the second image to select get the matching descriptor in the first image 
des1t = des1'; 

for i = 1 : size(des2,1)
   dotprods = des2(i,:) * des1t;                % Computes vector of dot products
   [vals_new,indx_new] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals_new(1) < distRatio * vals_new(2))
      match_new(i) = indx_new(1);
      
   else
      match_new(i) = 0;
   end
   
   C(i,1:3)=loc1(i,1:3); % This stores the 3D coordinates of the SIFT points in the SECOND image that have a matching SIFT point in the FIRST image; B and C are different, as the yare different images 
end

%% Step 1 of "III. AN SVD ALGORITHM FOR FINDING R" from K. S. ARUN, T. S. HUANG, AND S. D. BLOSTEIN
%Get the column-wise average of B and C 
column_B_average = sum(B , 1)/1341; %dimension 1 means column; 1341 is the length of the column --> must be changed to a variable
column_C_average = sum(C , 1)/1341;
% Normalize each element of B and C based on averages
normalized_B = B-column_B_average;
normalized_C = B-column_C_average;
%% Step 2 of "III. AN SVD ALGORITHM FOR FINDING R" from K. S. ARUN, T. S. HUANG, AND S. D. BLOSTEIN
%Generate matrix H
normalized_C_t = normalized_C'; %take the transpose of C so we can perform multiplication between column and row vectors 
H=0;
for i = 1 : 1341
    column_vector= normalized_C_t(:,i);
    row_vector= normalized_B(i,:);
    H = H + column_vector.*row_vector;
end
%% Step 3 of "III. AN SVD ALGORITHM FOR FINDING R" from K. S. ARUN, T. S. HUANG, AND S. D. BLOSTEIN
%%Perform SVD on H
[U,S,V] = svd(H);
