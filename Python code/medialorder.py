import numpy as np
from numpy import *
import scipy.sparse as sps

def medialorder(medialdata): 
    m2 = medialdata[:,0]
    r2 = medialdata[:,1]
    triin2 = medialdata[:,2:5]

    nt = triin2.shape[0]                          # nt = size(triin2,1)  == 3

    array1 = array(range(1,nt+1))
    array2 = array(range(1,nt+1))
    array3 = array(range(1,nt+1))
    array_new = np.append(array1,array2)
    array_new = np.append(array_new,array3)
    I = np.array(array_new)
    mat_I = mat(I)

    J = triin2.flatten('F')    # triin2(:)
    array_J = J.real.astype(int)

    V = np.ones((3*nt),dtype=int)                              # ones(1,3*nt)
    #print("V:",V)

    B1 = sps.csr_matrix((V, (I, array_J))).toarray()
    B2 = np.transpose(B1)
    B = np.dot(B1,B2)

    C = np.where(B > 1)
    array_x = C[0]
    array_y = C[1]
    new_x = []
    new_y = []

    zipped = list(zip(array_x,array_y))
    #print(zipped)
    for i in range(len(zipped)):
        a1 = zipped[i][0]
        b1 = zipped[i][1]
        if a1 > b1:
            new_x.append(a1)
            new_y.append(b1)

    list1 = []
    list2 = []
    for i in range(len(new_x)):
        list1.append(m2[new_x[i] - 1].tolist())
        list2.append(m2[new_y[i] - 1].tolist())

    mord = np.asmatrix(np.array([list1,list2]))
    return mord 

''' simple test case
# medialdata = np.mat([[1,2,8,9,11],[4,5,6,12,12],[7,8,9,17,6],[7,8,9,17,6],[7,8,9,17,6]])
# # [1 2 8 9 11; 4 5 6 12 12; 7 8 9 17 6; 7 8 9 17 6; 7 8 9 17 6]
# # print(medialdata)
# mord = medialorder(medialdata)
# print(mord)
'''