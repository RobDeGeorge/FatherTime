import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    
    // === PROPER RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.8, 500)
    height: Math.min(parent.height * 0.8, 450)
    
    anchors.centerIn: parent
    modal: true
    
    // Public aliases for external access
    property alias countdownNameField: countdownNameField
    property alias hoursSpinBox: hoursSpinBox
    property alias minutesSpinBox: minutesSpinBox
    property alias secondsSpinBox: secondsSpinBox
    
    function resetFields() {
        countdownNameField.text = ""
        hoursSpinBox.value = 0
        minutesSpinBox.value = 0
        secondsSpinBox.value = 0
    }
    
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
            anchors.topMargin: 3
            anchors.leftMargin: 3
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
            anchors.margins: 18
            spacing: 12
            
            Rectangle {
                width: 36
                height: 36
                color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.15)
                radius: 10
                
                Text {
                    anchors.centerIn: parent
                    text: "⏲️"
                    font.pixelSize: 20
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Add Countdown Timer"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.backgroundColor
                }
                
                Text {
                    text: "Create a timer that counts down from a set duration"
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
                root.resetFields()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                var countdownName = countdownNameField.text.trim() || "Countdown"
                var totalSeconds = hoursSpinBox.value * 3600 + minutesSpinBox.value * 60 + secondsSpinBox.value
                if (totalSeconds > 0) {
                    timerManager.addTimer(countdownName, "countdown")
                    var newTimer = timerManager.timers[timerManager.timers.length - 1]
                    timerManager.setCountdownTime(newTimer.id, totalSeconds)
                    root.close()
                    root.resetFields()
                }
                event.accepted = true
            }
        }
    }

    // === CONTENT ===
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
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
                id: countdownNameField
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                
                placeholderText: "Enter timer name..."
                font.pixelSize: 16
                selectByMouse: true
                color: window.textColor
                
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        var countdownName = text.trim() || "Countdown"
                        var totalSeconds = hoursSpinBox.value * 3600 + minutesSpinBox.value * 60 + secondsSpinBox.value
                        if (totalSeconds > 0) {
                            timerManager.addTimer(countdownName, "countdown")
                            var newTimer = timerManager.timers[timerManager.timers.length - 1]
                            timerManager.setCountdownTime(newTimer.id, totalSeconds)
                            root.close()
                            root.resetFields()
                        }
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
        
        // === DURATION SECTION ===
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Text {
                text: "Duration"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: window.textColor
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                // Hours
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Hours"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: window.textColor
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                    
                    SpinBox {
                        id: hoursSpinBox
                        from: 0
                        to: 23
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        font.pixelSize: 14
                        textFromValue: function(value, locale) { return value + "h" }
                    }
                }
                
                // Minutes
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Minutes"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: window.textColor
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                    
                    SpinBox {
                        id: minutesSpinBox
                        from: 0
                        to: 59
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        font.pixelSize: 14
                        textFromValue: function(value, locale) { return value + "m" }
                    }
                }
                
                // Seconds
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "Seconds"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: window.textColor
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                    
                    SpinBox {
                        id: secondsSpinBox
                        from: 0
                        to: 59
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        font.pixelSize: 14
                        textFromValue: function(value, locale) { return value + "s" }
                    }
                }
            }
            
            Text {
                text: "💡 Set the duration for your countdown timer"
                font.pixelSize: 11
                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 16
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.3)
        }
        
        // === BUTTONS ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Layout.bottomMargin: 8
            
            Item {
                Layout.fillWidth: true
            }
            
            Button {
                text: "Cancel"
                Layout.preferredWidth: 100
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
                    root.resetFields()
                }
            }
            
            Button {
                text: "Create Timer"
                enabled: countdownNameField.text.trim() !== "" && 
                        (hoursSpinBox.value > 0 || minutesSpinBox.value > 0 || secondsSpinBox.value > 0)
                Layout.preferredWidth: 130
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
                    let totalSeconds = hoursSpinBox.value * 3600 + minutesSpinBox.value * 60 + secondsSpinBox.value
                    timerManager.addTimer(countdownNameField.text.trim(), "countdown")
                    let newTimer = timerManager.timers[timerManager.timers.length - 1]
                    timerManager.setCountdownTime(newTimer.id, totalSeconds)
                    root.close()
                    root.resetFields()
                }
            }
        }
    }
    
    onOpened: {
        countdownNameField.forceActiveFocus()
    }
    
    onClosed: {
        resetFields()
    }
}