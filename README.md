# Computer vision for 3D reconstructions from point cloud data

The objective of this coursework is to generate a 3D model of the inside of an office
room using a set of 3D point clouds generated by scanning the room using an Intel
RealSense depth sensor. The original data provided consists of 40 frames taken
from different viewpoints as the sensor is moved across the office. One clear pattern
that can be noticed by examining the frames is that frames include similar scenes
to one another (especially consecutive frames) so this pattern will be crucial in the
reconstruction process. The work can be divided into the following tasks:

1. Extract the relevant data from each point cloud
2. Estimate the reference transformation linking each consecutive pair of frames
3. Fuse all of the points into a single 3D coordinate system.
4. Evaluate the quality of the final model
