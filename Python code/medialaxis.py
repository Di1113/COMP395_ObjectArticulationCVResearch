import numpy as np
from scipy.spatial import Delaunay
import matplotlib.pyplot as plt
import cv2


def medialaxis(boundary):

    # Function:       medialaxis(boundary)
    # Description:    given sorted boundary points, outputs a matrix medial data: medial points, radii and triangles
    # Input:          bounday - a vector of sorted complex valued boundary points.
    # Output:         medialdata[m r triin] - m is the collection of points on the medial axis, r is the associated radii, and triin is the delaunay triangulation of the boundary corresponding to triangles entirely inside the boundary.

    boundary = np.array(boundary)
    if np.dot(np.squeeze(boundary.real - np.roll(boundary.real,-1)), np.squeeze(boundary.imag + np.roll(boundary.imag ,-1))) > 0: 
        boundary = np.flipud(boundary)

    # print(boundary) 
    coordinates = []
    for i in boundary:
        coordinates.append([i.real, i.imag])

    points = np.array(coordinates)
    # print("points") 
    # print(points) 

    tri = Delaunay(points)
    # '''
    plt.scatter(points[:,0], points[:,1])
    plt.plot(points[:,0], points[:,1]) # plots boundary points with connected lines
    # plt.triplot(points[:,0], points[:,1], tri.simplices) # plots Delaunay triangles  
    # plt.plot(points[:,0], points[:,1], 'o') # plots boundary points
    # plt.show()
    # '''
    tri = np.array(tri.simplices)
    tri.sort(axis=1)

    u = boundary[tri[:, 0]]
    v = boundary[tri[:, 1]]
    w = boundary[tri[:, 2]]
    dot = (u - w) * np.conj(v - w)

    m = (u + v + 1j * (u - v) * dot.real / dot.imag) / 2
    r = abs(u - m)

    inside = dot.imag > 0
    triin = tri[inside, :]
    m = m[inside]
    r = r[inside]

    # print("m")
    # print(len(m))
    # print("r")
    # print(len(r))

    plt.plot(m.real, m.imag, 'o')
    plt.show()

    result = []
    result.append(m)
    result.append(r)
    result.append(triin)

    return result


# test data: p1-p6
# p1 = complex(1, 1)
# p2 = complex(3, 2)
# p3 = complex(5, 2)
# p4 = complex(3, 4)
# p5 = complex(1, 5)
# p6 = complex(3, 6)

# z = np.array([p1, p2, p3, p4, p5, p6])
# print(z)
# a = medialaxis(z)
# print(a)
# should print: 
# [array([4.  +3.j, 1.25+3.j, 1.25+3.j]), array([1.41421356, 2.01556444, 2.01556444]), array([[2, 3, 4],[1, 2, 4],[1, 4, 5]], dtype=int32)]

# test data: heart  
'''
pt1 = complex(4,-2) 
pt2 = complex(5,-1) 
pt3 = complex(6,-.5) 
pt4 = complex(7,-1) 
pt5 = complex(8,-2) 
pt6 = complex(8.5,-3) 
pt7 = complex(8,-4) 
pt8 = complex(7,-6) 
pt9 = complex(5,-8) 
pt10 = complex(4,-9)
pt11 = complex(3,-8) 
pt12 = complex(1,-6) 
pt13 = complex(0,-4) 
pt14 = complex(-.5,-3) 
pt15 = complex(0,-2) 
pt16 = complex(1,-1) 
pt17 = complex(2,-.5) 
pt18 = complex(3,-1) 
pt19 = complex(4,-2)
z = np.array([pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8, pt9, pt10, pt11, pt12, pt13, pt14, pt15, pt16, pt17, pt18, pt19])
# test data for matlab  
# heart = [4.-2.i   5.-1.i   6.-0.5i  7.-1.i   8.-2.i   8.5-3.i   8.-4.i 7.-6.i   5.-8.i   4.-9.i   3.-8.i   1-6.i   0.-4.i  -0.5-3.i 0.-2.i   1.-1.i   2.-0.5i  3.-1.i   4.-2.i]

a = medialaxis(z)
'''

# test data: ginger man 
# '''
# x = [(0,9) , (1,8) , (1.5,7) , (2,5) , (1.5,3) , (0.5,1.5) , (3,1) , (4,1) , (5,1.5) , (6,2) , (7,1.5), (7.5,1) , (8,0) , (7,-1.5) , (5,-2.5) , (4,-2.5) , (2.5,-3) , (2,-4) , (2,-6.5) , (2,-7.5) , (2,-8), (2.5,-9.5) , (3.5,-11) , (4,-12) , (5,-13.5) , (5,-14.5) , (4.5,-15.5) , (2,-16) , (0.5,-14.5) , (-0.5,-13.5), (-1.5,-12) , (-2.5,-9.5) , (-4,-12) , (-4.5,-13) , (-5,-14) , (-6,-15) , (-8,-16) , (-9.5,-15.5) , (-10.5,-14), (-10,-13) , (-9,-11.5) , (-8.5,-11) , (-7.5,-9) , (-7,-8) , (-7,-7) , (-7,-6) , (-6.5,-4) , (-7,-3), (-9.5,-2.5) , (-10.5,-2) , (-11.5,-1.5) , (-13,0) , (-12.5,1) , (-12,2), (-10,2), (-9,1.5), (-8,1.5), (-7,1.5), (-6,2), (-7,4), (-7,6), (-6,8), (-5,9), (-2.5,9.5), (0,9)]
# z = []
# # print(len(x))
# for y in x:
#     f = complex(y[0], y[1])
#     z.append(f)
# # print(z)
# a = medialaxis(z)
# print(a)
# '''