import numpy as np
from sklearn.cluster import KMeans


def get_sift(path, n_features, isClient):
    """Get retrieved SIFT features from .npy files."""
    data = []
    for i in range(50):
        k = i+1
        tmp = '_t' * isClient
        tmp = np.load(path + 'obj' + str(k) + tmp + '.npy', allow_pickle = True)[:, :n_features, :]
        tmp = tmp.reshape(-1, tmp.shape[2])
        data.append(tmp)
    return np.array(data) # 50*3000*128


def create_tree(data, b, depth):
    sift_features = np.concatenate(data, axis=0)
    n_objects = data.shape[0]

    #idx_features = np.arange(data.shape[0])
    #tree = hi_kmeans(sift_features, idx_features, b, depth, 0, n_objects)
    tree = hi_kmeans(sift_features, b, depth, n_objects)

    # link leaves with feature, 50obj * 3000feature * 128bits
    for i,obj in enumerate(data):
        for feature in obj:
            leaf = explore_next(tree, feature.reshape(1, -1), 0)
            tree[leaf]['objects'][i] += 1

    leaves = list((filter(lambda x: len(x['children']) == 0, tree)))
    return tree, leaves 


def explore_next(tree, feature, node):
    if tree[node]['model'] != None:
        cluster = tree[node]['model'].predict(feature)
        node = explore_next(tree, feature, tree[node]['children'][cluster[0]])
    return node 


def hi_kmeans1(sift_features, idx_features, b, depth, n, n_objects):
    data = sift_features[idx_features]
    datalist = []
    children = []
    kmeans = None 
    object_list = None 

    if data.shape[0] >= b and depth > 1:
        kmeans = KMeans(n_clusters = b, random_state = 0).fit(data)

        for i in range(b):
            idx_b = [idx_features[m] for m,n in enumerate(kmeans.labels_) if n==i]
            new_list = hi_kmeans1(sift_features, idx_b, b, depth-1, n+len(datalist)+1, n_objects)

            datalist += new_list
            children.append(new_list[-1]['i'])
    else:
        object_list = np.zeros(n_objects)
    datalist.append({'i':n, 'model':kmeans, 'children':children, 'objects':object_list})

    datalist = sorted(datalist, key=lambda k: k['i'])
    return datalist


def recursive(features, idx_features, b, depth, n, n_objects):

    data = features[idx_features]
    dList = []
    children = []
    kmeans = None
    obj_array = None
    v = np.mean(np.var(data, axis = 0))
    if data.shape[0] >= b and depth > 1:
            kmeans = KMeans(n_clusters = b, random_state = 0).fit(data)
            for i in range(b):

                idx_b = [idx_features[l] for l, ll in enumerate(kmeans.labels_) if ll == i]
                new_dList = recursive(features, idx_b, b, depth-1, n+len(dList)+1, n_objects)

                dList += new_dList
                children.append(new_dList[-1]['i'])
    else:
        obj_array = np.zeros(n_objects)
    dList.append({'i': n, 'model': kmeans, 'children': children, 'objects': obj_array})
    return dList

def hi_kmeans(data, b, depth, n_objects):
    dList = []

    dList = recursive(data, np.arange(data.shape[0]), b, depth, 0, n_objects)
    dList = sorted(dList, key = lambda k: k['i'])

    return dList


def tf_idf(leaves, data):
    n_objects = data.shape[0]
    print(n_objects)

    f = np.array(list(map(lambda x: x['objects'], leaves)))
    F = np.array(list(map(lambda x: x.shape[0], data)))
    K = np.array(list(map(lambda x: np.sum(x != 0), f)))
    #print(K)

    W = f/F * np.log2(K/n_objects).reshape(-1, 1)

    return W,f 



if __name__ == "__main__":

    # build tree
    b = 5
    depth = 7
    n_features = 1000
    print('b =', b)
    print('depth =', depth)

    # build server tree
    data = get_sift('sift1000/server/sift/', n_features = 1000, isClient = False)
    tree, leaves = create_tree(data, b, depth)
    W, M = tf_idf(leaves, data)
    print("TREE BUILT")

    # query
    query = get_sift('sift1000/client/sift/', n_features = 900, isClient = True)
    result = np.zeros((query.shape[0], len(leaves)))
    leaves1 = np.array(list(map(lambda x: x['i'], leaves)))
    for i, obj in enumerate(query):
        for feature in obj:
            leaf = explore_next(tree, feature.reshape(1,-1), 0)
            leaf = np.where(leaves1 == leaf)[0][0]
            result[i][leaf] += 1
    # print(result)
    N = result 
    q = N @ W 
    d = (M.T @ W).T 
    score = []
    for i,query in enumerate(q):
        score.append(np.linalg.norm(query/np.linalg.norm(query) - d/np.linalg.norm(d), axis = 1))
    score_sort = np.argsort(score, axis=1)[:,:5]
    top1 = np.sum([np.any(i == ss) for i, ss in enumerate(score_sort[:, :1])])
    top5 = np.sum([np.any(i == ss) for i, ss in enumerate(score_sort[:, :5])])
    print(top1/50)
    print(top5/50)


