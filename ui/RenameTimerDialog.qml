import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    anchors.centerIn: parent
    width: window.width * 0.7
    height: window.height * 0.4
    modal: true
    
    property var currentTimer: null
    property alias renameTextField: renameTextField
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            cancelButton.clicked()
        }
    }
    
    Shortcut {
        sequence: "Return"
        onActivated: {
            var newName = renameTextField.text.trim()
            if (newName !== "" && !isNameTaken(newName) && currentTimer) {
                timerManager.renameTimer(currentTimer.id, newName)
                root.close()
                renameTextField.text = ""
            }
        }
    }
    
    function isNameTaken(newName) {
        if (!newName || newName.trim() === "") return false
        var trimmedName = newName.trim().toLowerCase()
        
        for (var i = 0; i < timerManager.timers.length; i++) {
            var timer = timerManager.timers[i]
            // Skip the current timer being renamed
            if (currentTimer && timer.id === currentTimer.id) continue
            // Check if name matches (case-insensitive)
            if (timer.name.toLowerCase() === trimmedName) return true
        }
        return false
    }
    
    function openForTimer(timer) {
        currentTimer = timer
        if (timer) {
            renameTextField.text = timer.name
            open()
            renameTextField.selectAll()
            renameTextField.forceActiveFocus()
        }
    }
    
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.primaryColor
        border.width: 2
        radius: 8
    }
    
    header: Rectangle {
        height: 50
        color: window.primaryColor
        radius: 8
        
        Text {
            anchors.centerIn: parent
            text: "Rename Timer"
            font.pixelSize: 16
            font.bold: true
            color: window.backgroundColor
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Math.max(window.width * 0.025, 20)
        spacing: Math.max(window.height * 0.025, 20)
        
        Text {
            text: (currentTimer && currentTimer.name) ? 
                  "Enter a new name for \"" + currentTimer.name + "\":" : 
                  "Enter a new name for the timer:"
            font.pixelSize: 14
            color: window.textColor
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        
        TextField {
            id: renameTextField
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
        
        // Warning text for duplicate names
        Text {
            text: root.isNameTaken(renameTextField.text) ? "⚠ A timer with this name already exists" : ""
            color: window.dangerColor
            font.pixelSize: 12
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            wrapMode: Text.WordWrap
            opacity: text !== "" ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
        
        Item {
            Layout.fillHeight: true
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
                    renameTextField.text = ""
                    window.restoreFocus()
                }
            }
            
            Button {
                id: renameConfirmButton
                text: "Rename"
                enabled: renameTextField.text.trim() !== "" && 
                         renameTextField.text.trim() !== (currentTimer ? currentTimer.name : "") &&
                         !root.isNameTaken(renameTextField.text)
                Layout.preferredWidth: Math.max(window.width * 0.12, 100)
                Layout.preferredHeight: Math.max(window.height * 0.05, 36)
                
                background: Rectangle {
                    color: {
                        if (!parent.enabled) return Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.5)
                        if (parent.pressed) return Qt.darker(window.accentColor, 1.1)
                        return window.accentColor
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
                    if (currentTimer && renameTextField.text.trim() !== "") {
                        timerManager.renameTimer(currentTimer.id, renameTextField.text.trim())
                        root.close()
                        renameTextField.text = ""
                        window.restoreFocus()
                    }
                }
            }
        }
    }
}