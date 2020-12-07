import math

class BMA:

    def __init__(self, pointsArray, WEDFArray, adjacencyMatrix):
        self.pointsArray = pointsArray
        self.WEDFArray = WEDFArray
        self.adjacencyMatrix = adjacencyMatrix

def main():
    pointsArray = 
    WEDFArray = 
    adjacencyMatrix = 
    bma = BMA(pointsArray, WEDFArray, adjacencyMatrix)


if __name__ == "__main__":
    main()

def getRoot(bma):
    # This function returns the index of the node with the highest WEDF value in the bma
    rootIdx = bma.pointsArray.index(max(bma.WEDFArray))
    return rootIdx

def getChild(nodeIdx, bma):
    # This function returns an array of indices of adjacent nodes with lower WEDF values to the input node
    # We only consider adjacent nodes with lower WEDF values as the children of given node
    # The output nodes are sorted based on their WEDF values from the highest to the lowest
    childNodes = {}
    currWEDF = bma.WEDFArray[nodeIdx]
    for i in range(len(bma.adjacencyMatrix[nodeIdx])):
        if bma.adjacencyMatrix[nodeIdx][i]:
            if bma.WEDFArray[i] <= currWEDF:
                childNodes[i] = bma.WEDFArray[i]
    childNodes = sorted(childNodes.items(), reverse = True, key = lambda x: x[1])
    return childNodes

def getEuclidean(nodeIdx1, nodeIdx2, bma1, bma2):
    EuclideanDistance = (bma1.erosionThickness[nodeIdx1] - bma2.erosionThickness[nodeIdx2]) ** 2 + (bma1.shapeTubularity[nodeIdx1] - bma2.shapeTubularity[nodeIdx2]) ** 2
    EuclideanDistance = math.sqrt(EuclideanDistance)
    return EuclideanDistance

def getED(nodeIdx1, nodeIdx2, bma1, bma2):
    # This function takes two nodes from two bma, and returns the editing distance between them and their child nodes
    ED = getEuclidean(nodeIdx1, nodeIdx2, bma1, bma2)
    childArray1 = getChild(nodeIdx1, bma1)
    childArray2 = getChild(nodeIdx2, bma2)

    if len(childArray1) == len(childArray2):
        if len(childArray1) == 0:
            # Both nodes have no child -- Base Case 1
            return ED
        else:
            # Both nodes have the same amount of child -- Recursive Case 1
            for i in range(len(childArray1)):
                ED += getED(childArray1[i][0], childArray2[i][0], bma1, bma2)
            return ED
    else:
        if (len(childArray1) == 0) or (len(childArray2) == 0):
            # One of the node has reach its end -- Base Case 2
            if len(childArray1) == 0:
                for i in childArray2:
                    ED += i[1]
            elif len(childArray2) == 0:
                for i in childArray1:
                    ED += i[1]
            return ED
        else:
            # Neither node has reach its end, yet having different number of child nodes -- Recursive Case 2
            if len(childArray1) > len(childArray2):
                numDel = len(childArray1) - len(childArray2)
                for i in range(numDel):
                    ED += childArray1[len(childArray2) + i][1]
                for i in range(len(childArray2)):
                    ED += getED(childArray1[i][0], childArray2[i][0], bma1, bma2)
            elif len(childArray2) > len(childArray1):
                numDel  = len(childArray2) - len(childArray1)
                for i in range(numDel):
                    ED += childArray2[len(childArray1) + i][1]
                for i in range(len(childArray1)):
                    ED += getED(childArray1[i][0], childArray2[i][0], bma1, bma2)
            return ED

def EditDistance(bma1, bma2):
    nodeIdx1 = getRoot(bma1)
    nodeIdx2 = getRoot(bma2)
    result = getED(nodeIdx1, nodeIdx2, bma1, bma2)
    return result
