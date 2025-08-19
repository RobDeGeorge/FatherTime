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
        anchors.margins: 8
        anchors.topMargin: 1
        spacing: 6
        
        // Left Section: Timer Info and Favorite
        ColumnLayout {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.leftMargin: 6
            spacing: 1
            
            // Type badge (above title)
            Rectangle {
                Layout.alignment: Qt.AlignLeft
                width: 70
                height: 18
                radius: 5
                color: timerItem && timerItem.type === "countdown" ? successColor : accentColor
                
                Text {
                    anchors.centerIn: parent
                    text: timerItem && timerItem.type === "countdown" ? "Countdown" : "Stopwatch"
                    color: Qt.darker(parent.parent.background.color, 3.0)
                    font.pixelSize: 10
                    focus: false
                    font.bold: true
                }
            }
            
            // Timer name
            Text {
                text: timerItem ? timerItem.name : ""
                font.pixelSize: 28
                font.bold: true
                color: primaryColor
                elide: Text.ElideRight
            }
            
            // Second row: Timer display and favorite button
            RowLayout {
                spacing: 4
                
                // Display time
                Text {
                    text: timerItem ? timerItem.displayTime : "00:00:00"
                    font.pixelSize: 24
                    font.bold: true
                    color: timerItem && timerItem.isRunning ? successColor : primaryColor
                    font.family: "monospace"
                }
                
                // Favorite button (to the right of timer display, below badge level)
                Button {
                    Layout.alignment: Qt.AlignVCenter
                    width: 34
                    height: 34
                    focus: false
                    
                    background: Rectangle {
                        radius: 14
                        color: timerItem && timerItem.isFavorite ? warningColor : "transparent"
                        border.color: timerItem && timerItem.isFavorite ? warningColor : "#bdc3c7"
                        border.width: 2
                        opacity: parent.hovered ? 1.0 : (timerItem && timerItem.isFavorite ? 0.9 : 0.4)
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                    
                    contentItem: Text {
                        text: "★"
                        color: timerItem && timerItem.isFavorite ? Qt.darker(parent.parent.background.color, 3.0) : "#666666"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: toggleFavorite()
                    
                    ToolTip.visible: hovered
                    ToolTip.text: timerItem && timerItem.isFavorite ? "Remove from favorites" : "Add to favorites"
                    ToolTip.delay: 500
                }
            }
        }
        
        // Right Section: All control buttons (leaving space under delete button)
        RowLayout {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.topMargin: 12  // Leave space under delete button
            Layout.rightMargin: 38  // Add space from right edge
            spacing: 14
            
            // Start/Stop and Reset buttons
            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 14
                
                // Start/Stop Button
                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 48
                    text: timerItem && timerItem.isRunning ? "Stop" : "Start"
                    font.pixelSize: 14
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
                        color: Qt.darker(parent.parent.background.color, 3.0)
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
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 48
                    text: "Reset"
                    font.pixelSize: 14
                    focus: false
                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(warningColor) : warningColor
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: Qt.darker(parent.parent.background.color, 3.0)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: parent.font.pixelSize
                        font.bold: true
                    }
                    onClicked: resetTimer()
                }
            }
            
            // Time increment controls (increment button above +/- buttons)
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 8
                
                // Time increment toggle (above +/- buttons)
                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 30
                    property var increments: [60, 300, 1800, 3600] // 1m, 5m, 30m, 1h
                    property var incrementLabels: ["1m", "5m", "30m", "1h"]
                    property int currentIndex: 0
                    
                    text: incrementLabels[currentIndex]
                    font.pixelSize: 11
                    focus: false
                    
                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(accentColor) : accentColor
                        radius: 3
                        opacity: 0.8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: Qt.darker(parent.parent.background.color, 3.0)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: parent.font.pixelSize
                        font.bold: true
                    }
                    
                    onClicked: {
                        currentIndex = (currentIndex + 1) % increments.length
                    }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: "Click to cycle time increment"
                }
                
                // Plus/minus buttons
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 1
                    
                    // Minus Button
                    Button {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        text: "−"
                        font.pixelSize: 18
                        focus: false
                        
                        property Button incrementButton: parent.parent.children[0]
                        
                        background: Rectangle {
                            color: parent.pressed ? Qt.darker("#e74c3c") : "#e74c3c"
                            radius: 3
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: Qt.darker(parent.parent.background.color, 3.0)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: parent.font.pixelSize
                            font.bold: true
                        }
                        
                        onClicked: {
                            adjustTime(-incrementButton.increments[incrementButton.currentIndex])
                        }
                    }
                    
                    // Plus Button
                    Button {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        text: "+"
                        font.pixelSize: 18
                        focus: false
                        
                        property Button incrementButton: parent.parent.children[0]
                        
                        background: Rectangle {
                            color: parent.pressed ? Qt.darker("#27ae60") : "#27ae60"
                            radius: 3
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: Qt.darker(parent.parent.background.color, 3.0)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: parent.font.pixelSize
                            font.bold: true
                        }
                        
                        onClicked: {
                            adjustTime(incrementButton.increments[incrementButton.currentIndex])
                        }
                    }
                }
            }
        }
    }
    
    // Delete button in top-right corner
    Button {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 6
        width: 24
        height: 24
        focus: false
        
        background: Rectangle {
            radius: 12
            color: parent.pressed ? Qt.darker(dangerColor) : (parent.hovered ? dangerColor : Qt.rgba(dangerColor.r, dangerColor.g, dangerColor.b, 0.7))
            opacity: parent.hovered ? 1.0 : 0.6
            
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
        
        contentItem: Text {
            text: "×"
            color: Qt.darker(parent.background.color, 3.0)
            font.pixelSize: 18
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: deleteTimer()
        
        ToolTip.visible: hovered
        ToolTip.text: "Delete this timer"
        ToolTip.delay: 500
    }
    
    // Mouse area for timer selection (avoiding delete button and drag handle)
    MouseArea {
        anchors.fill: parent
        anchors.leftMargin: 20   // Avoid the drag handle area
        anchors.topMargin: 40    // Avoid the delete button
        anchors.rightMargin: 40  // Avoid the delete button
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