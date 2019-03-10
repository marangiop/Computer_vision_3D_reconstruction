office = load('office1.mat');
office = office.pcl_train;

%%Image 1
rgb = office{27}.Color; % Extracting the colour data
point = office{27}.Location; % Extracting the xyz data
pc = pointCloud(point, 'Color', rgb); % 

%%Image 2
rgb_2 = office{28}.Color; % Extracting the colour data
point_2 = office{28}.Location; % Extracting the xyz data
pc_2 = pointCloud(point_2, 'Color', rgb_2); % 
%%
figure(1)
pcshow(pc)
xlabel('X(m)')
ylabel('Y(m)')
zlabel('Z(m)')
title('Original Point Cloud - Frame 1')

%figure(1)
%pcshow(pc_2)
%xlabel('X(m)')
%ylabel('Y(m)')
%zlabel('Z(m)')
%title('Original Point Cloud - Frame 2')
%%
maxDistance = 0.02;
[model1,inlierIndices,outlierIndices]= pcfitplane(pc, maxDistance);
plane1 = select(pc,inlierIndices);

[model2,inlierIndices_2,outlierIndices_2]= pcfitplane(pc_2, maxDistance);
plane2 = select(pc_2,inlierIndices_2);

figure
pcshow(plane1)
title('First Plane - Frame 1')

hold on
plot(model1)

%%

%figure(2)
%pcshow(plane2)
%title('First Plane - Frame 2')
%hold on
%plot(model2)

%%
%calculating angle between planes
a=model1.Parameters(1);
b=model1.Parameters(2);
c=model1.Parameters(3);

e=model2.Parameters(1);
f=model2.Parameters(2);
g=model2.Parameters(3);


%normals to the planes
v=[a,b,c];
v1=[e,f,g];

%converting to unit length
v = v/norm(v);
v1= v1/norm(v1);

%angle between the normals to two planes is the same as the angle between those planes
ang = atan2(norm(cross(v,v1)),dot(v,v1)); 
ang_in_degrees = rad2deg(ang)

%in what units is this angle?





