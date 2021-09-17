% nearest neighbor matching

% compute distance and keep the minimum
for i = 1:train_num
    min_distance = inf;
    for j = 1:test_num
        distance = sqrt(sum((train_sift_descriptor(:,i)-test_sift_descriptor(:,j)).^2));
        if distance < min_distance
            min_distance = distance;
            index_j = j;
        end
    end
    match(i,1) = i;
    match(i,2) = index_j;
end

% plot
figure(3);
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
% plot matching
for i = 1:train_num
    train_match_index = match(i,1);
    test_match_index = match(i,2);
    plot([train_sift(1,train_match_index) test_sift_plot(1,test_match_index)],...
    [train_sift(2,train_match_index) test_sift_plot(2,test_match_index)], 'y');
end
legend('obj1\_5.JPG','obj1\_t1.JPG');
title('SIFT Keypoints with Nearest Neighbor Matching');
            
    