import numpy as np 

class BlumMedialAxis:
    '''
    BlumMedialAxis defines a class to represent a Blum Medial Axis. Let bma be an object of the BlumMedialAxis class. 
    Then bma.boundary(i) is a point on the boundary curve that gives the axis. bma. bma.pointsArray(j) is the location of a point on the medial axis, 
    bma.radiiArray(j) is the radius associated with that point, bma.EDFArray(j) is the EDF associated with the point, 
    bma.indexOfBndryPoints(j) is a 3x1 array of which each element is the index in bma.boundary of one of the boundary points that defined the point, 
    and bma.onMedialResidue(j) is a boolean assigned true if the point at j is on the medial residue of bma. bma.adjacencyMatrix is a square matrix 
    such that bma.adjacencyMatrix(m,n) and bma.adjacencyMatrix(n,m) are both true when there exists an adjacency between the two points at m and n.
    '''

    def __init__(self, boundary):
        self.boundary = boundary    
        # pointsArray = None
        # radiiArray = None
        # EDFArray = None
        # WEDFArray = None
        # indexOfBndryPoints = None
        # onMedialResidue = None
        # adjacencyMatrix = None
        # erosionThickness = None
        # shapeTubularity = None
        # pointType = None
        # branchNumber = None
        # branchAdjacency = None

        ## private data attribute
        # _medialData = medialaxis(boundary)

    def medialaxis(self):
        z = self.boundary 
        if np.dot((real(z) - np.roll(real(z),-1)), (imag(z) + np.roll(imag(z),-1))) > 0: 
            z = np.flipud(z);

        # ...
        # return z, _medialData 
        pass

    def medialorder(self):
        # mord = medialorder(self._medialData)
        # ...
        pass 

    def buildPoints(self):
        psss 

    def findOrAdd(self, _medialData, point):
        '''
        FINDORADD Attempts to find the index of point in bma.pointsArray. If the point is not in bma.pointsArray, then it adds the point with the appropriate information from medialData.
        '''
        index = np.where(bma.pointsArray == point) 
        indexInMD = np.where(_medialData[:, 1] == point)
        
        # check if they have the same boundary points
        dbp1=0
        dbp2=0
        if (index.size == 1):
            bp1 = np.sort(_medialData[indexInMD[0], 2:4])
            bp2 = np.sort(bma.indexOfBndryPoints[index,:])
            dbp1 = (np.where(bp1 != bp2).size != 0) # they have different boundary points
            if (len(indexInMD) >= 2):
                 bp3 = np.sort(_medialData[indexInMD[1], 2:4])
                 dbp2 = (np.where(bp3 != bp2).size != 0) # they have different boundary points

        if ((index.size == 0) or dbp1 or dbp2):                
              # if they have different boundary points: keep point
              bma.pointsArray = np.append(bma.pointsArray, point)
              bma.radiiArray = np.append(bma.radiiArray, _medialData[indexInMD(0), 1])
              if ((index.size == 0) or dbp1):
                bma.indexOfBndryPoints = np.append(bma.indexOfBndryPoints, _medialData[indexInMD[0], 2:4])
              else:
                bma.indexOfBndryPoints = np.append((bma.indexOfBndryPoints, _medialData[indexInMD[1], 2:4]))
              index = bma.pointsArray.size

        return index, self 