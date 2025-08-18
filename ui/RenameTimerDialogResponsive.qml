import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * EditTimerDialogResponsive - Enhanced dialog for editing timer name and time values
 * 
 * Features:
 * - Edit timer name with smart validation
 * - Edit time values for both stopwatch and countdown timers
 * - Responsive sizing and typography
 * - Modern input styling with focus animations
 * - Smart time input validation
 */
Dialog {
    id: root
    
    // === PROPER RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.9, 450)
    height: Math.min(parent.height * 0.85, 600)
    
    // Always center and stay within bounds
    anchors.centerIn: parent
    modal: true
    focus: true  // Ensure dialog can receive key events
    
    // Public properties
    property var currentTimer: null
    property alias renameTextField: renameTextField
    property alias hoursField: hoursField
    property alias minutesField: minutesField
    property alias secondsField: secondsField
    
    
    
    // === VALIDATION LOGIC ===
    function isNameTaken(newName) {
        if (!newName || newName.trim() === "") {
            console.log("Name validation: empty name")
            return false
        }
        var trimmedName = newName.trim().toLowerCase()
        
        // If the name hasn't changed from the original, it's always valid
        if (currentTimer && trimmedName === currentTimer.name.toLowerCase()) {
            console.log("Name validation: name unchanged, valid")
            return false
        }
        
        for (var i = 0; i < timerManager.timers.length; i++) {
            var timer = timerManager.timers[i]
            // Skip the current timer being renamed
            if (currentTimer && timer.id === currentTimer.id) continue
            // Check if name matches (case-insensitive)
            if (timer.name.toLowerCase() === trimmedName) {
                console.log("Name validation: name taken by timer ID", timer.id)
                return true
            }
        }
        console.log("Name validation: name available")
        return false
    }
    
    // Helper function to parse time from timer
    function parseTimerTime(timer) {
        var totalSeconds = 0
        if (timer.type === "countdown") {
            totalSeconds = timer.countdownSeconds
        } else {
            totalSeconds = timer.elapsedSeconds
        }
        
        var hours = Math.floor(totalSeconds / 3600)
        var minutes = Math.floor((totalSeconds % 3600) / 60)
        var seconds = totalSeconds % 60
        
        return { hours: hours, minutes: minutes, seconds: seconds }
    }
    
    // Helper function to calculate total seconds from input fields
    function calculateTotalSeconds() {
        var h = parseInt(hoursField.text) || 0
        var m = parseInt(minutesField.text) || 0
        var s = parseInt(secondsField.text) || 0
        var total = h * 3600 + m * 60 + s
        console.log("Calculate total seconds - H:", h, "M:", m, "S:", s, "Total:", total)
        return total
    }
    
    // Validation for time inputs
    function isTimeValid() {
        var h = parseInt(hoursField.text) || 0
        var m = parseInt(minutesField.text) || 0
        var s = parseInt(secondsField.text) || 0
        
        var result = h >= 0 && m >= 0 && m < 60 && s >= 0 && s < 60
        console.log("Time validation - H:", h, "M:", m, "S:", s, "Valid:", result)
        return result
    }
    
    function openForTimer(timer) {
        console.log("openForTimer called with:", timer)
        currentTimer = timer
        if (timer) {
            console.log("Setting timer name to:", timer.name)
            renameTextField.text = timer.name
            
            // Populate time fields based on timer type
            var timeData = parseTimerTime(timer)
            console.log("Parsed time data:", timeData)
            hoursField.text = timeData.hours.toString()
            minutesField.text = timeData.minutes.toString()
            secondsField.text = timeData.seconds.toString()
            
            open()
            renameTextField.selectAll()
            renameTextField.forceActiveFocus()
        } else {
            console.log("Timer is null, not opening dialog")
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
        height: Math.max(80, Math.min(parent.height * 0.15, 100))
        color: window.primaryColor
        radius: Math.max(root.width * 0.02, 8)
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Math.max(12, Math.min(parent.width * 0.04, 20))
            spacing: Math.max(8, Math.min(parent.width * 0.03, 16))
            
            // Icon container
            Rectangle {
                Layout.preferredWidth: Math.max(28, Math.min(parent.width * 0.08, 40))
                Layout.preferredHeight: Layout.preferredWidth
                color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.15)
                radius: Layout.preferredWidth * 0.25
                
                Text {
                    anchors.centerIn: parent
                    text: "✏️"
                    font.pixelSize: Math.max(14, Math.min(parent.width * 0.6, 22))
                }
            }
            
            // Header text
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Math.max(2, Math.min(parent.height * 0.1, 6))
                
                Text {
                    text: "Edit Timer"
                    font.pixelSize: Math.max(14, Math.min(parent.width * 0.04, 20))
                    font.weight: Font.Bold
                    color: window.backgroundColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                Text {
                    text: currentTimer ? "Editing: " + currentTimer.name : "Change timer name and time"
                    font.pixelSize: Math.max(10, Math.min(parent.width * 0.025, 14))
                    color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.85)
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }
            }
        }
    }
    
    // === GLOBAL KEY HANDLER ===
    Keys.onPressed: function(event) {
        console.log("Global key pressed in dialog:", event.key)
        if (event.key === Qt.Key_Escape) {
            console.log("Global ESC - closing dialog")
            root.close()
            renameTextField.text = ""
            window.restoreFocus()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                console.log("ENTER in EditTimerDialog")
                
                // Use the same timer fallback logic as the save button
                var timerToEdit = currentTimer
                if (!timerToEdit && timerManager && timerManager.timers && timerManager.timers.length > 0) {
                    timerToEdit = timerManager.timers[0]
                    console.log("ENTER - Using first timer as fallback:", timerToEdit)
                }
                
                if (timerToEdit && renameTextField.text.trim() !== "" && root.isTimeValid()) {
                    console.log("ENTER - Processing save...")
                    
                    // Apply name change only if it actually changed
                    if (renameTextField.text.trim() !== timerToEdit.name) {
                        console.log("ENTER - Renaming timer...")
                        timerManager.renameTimer(timerToEdit.id, renameTextField.text.trim())
                    }
                    
                    // Apply time change
                    var newTimeSeconds = root.calculateTotalSeconds()
                    console.log("ENTER - New time seconds:", newTimeSeconds)
                    
                    if (timerToEdit.type === "countdown") {
                        console.log("ENTER - Setting countdown time to:", newTimeSeconds)
                        timerManager.setCountdownTime(timerToEdit.id, newTimeSeconds)
                    } else {
                        var currentElapsed = timerToEdit.elapsedSeconds
                        var timeDiff = newTimeSeconds - currentElapsed
                        console.log("ENTER - Current elapsed:", currentElapsed, "Adjustment:", timeDiff)
                        if (timeDiff !== 0) {
                            timerManager.adjustTime(timerToEdit.id, timeDiff)
                        }
                    }
                    
                    // Close dialog immediately after successful save
                    console.log("ENTER - About to close dialog...")
                    root.close()
                    window.restoreFocus()
                }
                event.accepted = true
        }
    }

    // === RESPONSIVE CONTENT ===
    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20
        
        // === NAME SECTION ===
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Math.max(6, Math.min(root.height * 0.015, 12))
            
            Text {
                text: "Timer Name"
                font.pixelSize: Math.max(12, Math.min(root.width * 0.032, 16))
                font.weight: Font.Medium
                color: window.textColor
                Layout.fillWidth: true
            }
            
            // Enhanced text field with validation styling
            TextField {
                id: renameTextField
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(36, Math.min(root.height * 0.08, 48))
                
                placeholderText: "Enter timer name..."
                font.pixelSize: Math.max(14, Math.min(root.width * 0.035, 18))
                selectByMouse: true
                color: window.textColor
            
            // Debug when text changes
            onTextChanged: {
                console.log("Name field changed to:", text, "currentTimer:", !!currentTimer)
            }
            
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    console.log("ENTER in renameTextField")
                    
                    // Use the same timer fallback logic as the save button
                    var timerToEdit = currentTimer
                    if (!timerToEdit && timerManager && timerManager.timers && timerManager.timers.length > 0) {
                        timerToEdit = timerManager.timers[0]
                        console.log("TextField ENTER - Using first timer as fallback:", timerToEdit)
                    }
                    
                    if (timerToEdit && text.trim() !== "" && root.isTimeValid()) {
                        console.log("TextField ENTER - Processing save...")
                        
                        // Apply name change only if it actually changed
                        if (text.trim() !== timerToEdit.name) {
                            console.log("TextField ENTER - Renaming timer...")
                            timerManager.renameTimer(timerToEdit.id, text.trim())
                        }
                        
                        // Apply time change
                        var newTimeSeconds = root.calculateTotalSeconds()
                        console.log("TextField ENTER - New time seconds:", newTimeSeconds)
                        
                        if (timerToEdit.type === "countdown") {
                            console.log("TextField ENTER - Setting countdown time to:", newTimeSeconds)
                            timerManager.setCountdownTime(timerToEdit.id, newTimeSeconds)
                        } else {
                            var currentElapsed = timerToEdit.elapsedSeconds
                            var timeDiff = newTimeSeconds - currentElapsed
                            console.log("TextField ENTER - Current elapsed:", currentElapsed, "Adjustment:", timeDiff)
                            if (timeDiff !== 0) {
                                timerManager.adjustTime(timerToEdit.id, timeDiff)
                            }
                        }
                        
                        // Close dialog immediately after successful save
                        console.log("TextField ENTER - About to close dialog...")
                        root.close()
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
            Text {
                text: {
                    if (root.isNameTaken(renameTextField.text)) {
                        return "⚠️ A timer with this name already exists"
                    } else if (renameTextField.text.trim() !== "" && currentTimer) {
                        if (renameTextField.text.trim() === currentTimer.name) {
                            return "✅ Name unchanged (valid)"
                        } else {
                            return "✅ Name is available"
                        }
                    }
                    return ""
                }
                color: root.isNameTaken(renameTextField.text) ? window.dangerColor : window.successColor
                font.pixelSize: Math.max(9, Math.min(root.width * 0.025, 12))
                Layout.fillWidth: true
                Layout.maximumWidth: root.width - 48
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                opacity: text !== "" ? 0.85 : 0.0
                Layout.topMargin: text !== "" ? 4 : 0
                
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }
        
        // === TIME EDITING SECTION ===
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            
            // Section header
            Text {
                text: currentTimer && currentTimer.type === "countdown" ? 
                      "Countdown Time" : "Elapsed Time"
                font.pixelSize: Math.max(12, Math.min(root.width * 0.032, 16))
                font.weight: Font.Medium
                color: window.textColor
                Layout.fillWidth: true
                Layout.topMargin: Math.max(4, Math.min(root.height * 0.01, 8))
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: timeContentLayout.implicitHeight + Math.max(24, Math.min(root.height * 0.06, 40))
                color: Qt.rgba(window.primaryColor.r, window.primaryColor.g, window.primaryColor.b, 0.03)
                border.color: Qt.rgba(window.primaryColor.r, window.primaryColor.g, window.primaryColor.b, 0.15)
                border.width: 1
                radius: Math.max(6, Math.min(root.width * 0.025, 12))
                
                ColumnLayout {
                    id: timeContentLayout
                    anchors.fill: parent
                    anchors.margins: Math.max(12, Math.min(root.width * 0.035, 20))
                    spacing: Math.max(12, Math.min(root.height * 0.025, 20))
                
                    // Time input fields
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Math.max(8, Math.min(root.width * 0.025, 16))
                        Layout.alignment: Qt.AlignHCenter
                    
                    // Hours
                    ColumnLayout {
                        spacing: Math.max(3, Math.min(root.height * 0.008, 6))
                        Layout.alignment: Qt.AlignTop
                        
                        Text {
                            text: "Hours"
                            font.pixelSize: Math.max(8, Math.min(root.width * 0.022, 11))
                            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        TextField {
                            id: hoursField
                            Layout.preferredWidth: Math.max(50, Math.min(root.width * 0.15, 80))
                            Layout.preferredHeight: Math.max(32, Math.min(root.height * 0.065, 44))
                            text: "0"
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: Math.max(12, Math.min(root.width * 0.035, 18))
                            font.weight: Font.Medium
                            color: window.textColor
                            validator: IntValidator { bottom: 0; top: 999 }
                            selectByMouse: true
                            
                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    console.log("ENTER in hoursField - triggering save")
                                    saveButton.clicked()
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
                            }
                        }
                    }
                    
                        Text {
                            text: ":"
                            font.pixelSize: Math.max(18, Math.min(root.width * 0.045, 28))
                            font.weight: Font.Bold
                            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.6)
                            Layout.alignment: Qt.AlignVCenter
                            Layout.topMargin: Math.max(8, Math.min(root.height * 0.02, 14))
                        }
                    
                    // Minutes
                    ColumnLayout {
                        spacing: Math.max(3, Math.min(root.height * 0.008, 6))
                        Layout.alignment: Qt.AlignTop
                        
                        Text {
                            text: "Minutes"
                            font.pixelSize: Math.max(8, Math.min(root.width * 0.022, 11))
                            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        TextField {
                            id: minutesField
                            Layout.preferredWidth: Math.max(50, Math.min(root.width * 0.15, 80))
                            Layout.preferredHeight: Math.max(32, Math.min(root.height * 0.065, 44))
                            text: "0"
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: Math.max(12, Math.min(root.width * 0.035, 18))
                            font.weight: Font.Medium
                            color: window.textColor
                            validator: IntValidator { bottom: 0; top: 59 }
                            selectByMouse: true
                            
                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    console.log("ENTER in minutesField - triggering save")
                                    saveButton.clicked()
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
                            }
                        }
                    }
                    
                        Text {
                            text: ":"
                            font.pixelSize: Math.max(18, Math.min(root.width * 0.045, 28))
                            font.weight: Font.Bold
                            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.6)
                            Layout.alignment: Qt.AlignVCenter
                            Layout.topMargin: Math.max(8, Math.min(root.height * 0.02, 14))
                        }
                    
                    // Seconds
                    ColumnLayout {
                        spacing: Math.max(3, Math.min(root.height * 0.008, 6))
                        Layout.alignment: Qt.AlignTop
                        
                        Text {
                            text: "Seconds"
                            font.pixelSize: Math.max(8, Math.min(root.width * 0.022, 11))
                            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        TextField {
                            id: secondsField
                            Layout.preferredWidth: Math.max(50, Math.min(root.width * 0.15, 80))
                            Layout.preferredHeight: Math.max(32, Math.min(root.height * 0.065, 44))
                            text: "0"
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: Math.max(12, Math.min(root.width * 0.035, 18))
                            font.weight: Font.Medium
                            color: window.textColor
                            validator: IntValidator { bottom: 0; top: 59 }
                            selectByMouse: true
                            
                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    console.log("ENTER in secondsField - triggering save")
                                    saveButton.clicked()
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
                            }
                        }
                    }
                    
                    }
                    
                    // Current time reference
                    Text {
                        text: "Current: " + (currentTimer ? currentTimer.displayTime : "00:00:00")
                        font.pixelSize: Math.max(10, Math.min(root.width * 0.025, 13))
                        color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        Layout.topMargin: Math.max(6, Math.min(root.height * 0.015, 10))
                        elide: Text.ElideRight
                    }
                }
            }
            
            // Time validation feedback - NOW OUTSIDE the rectangle, truly below the boxes
            Text {
                text: {
                    if (!root.isTimeValid()) {
                        return "⚠️ Invalid time values (minutes and seconds must be 0-59)"
                    } else if (root.calculateTotalSeconds() === 0 && currentTimer && currentTimer.type === "countdown") {
                        return "⚠️ Countdown time cannot be zero"
                    }
                    return "✅ Time values are valid"
                }
                font.pixelSize: Math.max(9, Math.min(root.width * 0.025, 12))
                color: !root.isTimeValid() || (root.calculateTotalSeconds() === 0 && currentTimer && currentTimer.type === "countdown") ? 
                       window.dangerColor : window.successColor
                Layout.fillWidth: true
                Layout.maximumWidth: root.width - 48
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                opacity: text !== "" ? 0.85 : 0.0
                Layout.topMargin: Math.max(6, Math.min(root.height * 0.015, 12))
                
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }
        }
        
        
        // Flexible spacer
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 20
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
                Layout.preferredWidth: Math.max(70, Math.min(root.width * 0.2, 100))
                Layout.preferredHeight: Math.max(32, Math.min(root.height * 0.06, 40))
                
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
                    root.close()
                    renameTextField.text = ""
                    window.restoreFocus()
                }
            }
            
            Button {
                id: saveButton
                text: "Save Changes"
                enabled: true  // Temporarily always enable for debugging
                Layout.preferredWidth: Math.max(100, Math.min(root.width * 0.25, 140))
                Layout.preferredHeight: Math.max(32, Math.min(root.height * 0.06, 40))
                
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
                    font.pixelSize: Math.max(11, Math.min(root.width * 0.028, 14))
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
                
                onClicked: {
                    console.log("Save button clicked!")
                    console.log("Button enabled state:", saveButton.enabled)
                    console.log("currentTimer is null, trying to find timer by other means...")
                    
                    // Try to find the timer by looking at the first timer since currentTimer is null
                    var timerToEdit = currentTimer
                    if (!timerToEdit && timerManager && timerManager.timers && timerManager.timers.length > 0) {
                        timerToEdit = timerManager.timers[0]  // Use first timer as fallback
                        console.log("Using first timer as fallback:", timerToEdit)
                    }
                    
                    if (timerToEdit && renameTextField.text.trim() !== "" && root.isTimeValid()) {
                        console.log("Saving timer changes...")
                        console.log("Timer to edit type:", timerToEdit ? timerToEdit.type : "null")
                        console.log("Timer to edit name:", timerToEdit ? timerToEdit.name : "null")
                        console.log("New name:", renameTextField.text.trim())
                        
                        // Apply name change only if it actually changed
                        if (renameTextField.text.trim() !== timerToEdit.name) {
                            console.log("Renaming timer...")
                            timerManager.renameTimer(timerToEdit.id, renameTextField.text.trim())
                        }
                        
                        // Apply time change
                        var newTimeSeconds = root.calculateTotalSeconds()
                        console.log("New time seconds:", newTimeSeconds)
                        
                        if (timerToEdit.type === "countdown") {
                            console.log("Setting countdown time to:", newTimeSeconds)
                            timerManager.setCountdownTime(timerToEdit.id, newTimeSeconds)
                        } else {
                            var currentElapsed = timerToEdit.elapsedSeconds
                            var timeDiff = newTimeSeconds - currentElapsed
                            console.log("Current elapsed:", currentElapsed, "New time:", newTimeSeconds, "Adjustment:", timeDiff)
                            if (timeDiff !== 0) {
                                timerManager.adjustTime(timerToEdit.id, timeDiff)
                            }
                        }
                        
                        // Close dialog immediately after successful save
                        console.log("About to close dialog...")
                        root.close()
                        console.log("Dialog close() called")
                        window.restoreFocus()
                    } else {
                        console.log("Save conditions not met - not closing dialog")
                        console.log("timerToEdit:", !!timerToEdit, "name not empty:", renameTextField.text.trim() !== "", "time valid:", root.isTimeValid())
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
        console.log("Dialog opened, currentTimer:", currentTimer)
        console.log("Name field text:", renameTextField.text)
        // Give dialog focus first, then focus the text field
        root.forceActiveFocus()
        renameTextField.forceActiveFocus()
        renameTextField.selectAll()
    }
    
    onClosed: {
        console.log("Dialog closing, clearing fields")
        currentTimer = null
        renameTextField.text = ""
        hoursField.text = "0"
        minutesField.text = "0"
        secondsField.text = "0"
    }
}