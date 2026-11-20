import cv2
import numpy as np
import matplotlib.pyplot as plt


def display_result(img, img_abs):
    # OpenCV
    cv2.imshow("Result", img_abs)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


    # Matplotlib

    plt.figure(figsize=(10, 5))

    plt.subplot(1, 2, 1)
    plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    plt.title('Original')
    plt.axis('off')

    plt.subplot(1, 2, 2)
    plt.imshow(img_abs, cmap='gray')
    plt.title('Result')
    plt.axis('off')

    plt.show()
