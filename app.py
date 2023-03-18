import sys
from pathlib import Path

from PySide6.QtCore import QObject,Signal, Slot, QSize, Qt
from PySide6.QtGui import QGuiApplication, QPixmap, QColor
from PySide6.QtQuick import QQuickImageProvider
# from PySide6.QtWidgets import
from PySide6.QtQml import QQmlApplicationEngine, QmlElement, qmlRegisterSingletonInstance
from PySide6.QtQuickControls2 import QQuickStyle

import wlvideo

QML_IMPORT_NAME = "wapoLive.web"
QML_IMPORT_MAJOR_VERSION = 1
@QmlElement
class WLWeb(QObject):
    """
    Provide all the web related functionality
    """
    pass


QML_IMPORT_NAME = "wapoLive.scraper"
QML_IMPORT_MAJOR_VERSION = 1
@QmlElement
class WLScraper(QObject):
    """
    Provide all the web-scraping related functionality
    """
    pass


class videoSourceImageProvider(QQuickImageProvider):
    def __init__(self) -> None:
        super().__init__(QQuickImageProvider.Pixmap)

    pixmaps = {}
    def setPixmap(self, id, pixmap):
        self.pixmaps[id] = pixmap
        
    def requestPixmap(self, id: str, size: QSize, requestedSize: QSize) -> QPixmap:
        width, height = 1000, 500
        if size:
            size = QSize(width, height)
        if int(id) not in self.pixmaps:
            pixmap = QPixmap(
                requestedSize.width() if requestedSize.width() > 0 else width,
                requestedSize.height() if requestedSize.height() > 0 else height,
            )
            pixmap.fill(QColor("grey").rgba())
            return pixmap
        return self.pixmaps[int(id)].scaled(width, height, Qt.KeepAspectRatio, Qt.SmoothTransformation)





@Slot()
def onQuit():
    print("App is about to quit, cleaning up ... ")
    # TODO :do cleanup here



if __name__ == "__main__":
    """
    Qt stuff for running a Qml based application
    """
    app = QGuiApplication(sys.argv)
    app.aboutToQuit.connect(onQuit)
    QQuickStyle.setStyle("Material")
    engine = QQmlApplicationEngine()


    imageProvider = videoSourceImageProvider()
    wlVideoInstance = wlvideo.WLVideo()
    wlVideoInstance.setImageProvider(imageProvider)
    # TODO:: connect image provider and video class
    qmlRegisterSingletonInstance(wlvideo.WLVideo, "wapoLive.WLVideo", 1, 0, "WLVideo", wlVideoInstance)
    engine.addImageProvider("videos", imageProvider)

    qml_file = Path(__file__).parent / 'ui.qml'
    engine.load(qml_file)


    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())