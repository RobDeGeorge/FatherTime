import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    width: 1200
    height: 700
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
    property color cardBackgroundColor: configManager.cardBackground
    property color cardBorderColor: configManager.cardBorder
    
    // Force refresh colors when theme changes
    Connections {
        target: themeManager
        function onThemeChanged() {
            // Force refresh of all color bindings
            primaryColor = configManager.primary
            secondaryColor = configManager.secondary
            accentColor = configManager.accent
            successColor = configManager.success
            dangerColor = configManager.danger
            warningColor = configManager.warning
            backgroundColor = configManager.background
            textColor = configManager.text
            cardBackgroundColor = configManager.cardBackground
            cardBorderColor = configManager.cardBorder
        }
    }
    
    // Theme cycling keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+Alt+Shift+T"
        onActivated: {
            themeManager.cycleTheme()
        }
    }
    
    Shortcut {
        sequence: "Ctrl+Alt+Shift+Y" 
        onActivated: {
            themeManager.cycleThemeBackward()
            console.log("Cycled backward to theme:", themeManager.getCurrentTheme())
        }
    }
    
    // Global dialog keyboard shortcuts
    Shortcut {
        sequence: "Escape"
        onActivated: {
            console.log("ESC pressed - checking dialogs...")
            if (addTimerDialog.visible) {
                console.log("Closing addTimerDialog")
                addTimerDialog.close()
                addTimerDialog.timerNameField.text = ""
                restoreFocus()
            } else if (addCountdownDialog.visible) {
                console.log("Closing addCountdownDialog")
                addCountdownDialog.close()
                addCountdownDialog.countdownNameField.text = ""
                addCountdownDialog.hoursSpinBox.value = 0
                addCountdownDialog.minutesSpinBox.value = 0
                addCountdownDialog.secondsSpinBox.value = 0
            } else if (renameTimerDialog.visible) {
                console.log("Closing renameTimerDialog")
                renameTimerDialog.close()
                renameTimerDialog.renameTextField.text = ""
                restoreFocus()
            } else if (resetDataDialog.visible) {
                console.log("Closing resetDataDialog")
                resetDataDialog.confirmationSlider.value = 0
                resetDataDialog.close()
            } else if (settingsDialog.visible) {
                console.log("Closing settingsDialog")
                settingsDialog.close()
                restoreFocus()
            }
        }
    }
    
    Shortcut {
        sequence: "Ctrl+Return"
        onActivated: handleEnterPressed()
    }
    
    Shortcut {
        sequence: "Alt+Return"
        onActivated: handleEnterPressed()
    }
    
    function handleEnterPressed() {
        console.log("ENTER pressed - checking dialogs...")
        if (addTimerDialog.visible) {
            console.log("Creating timer from addTimerDialog")
            var timerName = addTimerDialog.timerNameField.text.trim() || "Timer"
            timerManager.addTimer(timerName, "stopwatch")
            addTimerDialog.close()
            addTimerDialog.timerNameField.text = ""
            restoreFocus()
        } else if (addCountdownDialog.visible) {
            console.log("Creating countdown from addCountdownDialog")
            var countdownName = addCountdownDialog.countdownNameField.text.trim() || "Countdown"
            var totalSeconds = addCountdownDialog.hoursSpinBox.value * 3600 + addCountdownDialog.minutesSpinBox.value * 60 + addCountdownDialog.secondsSpinBox.value
            if (totalSeconds > 0) {
                timerManager.addTimer(countdownName, "countdown")
                var newTimer = timerManager.timers[timerManager.timers.length - 1]
                timerManager.setCountdownTime(newTimer.id, totalSeconds)
                addCountdownDialog.close()
                addCountdownDialog.countdownNameField.text = ""
                addCountdownDialog.hoursSpinBox.value = 0
                addCountdownDialog.minutesSpinBox.value = 0
                addCountdownDialog.secondsSpinBox.value = 0
            }
        } else if (renameTimerDialog.visible && renameTimerDialog.currentTimer) {
            console.log("Renaming timer from renameTimerDialog")
            var newName = renameTimerDialog.renameTextField.text.trim()
            if (newName !== "") {
                timerManager.renameTimer(renameTimerDialog.currentTimer.id, newName)
                renameTimerDialog.close()
                renameTimerDialog.renameTextField.text = ""
                restoreFocus()
            }
        } else if (resetDataDialog.visible) {
            console.log("Checking reset confirmation...")
            if (resetDataDialog.confirmationSlider.value >= 95) {
                console.log("Resetting all data")
                timerManager.resetAllData()
                resetDataDialog.confirmationSlider.value = 0
                resetDataDialog.close()
            }
        } else if (settingsDialog.visible) {
            console.log("Closing settingsDialog")
            settingsDialog.close()
            restoreFocus()
        }
    }
    
    // Navigation properties
    property date currentDate: new Date()
    property int currentMonth: currentDate.getMonth()
    property int currentYear: currentDate.getFullYear()
    property string selectedDateForTimers: new Date().toISOString().split('T')[0]
    property int selectedCellIndex: -1
    property bool navigating: false
    
    // Timer selection properties
    property int selectedTimerIndex: -1
    property var selectedTimerItem: {
        if (selectedTimerIndex >= 0 && timerManager.timers && selectedTimerIndex < timerManager.timers.length) {
            return timerManager.timers[selectedTimerIndex]
        }
        return null
    }
    
    property Timer navigationTimer: Timer {
        id: navigationTimer
        interval: 50
        onTriggered: navigating = false
    }
    
    // Function to get timers for a specific date
    function getTimersForDate(dateString) {
        // For now, return all timers. In future, this could filter by creation date
        return timerManager.timers
    }
    
    // Function to calculate total time for selected date from currently loaded timers
    function getTotalTimeForCurrentDate() {
        let totalSeconds = 0
        
        // Add up elapsed seconds from all stopwatch timers currently loaded for this date
        for (let i = 0; i < timerManager.timers.length; i++) {
            let timer = timerManager.timers[i]
            if (timer.type === "stopwatch") {
                totalSeconds += timer.elapsedSeconds
            }
        }
        
        let hours = Math.floor(totalSeconds / 3600)
        let minutes = Math.floor((totalSeconds % 3600) / 60)
        let seconds = totalSeconds % 60
        
        if (hours > 0) {
            if (minutes > 0) {
                return hours + "h " + minutes + "m"
            } else {
                return hours + "h"
            }
        } else if (minutes > 0) {
            return minutes + "m"
        } else if (seconds > 0) {
            return seconds + "s"
        } else {
            return "0s"
        }
    }
    
    // Navigation functions
    function navigateGrid(direction) {
        if (navigating) return
        navigating = true
        navigationTimer.restart()
        
        if (selectedCellIndex === -1) {
            initializeSelection()
            return
        }
        
        var cols = 7
        var currentRow = Math.floor(selectedCellIndex / cols)
        var currentCol = selectedCellIndex % cols
        var newRow = currentRow
        var newCol = currentCol
        
        switch (direction) {
            case "up":
                newRow = (currentRow - 1 + 6) % 6
                break
            case "down":
                newRow = (currentRow + 1) % 6
                break
            case "left":
                newCol = (currentCol - 1 + cols) % cols
                break
            case "right":
                newCol = (currentCol + 1) % cols
                break
        }
        
        var newIndex = newRow * cols + newCol
        selectedCellIndex = newIndex
        updateSelectedDateFromIndex()
    }
    
    function initializeSelection() {
        let today = new Date()
        let firstDay = new Date(currentYear, currentMonth, 1) 
        let startDay = firstDay.getDay()
        
        if (today.getMonth() === currentMonth && today.getFullYear() === currentYear) {
            selectedCellIndex = startDay + today.getDate() - 1
        } else {
            selectedCellIndex = startDay
        }
        updateSelectedDateFromIndex()
    }
    
    function updateSelectedDateFromIndex() {
        if (selectedCellIndex >= 0) {
            var cellDate = getCellDateFromIndex(selectedCellIndex)
            if (cellDate) {
                selectedDateForTimers = cellDate.toISOString().split('T')[0]
                // Notify timer manager of date change
                timerManager.set_current_date(selectedDateForTimers)
            }
        }
    }
    
    function getCellDateFromIndex(index) {
        let firstDay = new Date(currentYear, currentMonth, 1)
        let startDay = firstDay.getDay()
        let dayOffset = index - startDay
        return new Date(currentYear, currentMonth, 1 + dayOffset)
    }
    
    function navigateToToday() {
        let today = new Date()
        currentDate = today
        currentMonth = today.getMonth()
        currentYear = today.getFullYear()
        initializeSelection()
    }
    
    // Function to restore focus for arrow key navigation
    function restoreFocus() {
        keyHandler.forceActiveFocus()
    }

    // Initialize timer manager with today's date on startup
    Component.onCompleted: {
        let today = new Date()
        selectedDateForTimers = today.toISOString().split('T')[0]
        timerManager.set_current_date(selectedDateForTimers)
        initializeSelection()
        restoreFocus() // Ensure initial focus
    }

    FocusScope {
        id: keyHandler
        anchors.fill: parent
        focus: true
        
        // Global shortcuts that work regardless of focus
        Shortcut {
            sequence: "Up"
            onActivated: navigateGrid("up")
        }
        Shortcut {
            sequence: "Down" 
            onActivated: navigateGrid("down")
        }
        Shortcut {
            sequence: "Left"
            onActivated: navigateGrid("left")
        }
        Shortcut {
            sequence: "Right"
            onActivated: navigateGrid("right")
        }
        Shortcut {
            sequence: "Home"
            onActivated: navigateToToday()
        }
        Shortcut {
            sequence: "Space"
            onActivated: navigateToToday()
        }
        Shortcut {
            sequence: "F2"
            onActivated: {
                if (selectedTimerItem) {
                    renameTimerDialog.openForTimer(selectedTimerItem)
                } else if (timerManager.timers.length > 0) {
                    // If no timer selected, use the first timer directly
                    var firstTimer = timerManager.timers[0]
                    renameTimerDialog.openForTimer(firstTimer)
                }
            }
        }
        
        Rectangle {
            anchors.fill: parent
            color: backgroundColor
        
            ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            
            // Top Half - Timers Section
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: parent.height * 0.6
                color: "transparent"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 15
                        
                        // Header
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 90
                            color: primaryColor
                            radius: 8
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 15
                                
                                Column {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Text {
                                        text: {
                                            if (selectedCellIndex >= 0) {
                                                var cellDate = getCellDateFromIndex(selectedCellIndex)
                                                if (cellDate) {
                                                    let today = new Date()
                                                    let isToday = cellDate.toDateString() === today.toDateString()
                                                    if (isToday) {
                                                        return "Today's Timers"
                                                    } else {
                                                        return cellDate.toLocaleDateString('en-US', { 
                                                            weekday: 'short',
                                                            month: 'short', 
                                                            day: 'numeric' 
                                                        }) + " Timers"
                                                    }
                                                }
                                            }
                                            return "Select a date to view timers"
                                        }
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: backgroundColor
                                        opacity: 0.95
                                    }
                                    
                                    Text {
                                        text: "Total: " + getTotalTimeForCurrentDate()
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: backgroundColor
                                        opacity: 0.95
                                    }
                                }
                                
                                RowLayout {
                                    spacing: 10
                                    
                                    Button {
                                        text: "+ Stopwatch"
                                        font.pixelSize: 12
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 35
                                        background: Rectangle {
                                            color: parent.pressed ? Qt.darker(accentColor) : accentColor
                                            radius: 6
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: parent.font.pixelSize
                                        }
                                        onClicked: {
                                            addTimerDialog.open()
                                            restoreFocus()
                                        }
                                    }
                                    
                                    Button {
                                        text: "+ Countdown"
                                        font.pixelSize: 12
                                        Layout.preferredWidth: 100
                                        Layout.preferredHeight: 35
                                        background: Rectangle {
                                            color: parent.pressed ? Qt.darker(successColor) : successColor
                                            radius: 6
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: parent.font.pixelSize
                                        }
                                        onClicked: {
                                            addCountdownDialog.open()
                                            restoreFocus()
                                        }
                                    }
                                    
                                    Button {
                                        text: "Reset Data"
                                        font.pixelSize: 12
                                        Layout.preferredWidth: 90
                                        Layout.preferredHeight: 35
                                        visible: true
                                        background: Rectangle {
                                            color: parent.pressed ? Qt.darker(dangerColor) : dangerColor
                                            radius: 6
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: parent.font.pixelSize
                                        }
                                        onClicked: {
                                            resetDataDialog.open()
                                            restoreFocus()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Timers List with drag and drop
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 200
                            clip: true
                            
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            
                            ListView {
                                id: timersListView
                                model: timerManager.timers
                                spacing: 10
                                boundsBehavior: Flickable.StopAtBounds
                                
                                delegate: TimerCard {
                                    width: timersListView.width
                                    timerItem: modelData
                                    isSelected: selectedTimerIndex === index
                                    onDeleteTimer: timerManager.deleteTimer(timerItem.id)
                                    onStartTimer: timerManager.startTimer(timerItem.id)
                                    onStopTimer: timerManager.stopTimer(timerItem.id)
                                    onResetTimer: timerManager.resetTimer(timerItem.id)
                                    onAdjustTime: timerManager.adjustTime(timerItem.id, seconds)
                                    onSetCountdown: timerManager.setCountdownTime(timerItem.id, seconds)
                                    onToggleFavorite: timerManager.toggleTimerFavorite(timerItem.id)
                                    onSelectTimer: {
                                        selectedTimerIndex = index
                                        restoreFocus()
                                    }
                                }
                            }
                        }
                        
                        // Empty state
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            visible: timersListView.count === 0
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 15
                                
                                Text {
                                    text: "No timers yet"
                                    font.pixelSize: 20
                                    color: textColor
                                    opacity: 0.6
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Text {
                                    text: "Click the + buttons above to create your first timer"
                                    font.pixelSize: 14
                                    color: textColor
                                    opacity: 0.4
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
                
            // Bottom Half - Calendar Section
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: parent.height * 0.4
                color: primaryColor
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    // Header with month navigation
                    RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: Qt.formatDate(currentDate, "MMMM yyyy")
                                font.pixelSize: 16
                                font.bold: true
                                color: "white"
                                Layout.fillWidth: true
                            }
                            
                            RowLayout {
                                spacing: 8
                                
                                Button {
                                    text: "◀"
                                    width: 25
                                    height: 25
                                    background: Rectangle {
                                        color: parent.pressed ? Qt.darker("white", 1.2) : "white"
                                        radius: 4
                                        opacity: 0.9
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: primaryColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 10
                                    }
                                    onClicked: {
                                        if (currentMonth === 0) {
                                            currentMonth = 11
                                            currentYear--
                                        } else {
                                            currentMonth--
                                        }
                                        currentDate = new Date(currentYear, currentMonth, 1)
                                        selectedCellIndex = -1
                                        // Update selected date and timer manager
                                        if (selectedCellIndex >= 0) {
                                            updateSelectedDateFromIndex()
                                        }
                                        restoreFocus()
                                    }
                                }
                                
                                Button {
                                    text: "▶"
                                    width: 25
                                    height: 25
                                    background: Rectangle {
                                        color: parent.pressed ? Qt.darker("white", 1.2) : "white"
                                        radius: 4
                                        opacity: 0.9
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: primaryColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 10
                                    }
                                    onClicked: {
                                        if (currentMonth === 11) {
                                            currentMonth = 0
                                            currentYear++
                                        } else {
                                            currentMonth++
                                        }
                                        currentDate = new Date(currentYear, currentMonth, 1)
                                        selectedCellIndex = -1
                                        // Update selected date and timer manager
                                        if (selectedCellIndex >= 0) {
                                            updateSelectedDateFromIndex()
                                        }
                                        restoreFocus()
                                    }
                                }
                                
                                Button {
                                    text: "Today"
                                    font.pixelSize: 10
                                    background: Rectangle {
                                        color: parent.pressed ? Qt.darker(accentColor) : accentColor
                                        radius: 4
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: parent.font.pixelSize
                                    }
                                    onClicked: {
                                        navigateToToday()
                                        restoreFocus()
                                    }
                                }
                            }
                        }
                        
                        // Calendar Grid
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: backgroundColor
                            border.color: primaryColor
                            border.width: 1
                            radius: 6
                            
                            GridLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                columns: 7
                                rows: 7
                                columnSpacing: 1
                                rowSpacing: 1
                                
                                // Day headers
                                Repeater {
                                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 20
                                        color: primaryColor
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.pixelSize: 9
                                            font.bold: true
                                            color: backgroundColor
                                        }
                                    }
                                }
                                
                                // Calendar days
                                Repeater {
                                    model: 42 // 6 weeks * 7 days
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        
                                        property date cellDate: {
                                            let firstDay = new Date(currentYear, currentMonth, 1)
                                            let startDay = firstDay.getDay()
                                            let dayOffset = index - startDay
                                            return new Date(currentYear, currentMonth, 1 + dayOffset)
                                        }
                                        
                                        property bool isCurrentMonth: {
                                            return cellDate.getMonth() === currentMonth && cellDate.getFullYear() === currentYear
                                        }
                                        
                                        property bool isToday: {
                                            if (!isCurrentMonth) return false
                                            let today = new Date()
                                            return cellDate.toDateString() === today.toDateString()
                                        }
                                        
                                        property bool isSelected: {
                                            return index === selectedCellIndex
                                        }
                                        
                                        property string dateString: {
                                            return cellDate.toISOString().split('T')[0]
                                        }
                                        
                                        property var dayData: {
                                            if (!isCurrentMonth) return null
                                            for (let i = 0; i < timerManager.dailyBreakdown.length; i++) {
                                                let breakdown = timerManager.dailyBreakdown[i]
                                                if (breakdown.date === dateString) {
                                                    return breakdown
                                                }
                                            }
                                            return null
                                        }
                                        
                                        color: {
                                            if (!isCurrentMonth) return Qt.lighter(backgroundColor, 1.2)
                                            if (isSelected) return Qt.lighter(accentColor, 1.5)
                                            if (isToday) return successColor
                                            if (dayData && dayData.rawTotalHours > 0) {
                                                let hours = dayData.rawTotalHours
                                                if (hours >= 4) return Qt.lighter(accentColor, 1.8)
                                                if (hours >= 2) return Qt.lighter(warningColor, 1.8)
                                                return Qt.lighter(warningColor, 1.9)
                                            }
                                            return Qt.lighter(backgroundColor, 1.1)
                                        }
                                        
                                        border.color: isSelected ? accentColor : Qt.lighter(backgroundColor, 1.3)
                                        border.width: isSelected ? 2 : 1
                                        
                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 1
                                            
                                            Text {
                                                text: cellDate.getDate()
                                                font.pixelSize: 10
                                                font.bold: isToday || isSelected
                                                color: {
                                                    if (isToday) return backgroundColor
                                                    if (isSelected) return backgroundColor
                                                    if (isCurrentMonth) return textColor
                                                    return Qt.darker(textColor, 1.8)
                                                }
                                                opacity: isCurrentMonth ? 1.0 : 0.6
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                            
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if (parent.isCurrentMonth) {
                                                    selectedCellIndex = index
                                                    updateSelectedDateFromIndex()
                                                } else {
                                                    currentMonth = parent.cellDate.getMonth()
                                                    currentYear = parent.cellDate.getFullYear()
                                                    currentDate = new Date(currentYear, currentMonth, 1)
                                                    selectedCellIndex = -1
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
    
    // Responsive dialogs with modern design
    AddTimerDialogResponsive {
        id: addTimerDialog
    }
    AddCountdownDialogResponsive {
        id: addCountdownDialog
    }
    
    ResetDataDialogResponsive {
        id: resetDataDialog
    }
    
    // Settings button in top right corner
    Button {
        id: settingsButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 10
        width: 32
        height: 32
        z: 100  // High z-order to appear above other content
        
        background: Rectangle {
            color: parent.pressed ? Qt.darker(primaryColor, 1.2) : primaryColor
            radius: 4
            border.color: backgroundColor
            border.width: 1
            opacity: 0.9
        }
        
        contentItem: Text {
            text: "⚙"
            color: backgroundColor
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: {
            settingsDialog.open()
            restoreFocus()
        }
        
        // Tooltip-like behavior
        ToolTip.text: "Settings"
        ToolTip.visible: hovered
        ToolTip.delay: 500
    }
    
    // Rename Timer Dialog
    RenameTimerDialogResponsive {
        id: renameTimerDialog
    }
    
    // Settings Dialog
    SettingsDialogResponsive {
        id: settingsDialog
    }
}