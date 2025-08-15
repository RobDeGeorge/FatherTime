import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    
    // === PROPER RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.85, 600)
    height: Math.min(parent.height * 0.85, 500)
    
    anchors.centerIn: parent
    modal: true
    
    // Public alias for external access
    property alias confirmationSlider: confirmSlider
    
    onOpened: {
        confirmSlider.value = 0
        forceActiveFocus()
    }
    
    // === ANIMATIONS ===
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 250 }
    }
    
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 200 }
    }
    
    // === DANGER BACKGROUND ===
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.dangerColor
        border.width: 3
        radius: 12
        
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.leftMargin: 4
            color: "#40FF0000"
            radius: parent.radius
            z: parent.z - 1
        }
    }
    
    // === DANGER HEADER ===
    header: Rectangle {
        height: 70
        color: window.dangerColor
        radius: 12
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            
            Rectangle {
                width: 40
                height: 40
                color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.15)
                radius: 10
                
                Text {
                    anchors.centerIn: parent
                    text: "⚠️"
                    font.pixelSize: 22
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                
                Text {
                    text: "⚠️ DANGER: Reset All Data"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.backgroundColor
                }
                
                Text {
                    text: "This action cannot be undone"
                    font.pixelSize: 12
                    color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.9)
                    font.weight: Font.Medium
                }
            }
        }
    }
    
    // === KEY HANDLER ===
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        focus: true
        
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                confirmSlider.value = 0
                root.close()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (confirmSlider.value >= 95) {
                    timerManager.resetAllData()
                    confirmSlider.value = 0
                    root.close()
                }
                event.accepted = true
            }
        }
    }

    // === MAIN CONTENT ===
    Item {
        anchors.fill: parent
        
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 20
            anchors.bottomMargin: 80  // Leave room for buttons
            spacing: 16
            
            Text {
                text: "⚠️ DANGER: Complete Data Reset"
                font.pixelSize: 18
                font.bold: true
                color: window.dangerColor
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            
            // === CONSEQUENCES SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                color: Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.08)
                radius: 10
                border.color: Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.3)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Text {
                        text: "This will permanently delete:"
                        font.pixelSize: 14
                        font.bold: true
                        color: window.textColor
                        Layout.fillWidth: true
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "🗑️ All timer definitions and configurations"
                            font.pixelSize: 12
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "📊 All work sessions and time tracking history"
                            font.pixelSize: 12
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "📈 All daily statistics and breakdowns"
                            font.pixelSize: 12
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "📅 All date-specific timer states"
                            font.pixelSize: 12
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.15)
                        radius: 6
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⚠️ This action cannot be undone!"
                            font.pixelSize: 12
                            font.bold: true
                            color: window.dangerColor
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
            
            // === CONFIRMATION SLIDER SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: Qt.rgba(window.warningColor.r, window.warningColor.g, window.warningColor.b, 0.08)
                radius: 10
                border.color: Qt.rgba(window.warningColor.r, window.warningColor.g, window.warningColor.b, 0.3)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    Text {
                        text: "Slide all the way to the right to confirm deletion:"
                        font.pixelSize: 13
                        font.bold: true
                        color: window.textColor
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "SAFE"
                            font.pixelSize: 11
                            font.bold: true
                            color: window.successColor
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        Slider {
                            id: confirmSlider
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            from: 0
                            to: 100
                            value: 0
                            
                            background: Rectangle {
                                x: confirmSlider.leftPadding
                                y: confirmSlider.topPadding + confirmSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 8
                                width: confirmSlider.availableWidth
                                height: implicitHeight
                                radius: height / 2
                                color: "#e8e8e8"
                                
                                Rectangle {
                                    width: confirmSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: confirmSlider.value < 95 ? window.warningColor : window.dangerColor
                                    radius: height / 2
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                            }
                            
                            handle: Rectangle {
                                x: confirmSlider.leftPadding + confirmSlider.visualPosition * (confirmSlider.availableWidth - width)
                                y: confirmSlider.topPadding + confirmSlider.availableHeight / 2 - height / 2
                                implicitWidth: 32
                                implicitHeight: 32
                                radius: width / 2
                                color: confirmSlider.pressed ? Qt.darker(confirmSlider.value < 95 ? window.warningColor : window.dangerColor, 1.2) : 
                                       (confirmSlider.value < 95 ? window.warningColor : window.dangerColor)
                                border.color: "#ffffff"
                                border.width: 2
                                
                                SequentialAnimation on scale {
                                    running: confirmSlider.value >= 95
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.1; duration: 500 }
                                    NumberAnimation { to: 1.0; duration: 500 }
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }
                        }
                        
                        Text {
                            text: "DELETE"
                            font.pixelSize: 11
                            font.bold: true
                            color: window.dangerColor
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
        
        // === BUTTONS AT BOTTOM ===
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 80
            color: "transparent"
            
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.3)
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12
                
                Item {
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "Cancel"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    
                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(window.cardBorderColor, 1.1) : 
                               parent.hovered ? Qt.lighter(window.cardBorderColor, 1.1) : window.cardBorderColor
                        radius: 6
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: window.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    
                    onClicked: {
                        confirmSlider.value = 0
                        root.close()
                    }
                }
                
                Button {
                    text: confirmSlider.value >= 95 ? "CONFIRM RESET" : "Slide to confirm →"
                    enabled: confirmSlider.value >= 95
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 36
                    
                    background: Rectangle {
                        color: {
                            if (!parent.enabled) return Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.5)
                            if (parent.pressed) return Qt.darker(window.dangerColor, 1.1)
                            if (parent.hovered) return Qt.lighter(window.dangerColor, 1.1)
                            return confirmSlider.value >= 95 ? window.dangerColor : Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.3)
                        }
                        radius: 6
                        
                        SequentialAnimation on opacity {
                            running: parent.enabled
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.8; duration: 800 }
                            NumberAnimation { to: 1.0; duration: 800 }
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : Qt.rgba(1, 1, 1, 0.5)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        wrapMode: Text.WordWrap
                    }
                    
                    onClicked: {
                        timerManager.resetAllData()
                        confirmSlider.value = 0
                        root.close()
                    }
                }
            }
        }
    }
}