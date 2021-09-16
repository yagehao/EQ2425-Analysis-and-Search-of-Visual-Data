clear;

% read in training and test images
train_raw = imread('data1/obj1_5.JPG');
test_raw = imread('data1/obj1_t1.JPG');
% convert to grayscale and normalize
train = single(rgb2gray(train_raw));
test = single(rgb2gray(test_raw));

% SIFT
% parameter settings
peakthresh = 14;
edgethresh = 7;
% keypoint detectors
[train_sift, train_sift_descriptor] = vl_sift(train,'PeakThresh',peakthresh,'EdgeThresh',edgethresh);
[test_sift, test_sift_descriptor] = vl_sift(test,'PeakThresh',peakthresh,'EdgeThresh',edgethresh);
% check number of keypoints
train_num = size(train_sift,2);
test_num = size(test_sift,2);

% plot
figure(1);
imshow([train_raw, test_raw]);
hold on;
% plot train
h1 = vl_plotframe(train_sift);
set(h1,'color','r','linewidth',4);
% plot test
test_sift_plot = test_sift;
test_sift_plot(1,:) = test_sift(1,:) + size(test,2);
h2 = vl_plotframe(test_sift_plot);
set(h2,'color','b','linewidth',4);
hold on;
legend('obj1\_5.JPG','obj1\_t1.JPG');
title('SIFT Keypoints');
