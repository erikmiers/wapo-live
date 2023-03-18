// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial


import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls
import QtQuick.Window 2.1
import QtQuick.Controls.Material 2.1

import wapoLive.WLVideo

ApplicationWindow {
    id              : mainWindow
    width           : 1600
    height          : 800
    visible         : true
    Material.theme  : Material.Dark
    Material.accent : Material.Red
 
    SplitView {
        anchors.fill          : parent
        orientation           : Qt.Vertical
        
        SplitView {
            SplitView.fillWidth   : true
            SplitView.fillHeight  : true

            orientation            : Qt.Horizontal

            Rectangle {
                id           : leftRect
                SplitView.preferredWidth : 400
                SplitView.fillHeight : true
                color : "steelblue"
            }

            ColumnLayout {
                SplitView.fillWidth : true
                SplitView.fillHeight: true
                TabBar {
                    id                     : tabbarVideoSource
                    Layout.preferredWidth  : parent.width - buttonToggle.width
                    Layout.preferredHeight : childrenRect.height
                    Repeater {
                        model : WLVideo.videoSources
                        TabButton {
                            text: qsTr(modelData)
                        } // repeated TabButton
                    } // Repeater
                                    Button {
                        anchors.right: tabbarVideoSource.right
                        anchors.top: tabbarVideoSource.top
                        id    : buttonToggle
                        text: "Toggle Video"
                        onClicked: WLVideo.toggleVideoSource(tabbarVideoSource.currentIndex, false)
                    }

                } // TabBar videoSource

                StackLayout {
                    id                : layoutVideoSource
                    currentIndex      : tabbarVideoSource.currentIndex
                    Layout.fillWidth  : true
                    Layout.fillHeight : true
                    Repeater {
                        model : WLVideo.videoSourceIds
                        Image {
                            fillMode          : Image.PreserveAspectFit
                            cache             : false
                            source            : imageSource
                            property string imageSource : "image://videos/" + modelData
                            Connections {
                                target: WLVideo
                                function onFrameReady() {
                                    // source = "image://videos/none"
                                    source = ""
                                    source = imageSource
                                }
                            }

                        } // repeated Image as stacked Item
                    } // Repeater
                } // StackLayout videoSource
            } // ColumnLayout videoSources

        } // SplitView


        // This is the footer ...
        Text {
            id: leftlabel
            Layout.alignment: Qt.AlignHCenter
            color: "white"
            font.pointSize: 16
            text: "Qt for Python"
            SplitView.preferredHeight: 100
            Material.accent: Material.Green
        } // Bottom Text


    } // SplitView / rootLayout


} // ApplicationWindow / mainWindow
