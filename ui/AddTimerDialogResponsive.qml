import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    
    // === PROPER RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.9, 600)
    height: Math.min(parent.height * 0.7, 320)
    
    anchors.centerIn: parent
    modal: true
    
    // Alias for external access
    property alias timerNameField: timerNameField
    
    // === ANIMATIONS ===
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200 }
    }
    
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 150 }
    }
    
    // === BACKGROUND ===
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.primaryColor
        border.width: 2
        radius: 12
        
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            color: "#20000000"
            radius: parent.radius
            z: parent.z - 1
        }
    }
    
    // === HEADER ===
    header: Rectangle {
        height: 70
        color: window.primaryColor
        radius: 12
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Rectangle {
                width: 36
                height: 36
                color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.15)
                radius: 10
                
                Text {
                    anchors.centerIn: parent
                    text: "⏱️"
                    font.pixelSize: 20
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Add Stopwatch Timer"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.backgroundColor
                }
                
                Text {
                    text: "Create a new timer to track elapsed time"
                    font.pixelSize: 12
                    color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.8)
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
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
                root.close()
                timerNameField.text = ""
                window.restoreFocus()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                var timerName = timerNameField.text.trim() || "Timer"
                timerManager.addTimer(timerName, "stopwatch")
                root.close()
                timerNameField.text = ""
                window.restoreFocus()
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
            anchors.bottomMargin: 60  // Leave room for buttons
            spacing: 16
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.3)
            }
            
            // === TIMER NAME SECTION ===
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "Timer Name"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: window.textColor
                    Layout.fillWidth: true
                }
                
                TextField {
                    id: timerNameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    
                    placeholderText: "Enter timer name..."
                    font.pixelSize: 16
                    selectByMouse: true
                    color: window.textColor
                    
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            var timerName = text.trim() || "Timer"
                            timerManager.addTimer(timerName, "stopwatch")
                            root.close()
                            text = ""
                            window.restoreFocus()
                            event.accepted = true
                        }
                    }
                    
                    background: Rectangle {
                        color: window.cardBackgroundColor
                        border.color: parent.activeFocus ? window.accentColor : window.cardBorderColor
                        border.width: parent.activeFocus ? 2 : 1
                        radius: 8
                        
                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Behavior on border.width {
                            NumberAnimation { duration: 150 }
                        }
                    }
                    
                    Component.onCompleted: forceActiveFocus()
                }
            }
            
            Text {
                text: "💡 Choose a descriptive name to easily identify this timer"
                font.pixelSize: 11
                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
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
            height: 60
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
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 40
                    
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
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    
                    onClicked: {
                        root.close()
                        timerNameField.text = ""
                        window.restoreFocus()
                    }
                }
                
                Button {
                    text: "Create"
                    enabled: timerNameField.text.trim() !== ""
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 40
                    
                    background: Rectangle {
                        color: {
                            if (!parent.enabled) return Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.5)
                            if (parent.pressed) return Qt.darker(window.primaryColor, 1.1)
                            if (parent.hovered) return Qt.lighter(window.primaryColor, 1.1)
                            return window.primaryColor
                        }
                        radius: 6
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : Qt.rgba(1, 1, 1, 0.5)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    
                    onClicked: {
                        timerManager.addTimer(timerNameField.text.trim(), "stopwatch")
                        root.close()
                        timerNameField.text = ""
                        window.restoreFocus()
                    }
                }
            }
        }
    }
    
    function openDialog() {
        open()
        timerNameField.forceActiveFocus()
        timerNameField.selectAll()
    }
    
    function resetFields() {
        timerNameField.text = ""
    }
    
    onOpened: {
        Qt.callLater(function() {
            timerNameField.forceActiveFocus()
        })
    }
    
    onClosed: {
        resetFields()
    }
}