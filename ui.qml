// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial


import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Controls
import QtQuick.Window 2.1
import QtQuick.Controls.Material 2.1

import wapoLive.WLVideo

import "."

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
            ColumnLayout {
                id                       : layoutLeftSidebar
                SplitView.preferredWidth : 400
                SplitView.fillHeight     : true
                RowLayout {
                    Layout.fillWidth       : true
                    Layout.preferredHeight : childrenRect.height
                    spacing                : 10

                    Rectangle {
                        Layout.fillWidth: true
                    }

                    Button {
                        id: buttonOne
                        icon.source : Res.iconDelete
                    }
                    Button {
                        id: buttonAdd
                        icon.source : Res.iconAdd
                    }
                } // RowLayout Buttonbar

                ScrollView {
                    Layout.fillWidth : true
                    Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill:parent
                        id: layoutAoi

                        function toggleExpansion(item, expanded) {
                            item.expanded = !expanded
                        }

                        Repeater {
                            model : WLVideo.areasOfInterest
                            Rectangle {
                                clip: true
                                color : "lightgrey"
                                id                           : rectContainer
                                Layout.fillWidth             : true
                                Layout.preferredHeight       : containerHeight
                                property bool expanded       : true
                                property int containerHeight : expanded ? 
                                    childrenRect.height : rectHeader.height

                                Behavior on containerHeight {
                                    NumberAnimation { duration : 230 }
                                }
                                
                                Rectangle {
                                    color : rectContainer.expanded ? "pink" : "red"
                                    id            : rectHeader
                                    anchors.left  : parent.left
                                    anchors.right : parent.right
                                    height        : 48
                                    MouseArea {
                                        anchors.fill : parent
                                        onClicked    : layoutAoi.toggleExpansion(rectContainer, rectContainer.expanded)
                                    }

                                    Label {
                                        text: "Device " + modelData.device + "\\" + modelData.name
                                    }
                                }
                                Rectangle {
                                    color : "blue"
                                    id            : rectContent
                                    anchors.top   : rectHeader.bottom
                                    anchors.left  : parent.left
                                    anchors.right : parent.right
                                    height        : 400 // childrenRect.height

                                }

                            } // Rectangle container item


                        } // Repeater AoI items
                    } // ColumnLayout
                } // ScrollView
            }

            ColumnLayout {
                SplitView.fillWidth : true
                SplitView.fillHeight: true
                TabBar {
                    id                     : tabbarVideoSource
                    Layout.preferredWidth  : childrenRect.width
                    Layout.preferredHeight : childrenRect.height
                    Repeater {
                        model : WLVideo.videoSources
                        TabButton {
                            text   : qsTr(modelData)
                            width  : implicitWidth * 3

                            RoundButton {
                                anchors.rightMargin : 10
                                anchors.right       : parent.right
                                Material.background : Material.Red
                                text                : "X"
                                onClicked           : {
                                    if ( text === "X" ) {
                                        text = "O"
                                        Material.background = Material.Green
                                        WLVideo.toggleVideoSource(index, false)
                                    } else {
                                        text = "X"
                                        Material.background = Material.Red
                                        WLVideo.toggleVideoSource(index, true)
                                    }
                                }
                            }

                        } // repeated TabButton
                    } // Repeater

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
            text: "Area for additional information"
            SplitView.preferredHeight: 100
            Material.accent: Material.Green
        } // Bottom Text


    } // SplitView / rootLayout


} // ApplicationWindow / mainWindow
