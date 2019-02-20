function R_x_y_z = rot_x_y_z(a, b, c)    % rotation angle a,b,c
% code
R_x = [1, 0, 0, 0; 0, cos(a), -sin(a), 0; 0, sin(a), cos(a), 0; 0, 0, 0, 1];
R_y = [cos(b), 0, sin(b), 0; 0, 1, 0, 0; -sin(b), 0, cos(b), 0; 0, 0, 0, 1];
R_z = [cos(c), -sin(c), 0, 0; sin(c), cos(c), 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
R_x_y_z = R_x * R_y * R_z;
end