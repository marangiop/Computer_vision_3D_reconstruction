% Step 1: I have saved all the matlab scripts and images in folder called Labs

% Step 2
rgb_hand = imread('Labs/hand.png'); 
rgb_hand = im2double(rgb_hand); % transform variable to double
hsv_hand = rgb2hsv(rgb_hand); % transform to the HSV colour space 
s = hsv_hand(:,:,2); %store the second dimension (i.e. saturation) in variable s 

% Now we show the rgb_hand and the s colour space
subplot (1,2,1), imshow(rgb_hand)
subplot (1,2,2), imshow(s)

% Step 3
% Now we observe how changing the threshold will affect the Canny edge detection of the output
%-General command is BW = edge(I,'Canny',threshold,sigma).
%-edge returns a binary image which contains the edges of the objects in the image.
%-I is the image from which we want to obtain the edges
%-Canny is the edge detector
%-threshold must be between 0 and 1
%-sigma is the standard deviation of the Gaussian filter

BW01 = edge(s, 'Canny',0.1); 
BW015 = edge(s, 'Canny',0.15); 
BW02 = edge(s, 'Canny',0.2); 
BW02 = edge(s, 'Canny',0.25); 
BW03 = edge(s, 'Canny',0.3); 

% Now we show the images for Canny edge detector with thresholds 0.1 and 0.3
figure, imshow(BW01)
figure, imshow(BW03)


% Step 4
% Understanding morphological operations: erosion and dilation
%-Dilation is used to gradually enlarge the boundaries of regions of foreground pixels. 
%-Erosion is used to do the opposite of dilation.
%-Dilation and erosion have two inputs: a binary image and a structuring element object.
%-The structuring element can have different shapes (e.g. line, square,
%-disk)and it represents the number of pixels that will be expanded or
%shrunk.
%-strel object represents the flat morphological structuring element.

% Step 5
%-Applying dilation and erosion to hand image with edges detected 
ed_canny = edge(s,'Canny', 0.2) ;
% Structuring element
SE = strel('square', 3) ;
SE2 = strel('square', 8) ;
% Morphological operation
erosion = imerode(ed_canny , SE);
dilation = imdilate(ed_canny , SE2);
subplot (1,3,1), imshow(ed_canny)
subplot (1,3,2), imshow(erosion)
subplot (1,3,3), imshow(dilation)
% Conclusion: Applying erosion makes the lines of edges to become too thin
% and no longer visible. Applying dilation makes the edges thicker.


% Step 6
% Colour thresholding is a basic operation that allows us to use the intensity values of our image to create binary images or masks.
filled_fingers = imfill(dilation, 'holes'); %fill the holes inside the boundaries created by dilated version of image with edge detected
SE3 = strel('square', 15);
erode_fingers = imerode(filled_fingers, SE3); %We use erson to reduce the thickness of the fingers. We consider this as our mask.

% We put the mask on the rgb image using the bsxfun command
masked_hand = bsxfun(@times, rgb_hand, cast(erode_fingers, 'like', rgb_hand));
subplot ( 1 , 2 , 1 ) , imshow(erode_fingers);
subplot ( 1 , 2 , 2 ) , imshow(masked_hand);
% Conclusion: our mask has segmented most of the fingers correctly.However, there is a green region from the background that was also segmented.

% Step 7
% We need to find a sensible threshold in the green colour space to
% eliminate the green region without affecting the colour of the fingers.

G = rgb_hand(:,:,2); %This returns the G channel; R is 1, G is 2, B is 3
imshow(G);
mask_G = G.*erode_fingers; % create a mask based on the green colour space and the previous mask;.* returns elementwise multiplication of the two arrays
imshow(mask_G) % Shows the binary mask .

tr=0.85; %Use the image mask_G to find the value of the threshold. 
mask_G(mask_G>tr)=0;%We threshold the intensity value of our new mask . All values above "tr" will become 0.
mask_G(mask_G>0)=1; %We make our mask a binary image 

new_masked_hand = bsxfun(@times , rgb_hand , cast(mask_G, 'like',rgb_hand));
subplot( 1 , 2 , 1 ) , imshow(masked_hand)
subplot( 1 , 2 , 2 ) , imshow(new_masked_hand)


% Step 8
% Label the 5 fingers
% If there is a small area near the palm of the hand, we can eliminate it using bwareopen.  
mask_G = bwareaopen(mask_G, 50); % Only the objects with area (pixels)>50 will remain

lbl = bwlabel(mask_G, 4);
imshow(lbl==1)
imshow(lbl==2)
imshow(lbl==3)
imshow(lbl==4)
imshow(lbl==5)

% Step 9
%- Draw a bounding box.
%- General formula is RGB = insertObjectAnnotation(I, shape, position, label);
%- I is the image where we want to draw the bounding box, 
%- shape is to select the type of bounding box( rectangle or circle)
%- position is the location and size of the bounding box.
%- label is the text that will be displayed.
%- We will use rectangle as a shape, so we need to provide four values: x, y, width, and height to the function. 
%- The elements, x and y, indicate the upper-left corner of the rectangle
%- The width and height specify the size.


close all;
%We will concatenate the positions of our 5 fingers , so we initialize the position as empty 
position=[];

% Names for our fingers
label_str={['Pinky'],['Ring Finger'], ['Middle Finger'], ['Index Finger'], ['Thumb']};

%Go through all the 5 labels to find the maximum and minimum row (r) and column (c)

for i =1:5
[r,c]=find(lbl==i);
max_r=max(r);
min_r=min(r);
max_c=max(c);
min_c=min(c);
width = max_c-min_c+1; % obtaining the width of the bounding box
height = max_r-min_r+1; % obtaining the height of the bounding box
position = [position;[min_c, min_r, width, height]]; % concatenating the positions of the fingers
end

rgb=insertObjectAnnotation(rgb_hand, 'rectangle', position, label_str, 'Color', 'red' , 'FontSize' ,10);
imshow(rgb)



