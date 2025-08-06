import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "Father Time"
    
    property color primaryColor: configManager.primary
    property color secondaryColor: configManager.secondary
    property color accentColor: configManager.accent
    property color successColor: configManager.success
    property color dangerColor: configManager.danger
    property color warningColor: configManager.warning
    property color backgroundColor: configManager.background
    property color textColor: configManager.text
    
    // Refresh daily breakdown when sessions change
    Connections {
        target: timerManager
        function onDailyBreakdownChanged() {
            // Model will update automatically via property binding
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20
            
            // Top Half - Timers Section
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 250
                spacing: 20
                
                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: primaryColor
                    radius: 10
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        
                        Text {
                            text: "Father Time"
                            font.pixelSize: 28
                            font.bold: true
                            color: "white"
                            Layout.fillWidth: true
                        }
                        
                        Button {
                            text: "+ Stopwatch"
                            font.pixelSize: 14
                            background: Rectangle {
                                color: parent.pressed ? Qt.darker(accentColor) : accentColor
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: addTimerDialog.open()
                        }
                        
                        Button {
                            text: "+ Countdown"
                            font.pixelSize: 14
                            background: Rectangle {
                                color: parent.pressed ? Qt.darker(successColor) : successColor
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: addCountdownDialog.open()
                        }
                        
                        Button {
                            text: "Reset Data"
                            font.pixelSize: 14
                            background: Rectangle {
                                color: parent.pressed ? Qt.darker(dangerColor) : dangerColor
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: resetDataDialog.open()
                        }
                    }
                }
                
                // Timers List
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ListView {
                        id: timersListView
                        model: timerManager.timers
                        spacing: 15
                        
                        delegate: TimerCard {
                            width: timersListView.width
                            timerItem: modelData
                            onDeleteTimer: timerManager.deleteTimer(timerItem.id)
                            onStartTimer: timerManager.startTimer(timerItem.id)
                            onStopTimer: timerManager.stopTimer(timerItem.id)
                            onResetTimer: timerManager.resetTimer(timerItem.id)
                            onAdjustTime: timerManager.adjustTime(timerItem.id, seconds)
                            onSetCountdown: timerManager.setCountdownTime(timerItem.id, seconds)
                        }
                    }
                }
                
                // Empty state
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: timerManager.timers.length === 0
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 20
                        
                        Text {
                            text: "No timers yet"
                            font.pixelSize: 24
                            color: textColor
                            opacity: 0.6
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Click the + buttons above to create your first timer"
                            font.pixelSize: 16
                            color: textColor
                            opacity: 0.4
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
            
            // Bottom Half - Daily Breakdown Section
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 250
                color: primaryColor
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    // Header
                    Text {
                        text: "Daily Project Breakdown (Last 2 Weeks)"
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                    }
                    
                    // Days List
                    ScrollView {
                        width: parent.width
                        height: parent.height - 40
                        
                        ListView {
                            id: dailyBreakdownList
                            width: parent.width
                            model: timerManager.dailyBreakdown
                            spacing: 15
                            
                            delegate: Rectangle {
                                width: dailyBreakdownList.width
                                height: Math.max(80, projectsColumn.height + 30)
                                color: modelData.isToday ? successColor : "white"
                                radius: 8
                                opacity: modelData.isToday ? 1.0 : 0.95
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 8
                                    
                                    // Date Header
                                    Row {
                                        spacing: 10
                                        
                                        Text {
                                            text: modelData.dayName
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: modelData.isToday ? "white" : primaryColor
                                        }
                                        
                                        Text {
                                            text: modelData.formattedDate
                                            font.pixelSize: 14
                                            color: modelData.isToday ? "white" : textColor
                                            opacity: 0.8
                                        }
                                        
                                        Item { width: 10; height: 1 }
                                        
                                        Rectangle {
                                            width: totalHoursText.width + 16
                                            height: 24
                                            radius: 12
                                            color: modelData.isToday ? "white" : accentColor
                                            opacity: 0.2
                                            
                                            Text {
                                                id: totalHoursText
                                                anchors.centerIn: parent
                                                text: "Total: " + modelData.totalHours
                                                font.pixelSize: 12
                                                font.bold: true
                                                color: modelData.isToday ? "white" : primaryColor
                                            }
                                        }
                                    }
                                    
                                    // Projects
                                    Column {
                                        id: projectsColumn
                                        spacing: 5
                                        
                                        Repeater {
                                            model: modelData.projects
                                            
                                            Row {
                                                spacing: 10
                                                
                                                Rectangle {
                                                    width: 8
                                                    height: 8
                                                    radius: 4
                                                    color: modelData.isToday ? "white" : accentColor
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                
                                                Text {
                                                    text: modelData.name + ":"
                                                    font.pixelSize: 12
                                                    color: modelData.isToday ? "white" : textColor
                                                    font.bold: true
                                                }
                                                
                                                Text {
                                                    text: modelData.hours
                                                    font.pixelSize: 12
                                                    color: modelData.isToday ? "white" : textColor
                                                    font.family: "monospace"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Add Timer Dialog
    Dialog {
        id: addTimerDialog
        title: "Add Stopwatch Timer"
        anchors.centerIn: parent
        width: 300
        height: 150
        
        Column {
            anchors.fill: parent
            spacing: 20
            
            TextField {
                id: timerNameField
                width: parent.width
                placeholderText: "Timer name..."
                font.pixelSize: 14
            }
            
            Row {
                anchors.right: parent.right
                spacing: 10
                
                Button {
                    text: "Cancel"
                    onClicked: {
                        addTimerDialog.close()
                        timerNameField.text = ""
                    }
                }
                
                Button {
                    text: "Add"
                    enabled: timerNameField.text.trim() !== ""
                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? Qt.darker(accentColor) : accentColor) : "#bdc3c7"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        timerManager.addTimer(timerNameField.text.trim(), "stopwatch")
                        addTimerDialog.close()
                        timerNameField.text = ""
                    }
                }
            }
        }
    }
    
    // Add Countdown Dialog
    Dialog {
        id: addCountdownDialog
        title: "Add Countdown Timer"
        anchors.centerIn: parent
        width: 300
        height: 200
        
        Column {
            anchors.fill: parent
            spacing: 20
            
            TextField {
                id: countdownNameField
                width: parent.width
                placeholderText: "Timer name..."
                font.pixelSize: 14
            }
            
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                
                SpinBox {
                    id: hoursSpinBox
                    from: 0
                    to: 23
                    textFromValue: function(value, locale) { return value + "h" }
                }
                
                SpinBox {
                    id: minutesSpinBox
                    from: 0
                    to: 59
                    textFromValue: function(value, locale) { return value + "m" }
                }
                
                SpinBox {
                    id: secondsSpinBox
                    from: 0
                    to: 59
                    textFromValue: function(value, locale) { return value + "s" }
                }
            }
            
            Row {
                anchors.right: parent.right
                spacing: 10
                
                Button {
                    text: "Cancel"
                    onClicked: {
                        addCountdownDialog.close()
                        countdownNameField.text = ""
                        hoursSpinBox.value = 0
                        minutesSpinBox.value = 0
                        secondsSpinBox.value = 0
                    }
                }
                
                Button {
                    text: "Add"
                    enabled: countdownNameField.text.trim() !== "" && 
                            (hoursSpinBox.value > 0 || minutesSpinBox.value > 0 || secondsSpinBox.value > 0)
                    background: Rectangle {
                        color: parent.enabled ? (parent.pressed ? Qt.darker(successColor) : successColor) : "#bdc3c7"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        let totalSeconds = hoursSpinBox.value * 3600 + minutesSpinBox.value * 60 + secondsSpinBox.value
                        timerManager.addTimer(countdownNameField.text.trim(), "countdown")
                        let newTimer = timerManager.timers[timerManager.timers.length - 1]
                        timerManager.setCountdownTime(newTimer.id, totalSeconds)
                        addCountdownDialog.close()
                        countdownNameField.text = ""
                        hoursSpinBox.value = 0
                        minutesSpinBox.value = 0
                        secondsSpinBox.value = 0
                    }
                }
            }
        }
    }
    
    // Reset Data Confirmation Dialog
    Dialog {
        id: resetDataDialog
        title: "Reset All Data"
        anchors.centerIn: parent
        width: 400
        height: 200
        
        Column {
            anchors.fill: parent
            spacing: 20
            
            Text {
                text: "Are you sure you want to reset all data?"
                font.pixelSize: 16
                color: textColor
                wrapMode: Text.WordWrap
                width: parent.width
            }
            
            Text {
                text: "This will permanently delete:\n• All timers\n• All work sessions\n• All daily statistics\n\nThis action cannot be undone."
                font.pixelSize: 14
                color: dangerColor
                wrapMode: Text.WordWrap
                width: parent.width
            }
            
            Row {
                anchors.right: parent.right
                spacing: 10
                
                Button {
                    text: "Cancel"
                    background: Rectangle {
                        color: parent.pressed ? Qt.darker("#bdc3c7") : "#bdc3c7"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: resetDataDialog.close()
                }
                
                Button {
                    text: "Reset All Data"
                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(dangerColor) : dangerColor
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        timerManager.resetAllData()
                        resetDataDialog.close()
                    }
                }
            }
        }
    }
}