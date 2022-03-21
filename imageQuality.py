# given x,y are circle center and r is radius
import cv2 as cv
import numpy as np
import os
import matplotlib.pyplot as plt
from PIL import Image, ImageDraw
#img = cv.imread('MultiSensorAdjFigures/1iterations0.1sf.png', 1)
def cropImage(filename):  
    print(f'MultiSensorOppFigures/{filename}')
    img=Image.open(f'MultiSensorOppFigures/{filename}')
    #img.show()

    height,width = img.size
    lum_img = Image.new('L', [height,width] , 0)

    xcentre = 405
    ycentre = 316 
    radius = 265


    draw = ImageDraw.Draw(lum_img)
    drawnImg = draw.pieslice([(xcentre-radius,ycentre-radius),(xcentre+radius,ycentre+radius) ], 0, 360, 
                fill = 255, outline = "white")
    #lum_img.show()
    img_arr =np.array(img)
    lum_img_arr =np.array(lum_img)
    #display(Image.fromarray(lum_img_arr))

    final_img_arr = np.dstack((img_arr,lum_img_arr))
    outputImg = Image.fromarray(final_img_arr)
    
    outputImg.save(f'OppCroppedImg/Cropped{filename}')


if __name__=="__main__":
    filelist = os.listdir('MultiSensorOppFigures')
    filelist.sort()

    # for filename in filelist:
    #     if(filename == '.DS_Store'):
    #         continue
    #     cropImage(filename)
    filelist = os.listdir('AdjcroppedImg')
    filelist.sort()
    # Grayimg = cv.imread(f'greyImg/Cropped9iterations1e-05sf.jpeg',0)
    # hist = cv.calcHist([Grayimg],[0],None,[256],[0,256])
    # plt.plot(hist[:250],color='k')
    # plt.show()
    # cv.imshow('greyscale',grayImg)


    # for filename in filelist:
    #     if(filename == '.DS_Store'):
    #             continue
    #     Grayimg = cv.imread(f'AdjcroppedImg/{filename}',0)
        
    #     cv.imwrite(f'greyImg/{filename}',Grayimg)
    SFlist = ['1','0.1','0.01','0.001','0.0001','1e-05','1e-06','1e-07','1e-08']
    SingleSFlist = ['1e-05']
    listOfOutput = []
    for iteration in range(20):
        iteration += 1
        for sf in SFlist:
            Grayimg = cv.imread(f'greyImg/Cropped{iteration}iterations{sf}sf.jpeg',0)
            hist = cv.calcHist([Grayimg],[0],None,[256],[0,256])
            # plt.plot(hist[:250],color='k')
            # plt.show()
            #cv.imshow('greyscale',grayImg)
            histwoBack = hist[:250]
            top5Bins = []
            numberOfPixels = 0 
            numberofBins  = 3
            for bin in histwoBack:
                numberOfPixels += bin[0]
                if len(top5Bins)<numberofBins:
                    top5Bins.append(bin)
                else:
                    for topBin in range(numberofBins):
                        if bin > top5Bins[topBin]:
                            top5Bins[topBin] = bin[0]
                            break

            top5binTotal = 0                
            for topbin in top5Bins:
                top5binTotal +=topbin
            #top5binTotal -= max(top5Bins)
            #print(f'Max bin was equal to {max(top5Bins)} ')
            # print(top5binTotal)
            # print(numberOfPixels)
            print(f'Iteration: {iteration}, sf {sf} \n Ratio of top bins to total number of pixels is: {top5binTotal/numberOfPixels}')
            listOfOutput.append(top5binTotal/numberOfPixels)

    exportArray = np.array(listOfOutput)
    
    

    
    plt.plot(exportArray)
    plt.show()
    