function [kps_scale] = Kps_scale_fun(width, height, kps, m)
    % Scale the coordinates based on the center point of the image.
    kps_scale = kps;
    
    %Get the new width and height first
    for i = 1:size(kps,2)
        new_width = width * m;
        new_height = height * m;
        
        %Here, building the scale matrix
        scale_matrix = [m, 0;0, m]*[(kps(1,i)-0.5 * width);(0.5 * height - kps(2,i))];
        
        %Give the scale information to kps
        kps_scale(1,i) = scale_matrix(1,1) + 0.5*new_width;
        kps_scale(2,i) = 0.5 * new_height - scale_matrix(2,1);
    end  
end