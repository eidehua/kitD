# -*- coding=utf-8 -*-
import os
import imghdr
import cv2

class CatFaceCropper:

    def __init__(self):
        # Load the face cascade classifier
        self.catPath = "haarcascade_frontalcatface.xml"
        self.faceCascade = cv2.CascadeClassifier(self.catPath)

    def crop_image_dir(self, directory):
        # TODO: Implement this
        for root, dirs, files in os.walk(directory):
            print("=== Processing " + root + " ...")
            for f in files:
                filename = root + os.sep + f
                if imghdr.what(filename) is not None:
                    self.crop_image(filename)
        print("=== Processing complete! ===")

    def crop_image(self, filename):
        # Check if file is image
        if imghdr.what(filename) is None:
            return

        # Split the path, filename and extension
        (filename_head, filename_tail) = os.path.split(filename)
        (filename_raw, filename_extension) = os.path.splitext(filename_tail)

        # Read the image and convert to gray scale
        img = cv2.imread(filename)
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # Detect the cat faces
        faces = self.faceCascade.detectMultiScale(
            gray,
            scaleFactor=1.02,
            minNeighbors=3,
            minSize=(150, 150),
            flags=cv2.CASCADE_SCALE_IMAGE
        )

        # Make an output directory if not exits
        out_dir = filename_head + os.sep + "output"
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)

        # Process each cat face
        i = 0
        for (x, y, w, h) in faces:
            # Crop the cat face and save into a jpg file
            img_sub = cv2.getRectSubPix(img, (w, h), (x + w / 2, y + h / 2))
            cv2.imwrite(out_dir + os.sep + filename_raw + "-" + str(i) + filename_extension, img_sub)
            i += 1

        # Draw a rectangle over each cat face and label it
        i = 0
        for (x, y, w, h) in faces:
            cv2.rectangle(img, (x, y), (x + w, y + h), (0, 0, 255), 2)
            cv2.putText(img, str(i), (x, y - 7), 3, 1.2, (0, 255, 0), 2, cv2.LINE_AA)
            i += 1
        cv2.imwrite(out_dir + os.sep + filename_raw + "-results" + filename_extension, img)
