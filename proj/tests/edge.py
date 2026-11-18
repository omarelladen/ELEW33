"""
Laplacian():

When ksize > 1, the function calculates the Laplacian of the source image by
adding up the second x and y derivatives calculated using the Sobel operator.

When ksize == 1, the Laplacian is computed by filtering the image with the
following 3×3 aperture:

0  1  0
1 -4  1
0  1  0

https://docs.opencv.org/3.4.20/d4/d86/group__imgproc__filter.html#gad78703e4c8fe703d479c1860d76429e6
"""

import cv2
import numpy as np

from utils import display_result


img_path = 'test.tif'

conv_kernel = np.array([[0,  1, 0],
                        [1, -4, 1],
                        [0,  1, 0]])

ddepth = cv2.CV_32F


# Load the image
img = cv2.imread(img_path)

print("img.shape:", img.shape, end="\n\n")
print("img.dtype:", img.dtype, end="\n\n")
print("img[0][0]:", img[0][0], end="\n\n")
print("img[0]:", img[0], end="\n\n")
print(f"img[{img.shape[0]-1}]:", img[img.shape[0]-1], end="\n\n")
print("img:", img, end="\n\n")

# Convert to gray scale
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
print("img_gray:", img_gray, end="\n\n")

# Convolution
img_conv = cv2.filter2D(img_gray, ddepth, conv_kernel)
# img_conv = cv2.Laplacian(img, ddepth, ksize=1)


# Convert the result to 8-bit (0-255) range
img_abs = cv2.convertScaleAbs(img_conv)
print("img_abs:", img_abs, end="\n\n")


display_result(img, img_abs)
