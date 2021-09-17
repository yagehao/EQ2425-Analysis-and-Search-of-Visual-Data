% Read the input image
I = imread('obj1_5.JPG');
I_gray_single = single(rgb2gray(I));

%SIFT part, setting the threshold first
peak_thresh = 10;
edge_thresh = 3.28;
[kps_sift,des_sift] = vl_sift(I_gray_single,'PeakThresh', peak_thresh, 'edgethresh', edge_thresh);
x = [];
y = [];

%%SURF part, setting the threshold first
I_gray = rgb2gray(I);
strongest_threshold = 5730;
surf_points = detectSURFFeatures(I_gray,'MetricThreshold',strongest_threshold);
kps_surf = surf_points.Location';
x_surf = [];
y_surf = [];
    
m = 1.2;

% Scale the images to get 8 different modified images
for i = 0:1:8
    %SIFT part
    I_gray_single_modify = imresize(I_gray_single, m);
    count_matches = 0;
    
    % Find the keypoints of modified image
    [kps_sift_modify,des_sift_modify] = vl_sift(I_gray_single_modify,'PeakThresh', peak_thresh, 'edgethresh', edge_thresh);
    % Scale the coordinates of the original image
    kps_sift_scaled = Kps_scale_fun(size(I,2), size(I,1),kps_sift,m);
    
    %To find if the keypoints of modified image is already matched
    flags = zeros(1,size(kps_sift_modify,2));
    kps_sift_modify = [kps_sift_modify; flags];
    
    %Using loop to compare different keypoints in both images
    for j = 1:size(kps_sift_scaled,2)
        for k = 1:size(kps_sift_modify,2)
            %When the keypoints of modified image hasn't been mathced
            if kps_sift_modify(5,k) == 0
                x1 = kps_sift_modify(1,k);
                y1 = kps_sift_modify(2,k);
                
                x0 = kps_sift_scaled(1,j);
                y0 = kps_sift_scaled(2,j);
                
                %Counting the matches number
                if abs(x1-x0) <= 2 && abs(y1-y0) <= 2
                    count_matches = count_matches + 1;
                    kps_sift_modify(5,k) = 1;
                end
            end
        end
    end
    
    %Compute repeatability by using the matches number
    repeatability = count_matches / size(kps_sift_scaled,2);
    y = [y,repeatability];
    x = [x,i];
    
    %SURF part, which is very similar
    I_gray_modify = imresize(I_gray, m);
    count_matches = 0;
    
    % Find the keypoints of modified image
    points_surf_modify = detectSURFFeatures(I_gray_modify,'MetricThreshold',strongest_threshold);
    kps_surf_modify = points_surf_modify.Location';
    
    % Scale the coordinates of the original image
    kps_surf_scaled = Kps_scale_fun(size(I,2), size(I,1),kps_surf,m);
    
    %To find if the keypoints of modified image is alread matched
    flags = zeros(1,size(kps_surf_modify,2));
    kps_surf_modify = [kps_surf_modify; flags];
    
    %Using loop to compare different keypoints in both images
    for j = 1:size(kps_surf_scaled,2)
        for k = 1:size(kps_surf_modify,2)
            %When the keypoints of modified image hasn't been mathced
            if kps_surf_modify(3,k) == 0
                x1 = kps_surf_modify(1,k);
                y1 = kps_surf_modify(2,k);
                
                x0 = kps_surf_scaled(1,j);
                y0 = kps_surf_scaled(2,j);
                
                %Counting the matches number
                if abs(x1-x0) <= 2 && abs(y1-y0) <= 2
                    count_matches = count_matches + 1;
                    kps_surf_modify(3,k) = 1;
                end
            end
        end
    end
    
    %Compute repeatability by using the matches number
    repeatability = count_matches / size(kps_surf_scaled,2);
    y_surf = [y_surf,repeatability];
    x_surf = [x_surf,i];   
    
    m = m * 1.2;
end

plot(x,y,'red--o','LineWidth',1.5 ); hold on;
plot(x_surf,y_surf,'blue--*','LineWidth',1.5 );    

title('Repeatability vs Scale');           
xlabel('Scale');                    
ylabel('Repeatability');  
legend('SIFT','SURF')