%Alternative approach for eliminating flying pixels using pcdenoise
rgb = office{27}.Color; % Extracting the colour data
points = office{27}.Location; % Extracting the xyz data

pc = pointCloud(points, 'Color', rgb);

[ptCloudOut,inlierIndices,outlierIndices] = pcdenoise(pc);

rgb_reshaped= rgb.';


outlierIndices_transposed = outlierIndices.';
for i = outlierIndices_transposed
       rgb_reshaped(1,i)=0;
       rgb_reshaped(2,i)=0;
       rgb_reshaped(3,i)=0; 
end
rgb_reshaped_back=rgb_reshaped.'; 

figure(1)
pcshow(ptCloudOut)
figure(2)
imag2d(rgb_reshaped_back) 




