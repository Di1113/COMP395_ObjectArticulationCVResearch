import cv2
from numpy import *

# input a picture
img = cv2.imread('2.jpg')

#灰化  貌似效果不好  我直接拿了原来的黑白图像
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
ret, binary = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)

def find_contour(img):
    #find contours
    contours, hierarchy = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cv2.drawContours(img, contours, -1, (0, 255, 255), 1)
        #cv2.imshow("img", img)
        #cv2.waitKey(0)

    #找出contour中含最多点的contour，即最大的一个contour
    max_len = 0
    for i in range(len(contours)):
        if len(contours[i])>len(contours[max_len]):
            max_len = i
        #print(contours[89])

    #把坐标放进list
    coordinates = []
    for i in range(len(contours[max_len])):
        a = contours[max_len][i,0][0]
        b = contours[max_len][i,0][1]
        c = complex(a,b)
        coordinates.append(c)

    return coordinates





