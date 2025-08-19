import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    height: 100
    color: configManager.cardBackground
    radius: 8
    border.color: isSelected ? accentColor : configManager.cardBorder
    border.width: isSelected ? 2 : 1
    
    property var timerItem
    property bool isSelected: false
    property color primaryColor: configManager.primary
    property color accentColor: configManager.accent
    property color successColor: configManager.success
    property color dangerColor: configManager.danger
    property color warningColor: configManager.warning
    
    signal deleteTimer()
    signal startTimer()
    signal stopTimer()
    signal resetTimer()
    signal adjustTime(int seconds)
    signal setCountdown(int seconds)
    signal toggleFavorite()
    signal selectTimer()
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 15
        
        // Timer Info Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            
            // Timer name and type
            RowLayout {
                spacing: 8
                
                Text {
                    text: timerItem ? timerItem.name : ""
                    font.pixelSize: 16
                    font.bold: true
                    color: primaryColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                Rectangle {
                    width: 70
                    height: 18
                    radius: 9
                    color: timerItem && timerItem.type === "countdown" ? successColor : accentColor
                    
                    Text {
                        anchors.centerIn: parent
                        text: timerItem && timerItem.type === "countdown" ? "Countdown" : "Stopwatch"
                        color: "white"
                        font.pixelSize: 8
                focus: false
                        font.bold: true
                    }
                }
                
                // Favorite star button
                Button {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    background: Rectangle {
                        radius: 12
                        color: "transparent"
                        border.color: timerItem && timerItem.isFavorite ? warningColor : "#bdc3c7"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: "★"
                        color: timerItem && timerItem.isFavorite ? warningColor : "#bdc3c7"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: toggleFavorite()
                    
                    ToolTip.visible: hovered
                    ToolTip.text: timerItem && timerItem.isFavorite ? "Remove from favorites" : "Add to favorites"
                }
            }
            
            // Display time
            Text {
                text: timerItem ? timerItem.displayTime : "00:00:00"
                font.pixelSize: 24
                font.bold: true
                color: timerItem && timerItem.isRunning ? successColor : primaryColor
                font.family: "monospace"
            }
        }
        
        // Control Buttons Section - All Horizontal
        RowLayout {
            spacing: 6
            
            // Start/Stop Button
            Button {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 30
                text: timerItem && timerItem.isRunning ? "Stop" : "Start"
                font.pixelSize: 10
                focus: false
                background: Rectangle {
                    color: {
                        if (!parent.enabled) return "#bdc3c7"
                        if (parent.pressed) return Qt.darker(timerItem && timerItem.isRunning ? dangerColor : successColor)
                        return timerItem && timerItem.isRunning ? dangerColor : successColor
                    }
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: parent.font.pixelSize
                    font.bold: true
                }
                onClicked: {
                    if (timerItem && timerItem.isRunning) {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }
            }
            
            // Reset Button
            Button {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 30
                text: "Reset"
                font.pixelSize: 10
                focus: false
                background: Rectangle {
                    color: parent.pressed ? Qt.darker(warningColor) : warningColor
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: parent.font.pixelSize
                    font.bold: true
                }
                onClicked: resetTimer()
            }
            
            // Time Adjustment Buttons
            Button {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                text: "-1m"
                font.pixelSize: 8
                focus: false
                background: Rectangle {
                    color: parent.pressed ? Qt.darker("#95a5a6") : "#95a5a6"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: parent.font.pixelSize
                }
                onClicked: adjustTime(-60)
            }
            
            Button {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                text: "-1h"
                font.pixelSize: 8
                focus: false
                background: Rectangle {
                    color: parent.pressed ? Qt.darker("#95a5a6") : "#95a5a6"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: parent.font.pixelSize
                }
                onClicked: adjustTime(-3600)
            }
            
            Button {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                text: "+1h"
                font.pixelSize: 8
                focus: false
                background: Rectangle {
                    color: parent.pressed ? Qt.darker("#95a5a6") : "#95a5a6"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: parent.font.pixelSize
                }
                onClicked: adjustTime(3600)
            }
            
            Button {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                text: "+1m"
                font.pixelSize: 8
                focus: false
                background: Rectangle {
                    color: parent.pressed ? Qt.darker("#95a5a6") : "#95a5a6"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: parent.font.pixelSize
                }
                onClicked: adjustTime(60)
            }
            
            // Delete Button
            Button {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 30
                text: "Delete"
                font.pixelSize: 9
                focus: false
                background: Rectangle {
                    color: parent.pressed ? Qt.darker(dangerColor) : dangerColor
                    radius: 4
                    opacity: 0.8
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: parent.font.pixelSize
                }
                onClicked: deleteTimer()
            }
        }
    }
    
    // Mouse area for timer selection (avoiding the drag handle area)
    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: 20  // Avoid the drag handle area
        z: -1  // Lower z-order so buttons can still be clicked
        onClicked: {
            selectTimer()
        }
    }
    
    // Subtle shadow effect
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1
        anchors.leftMargin: 1
        radius: parent.radius
        color: "#000000"
        opacity: 0.05
        z: parent.z - 1
    }
}