import numpy
import numpy.linalg as npl
import cmath;


# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
def myDET(c1, c2):
    z = numpy.array([[c1.real, c1.imag], [c2.real, c2.imag]])
    d = npl.det(z)
    print(d)
    return d



def tri_area(c1, c2, c3):
    print(abs(myDET(c3 - c1, c2 - c1))/2)
    return abs(myDET(c3 - c1, c2 - c1))/2
    # Use a breakpoint in the code line below to debug your script.


p1 = complex(1, 1)
p2 = complex(3, 2)
p3 = complex(5, 2)
p4 = complex(3, 4)
p5 = complex(1, 5)
p6 = complex(3, 6)
z = numpy.array([p1, p2, p3, p4, p5, p6])

myDET(p1, p2)
tri_area(p1, p2, p3)
