import cv2
import os
import glob
import numpy as np

def Features_sift(image, features_number = 1000):

    # Open our images
    rgb_img = image[:, :, ::-1] 

    # Finding the keypoints
    sift = cv2.SIFT_create(nfeatures = features_number)
    keyponits, descriptors = sift.detectAndCompute(image, None)

    return keyponits, descriptors

number_obj = 50

# Server part
server_path = 'Data2/server/'
os.makedirs(server_path + 'sift', exist_ok = True)

for i in np.arange(number_obj)+1:
    
    # Setting the path for it
    image_path = glob.glob(server_path + 'obj' + str(i) + '_*.JPG')
    
    with open(server_path + 'sift/obj' + str(i) + '.npy', 'wb') as f:
        depths = []
        for path in image_path:
            
            image = cv2.imread(path, cv2.IMREAD_COLOR)
            _, depth = Features_sift(image)
            depths.append(depth[:1000])
            
        # Save the features    
        np.save(f, np.array(depths))

# Client part
client_path = 'Data2/client/'
os.makedirs(client_path + 'sift', exist_ok = True)

for i in np.arange(number_obj)+1:
    
    # Setting the path for it
    image_path = glob.glob(client_path + 'obj' + str(i) + '_*.JPG')[0]

    with open(client_path + 'sift/obj' + str(i) + '_t.npy', 'wb') as f:

        image = cv2.imread(image_path, cv2.IMREAD_COLOR)
        _, depth = Features_sift(image)
        depth = depth[:1000].reshape((1, depth[:1000].shape[0], depth[:1000].shape[1]))

        # Save the features
        np.save(f, depth)
