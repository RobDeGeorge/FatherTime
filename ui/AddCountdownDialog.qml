import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    anchors.centerIn: parent
    width: window.width * 0.8
    height: window.height * 0.7
    modal: true
    
    property alias countdownNameField: countdownNameField
    property alias hoursSpinBox: hoursSpinBox
    property alias minutesSpinBox: minutesSpinBox
    property alias secondsSpinBox: secondsSpinBox
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            cancelButton.clicked()
        }
    }
    
    Shortcut {
        sequence: "Return"
        onActivated: {
            if (countdownNameField.text.trim() !== "") {
                let totalSeconds = hoursSpinBox.value * 3600 + minutesSpinBox.value * 60 + secondsSpinBox.value
                if (totalSeconds > 0) {
                    timerManager.addTimer(countdownNameField.text.trim(), "countdown")
                    let newTimer = timerManager.timers[timerManager.timers.length - 1]
                    timerManager.setCountdownTime(newTimer.id, totalSeconds)
                    root.close()
                    resetFields()
                }
            }
        }
    }
    
    function resetFields() {
        countdownNameField.text = ""
        hoursSpinBox.value = 0
        minutesSpinBox.value = 0
        secondsSpinBox.value = 0
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
                    text: "⏲️"
                    font.pixelSize: Math.max(window.width * 0.022, 16)
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Add Countdown Timer"
                    font.pixelSize: Math.max(window.width * 0.022, 16)
                    font.bold: true
                    color: window.backgroundColor
                }
                
                Text {
                    text: "Create a timer that counts down from a set duration"
                    font.pixelSize: Math.max(window.width * 0.014, 12)
                    color: Qt.rgba(window.backgroundColor.r, window.backgroundColor.g, window.backgroundColor.b, 0.8)
                }
            }
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: Math.max(window.width * 0.025, 15)
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        ColumnLayout {
            width: parent.width
            spacing: Math.max(window.height * 0.025, 20)
            
            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.3)
            }
            
            Text {
                text: "Timer Name"
                font.pixelSize: Math.max(window.width * 0.02, 15)
                font.weight: Font.Medium
                color: window.textColor
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            TextField {
                id: countdownNameField
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
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "Duration"
                    font.pixelSize: Math.max(window.width * 0.02, 15)
                    font.weight: Font.Medium
                    color: window.textColor
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15
                    
                    // Hours
                    ColumnLayout {
                        spacing: 5
                        Text {
                            text: "Hours"
                            font.pixelSize: Math.max(window.width * 0.014, 12)
                            font.weight: Font.Medium
                            color: window.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                        SpinBox {
                            id: hoursSpinBox
                            from: 0
                            to: 23
                            Layout.preferredWidth: Math.max(window.width * 0.15, 110)
                            Layout.preferredHeight: Math.max(window.height * 0.07, 40)
                            font.pixelSize: Math.max(window.width * 0.018, 14)
                            textFromValue: function(value, locale) { return value + "h" }
                            
                            background: Rectangle {
                                color: window.cardBackgroundColor
                                border.color: hoursSpinBox.activeFocus ? window.accentColor : window.cardBorderColor
                                border.width: hoursSpinBox.activeFocus ? 2 : 1
                                radius: 8
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                            
                            contentItem: Text {
                                text: hoursSpinBox.textFromValue(hoursSpinBox.value, hoursSpinBox.locale)
                                font: hoursSpinBox.font
                                color: window.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            up.indicator: Rectangle {
                                x: hoursSpinBox.mirrored ? 0 : parent.width - width
                                height: parent.height / 2
                                width: Math.max(window.width * 0.03, 24)
                                color: hoursSpinBox.up.pressed ? Qt.darker(window.accentColor, 1.2) : (hoursSpinBox.up.hovered ? Qt.lighter(window.accentColor, 1.1) : window.accentColor)
                                radius: 8
                                
                                Text {
                                    text: "+"
                                    font.pixelSize: Math.max(window.width * 0.014, 12)
                                    font.bold: true
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                            
                            down.indicator: Rectangle {
                                x: hoursSpinBox.mirrored ? 0 : parent.width - width
                                y: parent.height / 2
                                height: parent.height / 2
                                width: Math.max(window.width * 0.03, 24)
                                color: hoursSpinBox.down.pressed ? Qt.darker(window.accentColor, 1.2) : (hoursSpinBox.down.hovered ? Qt.lighter(window.accentColor, 1.1) : window.accentColor)
                                radius: 8
                                
                                Text {
                                    text: "−"
                                    font.pixelSize: Math.max(window.width * 0.014, 12)
                                    font.bold: true
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                        }
                    }
                    
                    // Minutes
                    ColumnLayout {
                        spacing: 5
                        Text {
                            text: "Minutes"
                            font.pixelSize: Math.max(window.width * 0.014, 12)
                            font.weight: Font.Medium
                            color: window.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                        SpinBox {
                            id: minutesSpinBox
                            from: 0
                            to: 59
                            Layout.preferredWidth: Math.max(window.width * 0.15, 110)
                            Layout.preferredHeight: Math.max(window.height * 0.07, 40)
                            font.pixelSize: Math.max(window.width * 0.018, 14)
                            textFromValue: function(value, locale) { return value + "m" }
                            
                            background: Rectangle {
                                color: window.cardBackgroundColor
                                border.color: minutesSpinBox.activeFocus ? window.accentColor : window.cardBorderColor
                                border.width: minutesSpinBox.activeFocus ? 2 : 1
                                radius: 8
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                            
                            contentItem: Text {
                                text: minutesSpinBox.textFromValue(minutesSpinBox.value, minutesSpinBox.locale)
                                font: minutesSpinBox.font
                                color: window.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            up.indicator: Rectangle {
                                x: minutesSpinBox.mirrored ? 0 : parent.width - width
                                height: parent.height / 2
                                width: Math.max(window.width * 0.03, 24)
                                color: minutesSpinBox.up.pressed ? Qt.darker(window.accentColor, 1.2) : (minutesSpinBox.up.hovered ? Qt.lighter(window.accentColor, 1.1) : window.accentColor)
                                radius: 8
                                
                                Text {
                                    text: "+"
                                    font.pixelSize: Math.max(window.width * 0.014, 12)
                                    font.bold: true
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                            
                            down.indicator: Rectangle {
                                x: minutesSpinBox.mirrored ? 0 : parent.width - width
                                y: parent.height / 2
                                height: parent.height / 2
                                width: Math.max(window.width * 0.03, 24)
                                color: minutesSpinBox.down.pressed ? Qt.darker(window.accentColor, 1.2) : (minutesSpinBox.down.hovered ? Qt.lighter(window.accentColor, 1.1) : window.accentColor)
                                radius: 8
                                
                                Text {
                                    text: "−"
                                    font.pixelSize: Math.max(window.width * 0.014, 12)
                                    font.bold: true
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                        }
                    }
                    
                    // Seconds
                    ColumnLayout {
                        spacing: 5
                        Text {
                            text: "Seconds"
                            font.pixelSize: Math.max(window.width * 0.014, 12)
                            font.weight: Font.Medium
                            color: window.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                        SpinBox {
                            id: secondsSpinBox
                            from: 0
                            to: 59
                            Layout.preferredWidth: Math.max(window.width * 0.15, 110)
                            Layout.preferredHeight: Math.max(window.height * 0.07, 40)
                            font.pixelSize: Math.max(window.width * 0.018, 14)
                            textFromValue: function(value, locale) { return value + "s" }
                            
                            background: Rectangle {
                                color: window.cardBackgroundColor
                                border.color: secondsSpinBox.activeFocus ? window.accentColor : window.cardBorderColor
                                border.width: secondsSpinBox.activeFocus ? 2 : 1
                                radius: 8
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                            
                            contentItem: Text {
                                text: secondsSpinBox.textFromValue(secondsSpinBox.value, secondsSpinBox.locale)
                                font: secondsSpinBox.font
                                color: window.textColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            up.indicator: Rectangle {
                                x: secondsSpinBox.mirrored ? 0 : parent.width - width
                                height: parent.height / 2
                                width: Math.max(window.width * 0.03, 24)
                                color: secondsSpinBox.up.pressed ? Qt.darker(window.accentColor, 1.2) : (secondsSpinBox.up.hovered ? Qt.lighter(window.accentColor, 1.1) : window.accentColor)
                                radius: 8
                                
                                Text {
                                    text: "+"
                                    font.pixelSize: Math.max(window.width * 0.014, 12)
                                    font.bold: true
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                            
                            down.indicator: Rectangle {
                                x: secondsSpinBox.mirrored ? 0 : parent.width - width
                                y: parent.height / 2
                                height: parent.height / 2
                                width: Math.max(window.width * 0.03, 24)
                                color: secondsSpinBox.down.pressed ? Qt.darker(window.accentColor, 1.2) : (secondsSpinBox.down.hovered ? Qt.lighter(window.accentColor, 1.1) : window.accentColor)
                                radius: 8
                                
                                Text {
                                    text: "−"
                                    font.pixelSize: Math.max(window.width * 0.014, 12)
                                    font.bold: true
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
            
            // Button Section Separator
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
                        root.resetFields()
                    }
                }
                
                Button {
                    text: "Create Timer"
                    enabled: countdownNameField.text.trim() !== "" && 
                            (hoursSpinBox.value > 0 || minutesSpinBox.value > 0 || secondsSpinBox.value > 0)
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
    }
}