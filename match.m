% num = match(image1, image2)
%
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.
%
% Example: match('scene.pgm','book.pgm');

function  [num, points_set_1, points_set_2] = match(image1, image2, frame_num)    %
% points_set_1, points_set_2 return matching points set from image1 and
% image2   2xN matrix [X1, ..., XN; Y1, ..., YN]

% Find SIFT keypoints for each image
[im1, des1, loc1] = sift(image1);
[im2, des2, loc2] = sift(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
if frame_num == 27 || frame_num == 24 || frame_num == 33 || frame_num == 22 || frame_num == 25
    distRatio = 0.65;  
elseif frame_num == 34 
    distRatio = 0.55;
elseif frame_num == 26 
    distRatio = 0.7;
elseif frame_num == 36
    distRatio = 0.72;
else
    distRatio = 0.4;
end

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
points_set_1 = zeros(2, 2000);          % normally the num of sift points will be less than 2000
points_set_2 = zeros(2, 2000);          % ---1---
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
      points_set_1(1,i) = round(loc1(i,1));         % ---2---% find the nearest neighbour as true point
      points_set_1(2,i) = round(loc1(i,2));
      points_set_2(1,i) = round(loc2(indx(1),1));   
      points_set_2(2,i) = round(loc2(indx(1),2));
   else
      match(i) = 0;
   end
end
% remove 0 in points set          ---3---
%points_set_1 = points_set_1(points_set_1~=0);
%points_set_2 = points_set_2(points_set_2~=0);

% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);

%Show a figure with lines joining the accepted matches.
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
% draw sift points in the first image
imsize = size(im1);
for i = 1: size(loc1,1)
    % Draw an arrow, each line transformed according to keypoint parameters.
    TransformLine(imsize, loc1(i,:), 0.0, 0.0, 1.0, 0.0);
    TransformLine(imsize, loc1(i,:), 0.85, 0.1, 1.0, 0.0);
    TransformLine(imsize, loc1(i,:), 0.85, -0.1, 1.0, 0.0);
end
% draw sift points in the second image, shoud be modified based on combined
% image (im3)
imsize = size(im3);
new_loc2 = loc2;  % used as sift points location for right image(from im2) in im3
new_loc2(:,2) = new_loc2(:,2) + 640; % transfer the y position from im2 to im3 
for i = 1: size(new_loc2,1)
    % Draw an arrow, each line transformed according to keypoint parameters.
    TransformLine(imsize, new_loc2(i,:), 0.0, 0.0, 1.0, 0.0);
    TransformLine(imsize, new_loc2(i,:), 0.85, 0.1, 1.0, 0.0);
    TransformLine(imsize, new_loc2(i,:), 0.85, -0.1, 1.0, 0.0);
end


% drawing matching points
cols1 = size(im1,2);
for i = 1: size(des1,1)
  if (match(i) > 0)
    line([loc1(i,2) loc2(match(i),2)+cols1], ...
         [loc1(i,1) loc2(match(i),1)], 'Color', 'g');
  end
end
hold off;
num = sum(match > 0);
fprintf('Found %d matches.\n', num);

% This is the function from showkeys.m, Draw an arrow, each line transformed according to keypoint parameters.
function TransformLine(imsize, keypoint, x1, y1, x2, y2)

% The scaling of the unit length arrow is set to approximately the radius
%   of the region used to compute the keypoint descriptor.
len = 6 * keypoint(3);

% Rotate the keypoints by 'ori' = keypoint(4)
s = sin(keypoint(4));
c = cos(keypoint(4));

% Apply transform
r1 = keypoint(1) - len * (c * y1 + s * x1);
c1 = keypoint(2) + len * (- s * y1 + c * x1);
r2 = keypoint(1) - len * (c * y2 + s * x2);
c2 = keypoint(2) + len * (- s * y2 + c * x2);

line([c1 c2], [r1 r2], 'Color', 'r');




