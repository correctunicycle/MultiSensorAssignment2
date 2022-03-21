import cv2 as cv
import numpy as np
import glob
import os


from functools import reduce

def factors(n):    
    return set(reduce(list.__add__, 
                ([i, n//i] for i in range(1, int(n**0.5) + 1) if n % i == 0)))



# A little script to read images of identical dimensions from a folder and 
# combine them into a grid of any desired dimension and then output that grid as an image.



#create list of all images in folder
images = []
filelist = os.listdir('/Users/ollie/Documents/msIP/MultiSensorAdjFigures/FirstImg/')
filelist.sort()

iterationNumber = [5,10,20,100]

for iteration in iterationNumber:
    img = cv.imread(f'/Users/ollie/Documents/msIP/MultiSensorAdjFigures/FirstImg/{iteration}iterations1e-05sf.png')
    images.append(img)
    
print(len(images))
print(factors(len(images)))
# iterations = images[9:]
# iterations10 = images[:9]
# iterations.append(iterations10)

# puts images into strips of desired width w
secondImgArr = []
imageWidth = 2
for x in range(0,len(images)+1-imageWidth,imageWidth):
    print('addingstrip')
    MiddleImage = np.concatenate(images[x:x+imageWidth],axis = 1)
    secondImgArr.append(MiddleImage)



#combine strips together and save output
FinalImage1 = np.concatenate(secondImgArr,axis = 0)



cv.imwrite('OutputImage.png',FinalImage1)



    