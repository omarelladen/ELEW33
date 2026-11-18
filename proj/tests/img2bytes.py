import cv2
import numpy as np


img_path = 'test.tif'


def img_gray_bytes(img_path):
    img = cv2.imread(img_path)
    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    height, length = img_gray.shape
    img_bytes = img_gray.tobytes()

    return img_bytes, height, length


img_bytes, height, length = img_gray_bytes(img_path)

for byte in img_bytes:
    print(byte, end=" ")
print()

print(type(img_bytes))
print(f"{height}x{length}={len(img_bytes)}")
