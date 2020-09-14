import numpy as np

# test code 
boundary = 


'''
Function:       medialaxis(boundary)
Description:    given sorted boundary points, outputs a matrix medial data: medial points, radii and triangles 
Input:          bounday - a vector of sorted complex valued boundary points. 
Output:         medialdata[m r triin] - m is the collection of points on the medial axis, r is the associated radii, and triin is the delaunay triangulation of the boundary corresponding to triangles entirely inside the boundary.
'''
def medialaxis(boundary):
    if np.dot((real(boundary) - np.roll(real(boundary),-1)), (imag(boundary) + np.roll(imag(boundary),-1))) > 0: 
        boundary = np.flipud(boundary);

    return boundary, medialdata 