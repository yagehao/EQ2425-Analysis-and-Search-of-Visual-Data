%Read the input image
I = imread('obj1_5.JPG');
I_gray = single(rgb2gray(I));
figure(1);
imshow(I); hold on;

%SIFT part, setting the threshold first
peak_thresh = 10;
%The edge threshold eliminates peaks of the DoG scale space, which curvature is small
edge_thresh = 3.28;
[kps_sift,des_sift] = vl_sift(I_gray,'PeakThresh', peak_thresh, 'edgethresh', edge_thresh);
%Here, we get the threshhold time by time, to find a few hundred,500 keypoints

%Show the result of SIFT
sift = vl_plotframe(kps_sift) ;
set(sift,'color','red','linewidth',2) ;

%SURF part, setting the threshold first
I_gray = rgb2gray(I);
strongest_threshold = 1000;
surf_points = detectSURFFeatures(I_gray,'MetricThreshold',strongest_threshold);
[surf_kps, vpts1] = extractFeatures(I_gray, surf_points);

%Show the result of SURF
figure(2);
imshow(I); hold on;
plot(surf_points)