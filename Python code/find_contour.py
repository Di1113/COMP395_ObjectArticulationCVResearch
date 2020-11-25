import cv2
from numpy import *
from medialaxis import medialaxis

def find_contour(img, binary):
    #find contours
    contours, hierarchy = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2:]
    cv2.drawContours(img, contours, -1, (0, 255, 255), 1)
        #cv2.imshow("img", img)
        #cv2.waitKey(0)

    #find the contour with the most points, i.e. the biggest contour
    max_len = 0
    for i in range(len(contours)):
        if len(contours[i])>len(contours[max_len]):
            max_len = i
        #print(contours[89])

    coordinates = []
    for i in range(len(contours[max_len])):
        a = contours[max_len][i,0][0]
        b = contours[max_len][i,0][1]
        c = complex(a,b)
        coordinates.append(c)

    return coordinates


# input a picture
img = cv2.imread('2.jpg')

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
ret, binary = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)

coord = find_contour(img, binary)
medialdata = medialaxis(coord)



