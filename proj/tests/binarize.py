import cv2

from utils import display_result


img_path = 'test.tif'
threshold = 90


# Load the image
img = cv2.imread(img_path)

# Convert to gray scale
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Binzarize
_, img_th = cv2.threshold(img_gray, threshold, 255, cv2.THRESH_BINARY)

# Convert the result to 8-bit (0-255) range
img_abs = cv2.convertScaleAbs(img_th)


display_result(img, img_abs)
