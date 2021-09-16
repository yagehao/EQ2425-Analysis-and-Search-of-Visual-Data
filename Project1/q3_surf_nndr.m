clear;

% read in training and test images
train_raw = imread('data1/obj1_5.JPG');
test_raw = imread('data1/obj1_t1.JPG');
% convert to grayscale
train = rgb2gray(train_raw);
test = rgb2gray(test_raw);

% SURF
% keypoint detectors
train_surf = detectSURFFeatures(train);
train_surf = train_surf.selectStrongest(250);
[train_surf_descriptor, train_surf] = extractFeatures(train, train_surf);
train_surf_descriptor = train_surf_descriptor';
train_surf_coord = train_surf.Location';

test_surf = detectSURFFeatures(test);
test_surf = test_surf.selectStrongest(250);
[test_surf_descriptor, test_surf] = extractFeatures(test, test_surf);
test_surf_descriptor = test_surf_descriptor';
test_surf_coord = test_surf.Location';

% check number of keypoints
train_num = size(train_surf_coord,2);
test_num = size(test_surf_coord,2);


% nearest neighbor distance ratio matching

% set parameters
ratio_threshold = 0.8;
counter = 0;

% compute distance ratio between the nearest and the second nearest
for i = 1:train_num
    nearest_distance = inf;
    second_distance = inf;
    for j = 1:test_num
        distance = sqrt(sum((train_surf_descriptor(:,i)-test_surf_descriptor(:,j)).^2));
        if distance < nearest_distance
            nearest_distance = distance;
            nearest_indexj = j;
        elseif (nearest_distance<distance) && (distance<second_distance)
            second_distance = distance;
            second_indexj = j;
        end
    end
    ratio = nearest_distance / second_distance;
    if ratio < ratio_threshold
        counter = counter + 1;
        match(counter,1) = i;
        match(counter,2) = nearest_indexj;
    end
end

% plot
figure(5);
imshow([train_raw, test_raw]);
hold on;
% plot train
train_surf.plot;
% plot test
test_surf_plot = test_surf;
test_surf_plot.Location(:,1) = test_surf.Location(:,1) + size(test,2);
test_surf_plot.plot;
hold on;
% plot matching
for i = 1:counter
    train_match_index = match(i,1);
    test_match_index = match(i,2);
    plot([train_surf.Location(train_match_index,1) test_surf_plot.Location(test_match_index,1)],...
    [train_surf.Location(train_match_index,2) test_surf_plot.Location(test_match_index,2)], 'y');
end
title('SURF Keypoints with Nearest Neighbor Distance Ratio Matching');
 