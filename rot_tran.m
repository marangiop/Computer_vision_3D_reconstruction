function [R, T] = rot_tran(points_set_m, points_set_d)    % return rotation matrix and translation matrix given matching points set
% points set = [X1,...,XN;Y1,...YN;Z1,...,ZN]  3xN matrix
% correlation matrix H 3x3
H = points_set_m' * points_set_d;
% SVD
[U, ~, V] = svd(H);
% Rotation matrix  3x3
R = V * U';
% mean of points_set_m  3x1 vector
mean_m = [mean(points_set_m(1, :)), mean(points_set_m(2, :)), mean(points_set_m(3, :))]';
mean_d = [mean(points_set_d(1, :)), mean(points_set_d(2, :)), mean(points_set_d(3, :))]';
% Translation matrix 3x1 vector
T = mean_d - R * mean_m;
end