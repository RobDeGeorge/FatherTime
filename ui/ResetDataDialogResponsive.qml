import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    
    // === PROPER RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.9, 550)
    height: Math.min(parent.height * 0.9, 580)
    
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
        height: Math.max(80, Math.min(parent.height * 0.15, 100))
        color: window.dangerColor
        radius: Math.max(8, Math.min(root.width * 0.025, 15))
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Math.max(16, Math.min(root.width * 0.04, 24))
            spacing: Math.max(8, Math.min(root.width * 0.025, 16))
            
            Rectangle {
                Layout.preferredWidth: Math.max(32, Math.min(root.width * 0.08, 45))
                Layout.preferredHeight: Layout.preferredWidth
                color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.15)
                radius: Layout.preferredWidth * 0.25
                
                Text {
                    anchors.centerIn: parent
                    text: "⚠️"
                    font.pixelSize: Math.max(16, Math.min(parent.width * 0.55, 26))
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Math.max(2, Math.min(root.height * 0.008, 6))
                
                Text {
                    text: "⚠️ DANGER: Reset All Data"
                    font.pixelSize: Math.max(14, Math.min(root.width * 0.04, 20))
                    font.weight: Font.Bold
                    color: window.backgroundColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                
                Text {
                    text: "This action cannot be undone"
                    font.pixelSize: Math.max(10, Math.min(root.width * 0.025, 14))
                    color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.9)
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    elide: Text.ElideRight
                    maximumLineCount: 2
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
            anchors.leftMargin: Math.max(16, Math.min(root.width * 0.04, 24))
            anchors.rightMargin: Math.max(16, Math.min(root.width * 0.04, 24))
            anchors.topMargin: Math.max(16, Math.min(root.height * 0.035, 24))
            anchors.bottomMargin: Math.max(70, Math.min(root.height * 0.15, 90))  // Leave room for buttons
            spacing: Math.max(12, Math.min(root.height * 0.025, 20))
            
            Text {
                text: "⚠️ DANGER: Complete Data Reset"
                font.pixelSize: Math.max(14, Math.min(root.width * 0.04, 20))
                font.weight: Font.Bold
                color: window.dangerColor
                Layout.fillWidth: true
                Layout.maximumWidth: root.width - 40
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
            }
            
            // === CONSEQUENCES SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(140, Math.min(root.height * 0.35, 180))
                color: Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.08)
                radius: Math.max(6, Math.min(root.width * 0.02, 12))
                border.color: Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.3)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Math.max(12, Math.min(root.width * 0.035, 20))
                    spacing: Math.max(8, Math.min(root.height * 0.02, 14))
                    
                    Text {
                        text: "This will permanently delete:"
                        font.pixelSize: Math.max(12, Math.min(root.width * 0.032, 16))
                        font.weight: Font.Bold
                        color: window.textColor
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Math.max(6, Math.min(root.height * 0.012, 10))
                        
                        Text {
                            text: "🗑️ All timer definitions and configurations"
                            font.pixelSize: Math.max(10, Math.min(root.width * 0.025, 14))
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width
                            maximumLineCount: 2
                        }
                        Text {
                            text: "📊 All work sessions and time tracking history"
                            font.pixelSize: Math.max(10, Math.min(root.width * 0.025, 14))
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width
                            maximumLineCount: 2
                        }
                        Text {
                            text: "📈 All daily statistics and breakdowns"
                            font.pixelSize: Math.max(10, Math.min(root.width * 0.025, 14))
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width
                            maximumLineCount: 2
                        }
                        Text {
                            text: "📅 All date-specific timer states"
                            font.pixelSize: Math.max(10, Math.min(root.width * 0.025, 14))
                            color: window.textColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            Layout.maximumWidth: parent.width
                            maximumLineCount: 2
                        }
                    }
                }
            }
            
            // === CONFIRMATION SLIDER SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(100, Math.min(root.height * 0.25, 130))
                color: Qt.rgba(window.warningColor.r, window.warningColor.g, window.warningColor.b, 0.08)
                radius: Math.max(6, Math.min(root.width * 0.02, 12))
                border.color: Qt.rgba(window.warningColor.r, window.warningColor.g, window.warningColor.b, 0.3)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Math.max(12, Math.min(root.width * 0.035, 20))
                    spacing: Math.max(12, Math.min(root.height * 0.025, 18))
                    
                    Text {
                        text: "Slide all the way to the right to confirm deletion:"
                        font.pixelSize: Math.max(11, Math.min(root.width * 0.028, 14))
                        font.weight: Font.Bold
                        color: window.textColor
                        Layout.fillWidth: true
                        Layout.maximumWidth: root.width - 40
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Math.max(8, Math.min(root.width * 0.025, 16))
                        
                        Text {
                            text: "SAFE"
                            font.pixelSize: Math.max(9, Math.min(root.width * 0.022, 12))
                            font.weight: Font.Bold
                            color: window.successColor
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        Slider {
                            id: confirmSlider
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(28, Math.min(root.height * 0.055, 36))
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
                                implicitWidth: Math.max(24, Math.min(root.width * 0.06, 36))
                                implicitHeight: implicitWidth
                                radius: width / 2
                                color: confirmSlider.pressed ? Qt.darker(confirmSlider.value < 95 ? window.warningColor : window.dangerColor, 1.2) : 
                                       (confirmSlider.value < 95 ? window.warningColor : window.dangerColor)
                                border.color: "#ffffff"
                                border.width: Math.max(1, Math.min(root.width * 0.005, 3))
                                
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
                            font.pixelSize: Math.max(9, Math.min(root.width * 0.022, 12))
                            font.weight: Font.Bold
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
            height: Math.max(70, Math.min(root.height * 0.15, 90))
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
                anchors.margins: Math.max(16, Math.min(root.width * 0.04, 24))
                spacing: Math.max(8, Math.min(root.width * 0.025, 16))
                
                Item {
                    Layout.fillWidth: true
                }
                
                Button {
                    text: "Cancel"
                    Layout.preferredWidth: Math.max(90, Math.min(root.width * 0.2, 130))
                    Layout.preferredHeight: Math.max(36, Math.min(root.height * 0.06, 40))
                    
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
                        font.pixelSize: Math.max(11, Math.min(root.width * 0.028, 14))
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    
                    onClicked: {
                        confirmSlider.value = 0
                        root.close()
                    }
                }
                
                Button {
                    text: confirmSlider.value >= 95 ? "CONFIRM RESET" : "Slide to confirm →"
                    enabled: confirmSlider.value >= 95
                    Layout.preferredWidth: Math.max(140, Math.min(root.width * 0.3, 180))
                    Layout.preferredHeight: Math.max(36, Math.min(root.height * 0.06, 40))
                    
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
                        font.pixelSize: Math.max(11, Math.min(root.width * 0.028, 14))
                        font.weight: Font.Bold
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
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