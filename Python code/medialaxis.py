import numpy as np
from scipy.spatial import Delaunay
import matplotlib.pyplot as plt
import cv2


def medialaxis(boundary):
    """
    Function:       medialaxis(boundary)
    Description:    given sorted boundary points, outputs a matrix medial data: medial points, radii and triangles
    Input:          bounday - a vector of sorted complex valued boundary points.
    Output:         medialdata[m r triin] - m is the collection of points on the medial axis, r is the associated radii, and triin is the delaunay triangulation of the boundary corresponding to triangles entirely inside the boundary.
    """
    boundary = np.array(boundary)
    if np.dot(np.squeeze(boundary.real - np.roll(boundary.real,-1)), np.squeeze(boundary.imag + np.roll(boundary.imag ,-1))) > 0: 
        boundary = np.flipud(boundary)

    coordinates = []
    for i in boundary:
        coordinates.append([i.real, i.imag])

    points = np.array(coordinates)

    tri = Delaunay(points)
    '''
    ######################## visualization for debugging ############################
    plt.scatter(points[:,0], points[:,1])
    plt.plot(points[:,0], points[:,1]) # plots boundary points with connected lines
    plt.triplot(points[:,0], points[:,1], tri.simplices) # plots Delaunay triangles  
    plt.plot(points[:,0], points[:,1], 'o') # plots boundary points
    plt.show()
    #################################################################################
    '''
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

    result = []
    result.append(m)
    result.append(r)
    result.append(triin)

    return result


# test data: ginger man 
'''
x = [(0,9) , (1,8) , (1.5,7) , (2,5) , (1.5,3) , (0.5,1.5) , (3,1) , (4,1) , (5,1.5) , (6,2) , (7,1.5), (7.5,1) , (8,0) , (7,-1.5) , (5,-2.5) , (4,-2.5) , (2.5,-3) , (2,-4) , (2,-6.5) , (2,-7.5) , (2,-8), (2.5,-9.5) , (3.5,-11) , (4,-12) , (5,-13.5) , (5,-14.5) , (4.5,-15.5) , (2,-16) , (0.5,-14.5) , (-0.5,-13.5), (-1.5,-12) , (-2.5,-9.5) , (-4,-12) , (-4.5,-13) , (-5,-14) , (-6,-15) , (-8,-16) , (-9.5,-15.5) , (-10.5,-14), (-10,-13) , (-9,-11.5) , (-8.5,-11) , (-7.5,-9) , (-7,-8) , (-7,-7) , (-7,-6) , (-6.5,-4) , (-7,-3), (-9.5,-2.5) , (-10.5,-2) , (-11.5,-1.5) , (-13,0) , (-12.5,1) , (-12,2), (-10,2), (-9,1.5), (-8,1.5), (-7,1.5), (-6,2), (-7,4), (-7,6), (-6,8), (-5,9), (-2.5,9.5), (0,9)]
z = []
# print(len(x))
for y in x:
    f = complex(y[0], y[1])
    z.append(f)
a = medialaxis(z)
plt.plot(a[0].real, a[0].imag, 'o')
plt.show()
print(a)
# '''