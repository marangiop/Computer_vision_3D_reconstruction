rgb = office{27}.Color; % Extracting the colour data
point = office{27}.Location; % Extracting the xyz data
imag2d(rgb)

%The while loop and variables declaration need to be commented out after
%they have been run once 

%I used this script in order to get the coordinate values of the bounding
%https://www.youtube.com/watch?v=_lNngeLivJ8

i = 1; x=0; spos=[]; % variables

while x~=1
    
    imag2d(rgb); 
    rect=imrect;
    
    pos = getPosition(rect);
    r = insertShape(rgb, 'Rectangle', pos);
    rgb=r;
    
    imag2d(rgb)
        spos=[spos;pos];
        xlswrite('C:\Users\maran\Desktop\Semester 2\Advanced Vision\Coursework\aa.xlsx', spos);
    
end

%The while loop and variables declaration need to be commented out after
%they have been run once 



%This draws a rectangle on the image 
hold on
rectangle('Position', [91,6,235,475], 'EdgeColor','r', 'LineWidth', 3)





%This sets all the values within the rectangle to 0 - NOT WORKING

new_rgb =[];
color_pc = rgb;
r = color_pc(:,1);
g = color_pc(:,2);
b = color_pc(:,3);
rec_r = reshape(r, [640, 480]);
rec_g = reshape(g, [640, 480]);
rec_b = reshape(b, [640, 480]);
new_rgb = cat(3, rec_r', rec_g', rec_b');

x_coord_lower = 6;
y_coord_lower = 91;
new_rgb(x_coord_lower:475+x_coord_lower, y_coord_lower:235+y_coord_lower, : )= 0;   
imshow(new_rgb)
pause(0.1)




