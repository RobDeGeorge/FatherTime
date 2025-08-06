import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    height: 100
    color: configManager.cardBackground
    radius: 8
    border.color: configManager.cardBorder
    border.width: 1
    
    property var timerItem
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
            }
            
            // Display time and status
            RowLayout {
                spacing: 10
                
                Text {
                    text: timerItem ? timerItem.displayTime : "00:00:00"
                    font.pixelSize: 24
                    font.bold: true
                    color: timerItem && timerItem.isRunning ? successColor : primaryColor
                    font.family: "monospace"
                }
                
                Text {
                    text: timerItem && timerItem.isRunning ? "Running..." : "Stopped"
                    font.pixelSize: 10
                focus: false
                    color: timerItem && timerItem.isRunning ? successColor : "#7f8c8d"
                    opacity: 0.8
                    Layout.fillWidth: true
                }
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
                Layout.preferredWidth: 25
                Layout.preferredHeight: 30
                text: "-1s"
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
                onClicked: adjustTime(-1)
            }
            
            Button {
                Layout.preferredWidth: 25
                Layout.preferredHeight: 30
                text: "+1s"
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
                onClicked: adjustTime(1)
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