import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * RenameTimerDialogResponsive - Fully responsive timer rename dialog
 * 
 * Features:
 * - Responsive sizing and typography
 * - Smart validation with real-time feedback
 * - Modern input styling with focus animations
 * - All original rename functionality preserved
 */
Dialog {
    id: root
    
    // === PROPER RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.8, 400)
    height: Math.min(parent.height * 0.7, 350)
    
    // Always center and stay within bounds
    anchors.centerIn: parent
    modal: true
    
    // Public properties (same as original)
    property var currentTimer: null
    property alias renameTextField: renameTextField
    
    
    // === VALIDATION LOGIC ===
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
    
    // === SMOOTH ANIMATIONS ===
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.9
                to: 1.0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
    
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 150
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.95
                duration: 150
                easing.type: Easing.InCubic
            }
        }
    }
    
    // === MODERN BACKGROUND STYLING ===
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.primaryColor
        border.width: 2
        radius: Math.max(root.baseWidth * 0.025, 12)
        
        // Simple shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            color: "#20000000"
            radius: parent.radius
            z: parent.z - 1
        }
    }
    
    // === RESPONSIVE HEADER ===
    header: Rectangle {
        height: 70
        color: window.primaryColor
        radius: Math.max(root.baseWidth * 0.025, 12)
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // Icon container
            Rectangle {
                width: 36
                height: 36
                color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.15)
                radius: 10
                
                Text {
                    anchors.centerIn: parent
                    text: "✏️"
                    font.pixelSize: 20
                }
            }
            
            // Header text
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Rename Timer"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.backgroundColor
                }
                
                Text {
                    text: currentTimer ? "Editing: " + currentTimer.name : "Change timer name"
                    font.pixelSize: 12
                    color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.8)
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    elide: Text.ElideRight
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
            console.log("Key pressed in RenameTimerDialog:", event.key)
            if (event.key === Qt.Key_Escape) {
                console.log("ESC in RenameTimerDialog")
                root.close()
                renameTextField.text = ""
                window.restoreFocus()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                console.log("ENTER in RenameTimerDialog")
                if (currentTimer && renameTextField.text.trim() !== "") {
                    timerManager.renameTimer(currentTimer.id, renameTextField.text.trim())
                    root.close()
                    renameTextField.text = ""
                    window.restoreFocus()
                }
                event.accepted = true
            }
        }
    }

    // === RESPONSIVE CONTENT ===
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // Context text
        Text {
            text: (currentTimer && currentTimer.name) ? 
                  "Enter a new name for \"" + currentTimer.name + "\":" : 
                  "Enter a new name for the timer:"
            font.pixelSize: 14
            color: window.textColor
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        
        // Enhanced text field with validation styling
        TextField {
            id: renameTextField
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            
            placeholderText: "Enter timer name..."
            font.pixelSize: 16
            selectByMouse: true
            color: window.textColor
            
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    console.log("ENTER in renameTextField")
                    if (currentTimer && text.trim() !== "") {
                        timerManager.renameTimer(currentTimer.id, text.trim())
                        root.close()
                        text = ""
                        window.restoreFocus()
                    }
                    event.accepted = true
                }
            }
            
            // Dynamic styling based on validation state
            background: Rectangle {
                color: window.cardBackgroundColor
                border.color: {
                    if (parent.activeFocus) {
                        if (root.isNameTaken(parent.text)) return window.dangerColor
                        return window.accentColor
                    }
                    if (root.isNameTaken(parent.text)) return Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.5)
                    return window.cardBorderColor
                }
                border.width: parent.activeFocus ? 2 : 1
                radius: 8
                
                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }
                
                Behavior on border.width {
                    NumberAnimation { duration: 150 }
                }
            }
        }
        
        // Smart validation feedback
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: "transparent"
            
            Text {
                anchors.fill: parent
                text: {
                    if (root.isNameTaken(renameTextField.text)) {
                        return "⚠️ A timer with this name already exists"
                    } else if (renameTextField.text.trim() !== "" && currentTimer && renameTextField.text.trim() !== currentTimer.name) {
                        return "✅ Name is available"
                    }
                    return ""
                }
                color: root.isNameTaken(renameTextField.text) ? window.dangerColor : window.successColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                opacity: text !== "" ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }
        
        // Helpful hint
        Text {
            text: "💡 Choose a unique, descriptive name for easy identification"
            font.pixelSize: 10
            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        
        // Flexible spacer
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 12
        }
        
        // === RESPONSIVE BUTTON SECTION ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Item {
                Layout.fillWidth: true
            }
            
            Button {
                id: cancelButton
                text: "Cancel"
                Layout.preferredWidth: 90
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
                    root.close()
                    renameTextField.text = ""
                    window.restoreFocus()
                }
            }
            
            Button {
                id: renameButton
                text: "Rename"
                enabled: renameTextField.text.trim() !== "" && 
                         renameTextField.text.trim() !== (currentTimer ? currentTimer.name : "") &&
                         !root.isNameTaken(renameTextField.text)
                Layout.preferredWidth: 120
                Layout.preferredHeight: 36
                
                background: Rectangle {
                    color: {
                        if (!parent.enabled) return Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.5)
                        if (parent.pressed) return Qt.darker(window.accentColor, 1.1)
                        if (parent.hovered) return Qt.lighter(window.accentColor, 1.1)
                        return window.accentColor
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
                    font.pixelSize: 13
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
                
                // Subtle success glow when enabled
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: parent.enabled ? Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.3) : "transparent"
                    border.width: parent.enabled && parent.hovered ? 1 : 0
                    radius: parent.radius
                    
                    Behavior on border.width {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }
    }
    
    // === EVENT HANDLERS ===
    
    onOpened: {
        renameTextField.forceActiveFocus()
        renameTextField.selectAll()
    }
    
    onClosed: {
        renameTextField.text = ""
    }
}