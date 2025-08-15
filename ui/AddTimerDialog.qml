import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    anchors.centerIn: parent
    width: window.width * 0.75
    height: window.height * 0.6
    modal: true
    
    property alias timerNameField: timerNameField
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            cancelButton.clicked()
        }
    }
    
    Shortcut {
        sequence: "Return"
        onActivated: {
            if (timerNameField.text.trim() !== "") {
                timerManager.addTimer(timerNameField.text.trim(), "stopwatch")
                root.close()
                timerNameField.text = ""
            }
        }
    }
    
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.primaryColor
        border.width: 2
        radius: 12
    }
    
    header: Rectangle {
        height: Math.max(window.height * 0.08, 50)
        color: window.primaryColor
        radius: 12
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Math.max(window.width * 0.02, 15)
            spacing: 15
            
            Rectangle {
                width: Math.max(window.width * 0.04, 32)
                height: Math.max(window.width * 0.04, 32)
                color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.15)
                radius: 10
                
                Text {
                    anchors.centerIn: parent
                    text: "⏱️"
                    font.pixelSize: Math.max(window.width * 0.022, 16)
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Add Stopwatch Timer"
                    font.pixelSize: Math.max(window.width * 0.022, 16)
                    font.bold: true
                    color: window.backgroundColor
                }
                
                Text {
                    text: "Create a new timer to track elapsed time"
                    font.pixelSize: Math.max(window.width * 0.014, 12)
                    color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.8)
                }
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Math.max(window.width * 0.025, 20)
        spacing: Math.max(window.height * 0.025, 20)
        
        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.3)
        }
        
        // Content Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Math.max(window.height * 0.02, 15)
            
            Text {
                text: "Timer Name"
                font.pixelSize: Math.max(window.width * 0.02, 15)
                font.weight: Font.Medium
                color: window.textColor
            }
            
            TextField {
                id: timerNameField
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(window.height * 0.07, 40)
                placeholderText: "Enter timer name..."
                font.pixelSize: Math.max(window.width * 0.022, 16)
                selectByMouse: true
                color: window.textColor
                
                background: Rectangle {
                    color: window.cardBackgroundColor
                    border.color: parent.activeFocus ? window.accentColor : window.cardBorderColor
                    border.width: parent.activeFocus ? 2 : 1
                    radius: 8
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
        
        // Button Section
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.3)
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            Layout.bottomMargin: 5
            
            Item {
                Layout.fillWidth: true
            }
            
            Button {
                id: cancelButton
                text: "Cancel"
                Layout.preferredWidth: Math.max(window.width * 0.08, 80)
                Layout.preferredHeight: Math.max(window.height * 0.05, 36)
                
                background: Rectangle {
                    color: parent.pressed ? Qt.darker(window.cardBorderColor, 1.1) : window.cardBorderColor
                    radius: 8
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: window.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Math.max(window.width * 0.015, 13)
                    font.weight: Font.Medium
                }
                
                onClicked: {
                    root.close()
                    timerNameField.text = ""
                }
            }
            
            Button {
                text: "Create Timer"
                enabled: timerNameField.text.trim() !== ""
                Layout.preferredWidth: Math.max(window.width * 0.12, 100)
                Layout.preferredHeight: Math.max(window.height * 0.05, 36)
                
                background: Rectangle {
                    color: {
                        if (!parent.enabled) return Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.5)
                        if (parent.pressed) return Qt.darker(window.primaryColor, 1.1)
                        return window.primaryColor
                    }
                    radius: 8
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "white" : Qt.rgba(1, 1, 1, 0.5)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Math.max(window.width * 0.015, 13)
                    font.weight: Font.Medium
                }
                
                onClicked: {
                    timerManager.addTimer(timerNameField.text.trim(), "stopwatch")
                    root.close()
                    timerNameField.text = ""
                }
            }
        }
    }
}