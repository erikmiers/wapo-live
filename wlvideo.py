from PySide6.QtCore import QObject, Property, Signal, Slot
from PySide6.QtCore import QTimer
from PySide6.QtGui import QImage, QPixmap

import cv2
import os

class WLVideo(QObject):
    """
    Provide all the video and OCR related functionality
    """
    _deviceList = []
    _deviceIds = []
    _captureDevices = []
    _imageProvider = None
    _areasOfInterest = [ {
        "name": "defaultName",
        "device" : 0,
        # coordinates (point, width, height) / (point, point)
        # settings (skew, threshold, ... )


    },{ "name": "defaultName2",
        "device" : 4,
    }]

    def getVideoSources(self) -> list:
        return self._deviceList

    def getVideoSourceIds(self) -> list:
        return self._deviceIds

    def getAreasOfInterest(self) -> list:
        return self._areasOfInterest
    
    videoSources = Property(list, fget=getVideoSources)
    videoSourceIds = Property(list, fget=getVideoSourceIds)
    areasOfInterest = Property(list, fget=getAreasOfInterest)

    def setImageProvider(self, imageProvider):
        self._imageProvider  = imageProvider

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self.initVideoSources()
        # TODO: read some initial settings 
        self.timer = QTimer(self)
        self.timer.setInterval(231)
        self.timer.timeout.connect(self.processFrame)
        self.timer.start()

    def __exit__(self, exc_type, exc_value, traceback):
        for videoCapture in self._captureDevices:
            if videoCapture: videoCapture.release()

    @Slot(int, bool)
    def toggleVideoSource(self, index, activate):
        # index = self._deviceIds(videoSourceId)
        videoCapture = self._captureDevices[index]
        if videoCapture:
            if videoCapture.isOpened():
                if activate: return
                videoCapture.release()
            else:
                if not activate: return
                videoCapture.open(self._deviceIds[index])
        else:
            if not activate: return
            videoCapture = cv2.VideoCapture(self._deviceIds[index])

    frameReady = Signal()


    def processFrame(self):
        for index, videoCapture in enumerate(self._captureDevices):
            if not videoCapture or not videoCapture.isOpened(): continue

            success, img = videoCapture.read()
            height, width, bPC = img.shape
            image =  QImage(img.data, width, height, bPC * width, QImage.Format_RGB888).rgbSwapped()
            pixmap = QPixmap.fromImage(image)
            self._imageProvider.setPixmap(self._deviceIds[index], pixmap)
        self.frameReady.emit()




    def initVideoSources(self):
        done = False
        currentDeviceNr = 0
        lastDeviceNr = 0
        while not done:
            try:
                videoCapture = cv2.VideoCapture(currentDeviceNr)
            except:
                pass

            if videoCapture and videoCapture.isOpened():
                self._deviceList.append("Device " + str(currentDeviceNr))
                self._deviceIds.append(currentDeviceNr)
                self._captureDevices.append(videoCapture)
                lastDeviceNr = currentDeviceNr
            currentDeviceNr += 1
            if currentDeviceNr - lastDeviceNr > 5:
                done = True


