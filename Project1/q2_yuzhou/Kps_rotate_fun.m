function [kps_rotate] = Kps_rotate_fun(width, height, kps, degrees)
    % Rotate the keypoints by calculating the degrees
    kps_rotate = kps;
    rad = pi * degrees / 180;
    
    %Calculate the new width and new height first
    for i = 1:size(kps,2)
        new_width = abs(width * cos(rad)) + abs(height * sin(rad));
        new_height = abs(width * sin(rad)) + abs(height * cos(rad));
        %Here, building the rotation matrix
        rotation_matrix = [cos(rad), -sin(rad);sin(rad), cos(rad)]*[(kps(1,i)-0.5*width);(0.5*height-kps(2,i))];
        
        %Give the rotation information to kps
        kps_rotate(1,i) = rotation_matrix(1,1) + 0.5 * new_width;
        kps_rotate(2,i) = 0.5 * new_height - rotation_matrix(2,1);
    end  
end