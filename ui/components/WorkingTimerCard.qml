import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * WorkingTimerCard - Enhanced TimerCard with SimplePopupMenu
 * A working version that replaces the crowded button layout
 */
Rectangle {
    id: root
    height: 100
    color: window.cardBackgroundColor
    radius: 8
    border.color: isSelected ? window.accentColor : window.cardBorderColor
    border.width: isSelected ? 2 : 1
    
    property var timerItem
    property bool isSelected: false
    
    // Signals (same as original TimerCard)
    signal deleteTimer()
    signal startTimer()
    signal stopTimer()
    signal resetTimer()
    signal adjustTime(int seconds)
    signal setCountdown(int seconds)
    signal toggleFavorite()
    signal selectTimer()
    signal renameTimer()  // New signal for rename functionality
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 15
        
        // Timer Info Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            
            // Timer name, type, and favorite
            RowLayout {
                spacing: 8
                
                Text {
                    text: timerItem ? timerItem.name : ""
                    font.pixelSize: 16
                    font.bold: true
                    color: window.primaryColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                
                Rectangle {
                    width: 70
                    height: 18
                    radius: 9
                    color: timerItem && timerItem.type === "countdown" ? window.successColor : window.accentColor
                    
                    Text {
                        anchors.centerIn: parent
                        text: timerItem && timerItem.type === "countdown" ? "Countdown" : "Stopwatch"
                        color: "white"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }
                
                // Favorite star button
                Button {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    
                    background: Rectangle {
                        radius: 12
                        color: "transparent"
                        border.color: timerItem && timerItem.isFavorite ? window.warningColor : "#bdc3c7"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: "★"
                        color: timerItem && timerItem.isFavorite ? window.warningColor : "#bdc3c7"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: toggleFavorite()
                    
                    ToolTip.visible: hovered
                    ToolTip.text: timerItem && timerItem.isFavorite ? "Remove from favorites" : "Add to favorites"
                }
            }
            
            // Display time and status
            RowLayout {
                spacing: 10
                
                Text {
                    text: timerItem ? timerItem.displayTime : "00:00:00"
                    font.pixelSize: 24
                    font.bold: true
                    color: timerItem && timerItem.isRunning ? window.successColor : window.primaryColor
                    font.family: "monospace"
                }
                
                Text {
                    text: timerItem && timerItem.isRunning ? "Running..." : "Stopped"
                    font.pixelSize: 10
                    color: timerItem && timerItem.isRunning ? window.successColor : "#7f8c8d"
                    opacity: 0.8
                    Layout.fillWidth: true
                }
            }
        }
        
        // Clean Control Section - Just 2 buttons instead of 8+
        RowLayout {
            spacing: 8
            
            // Main Start/Stop Button
            Button {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 32
                text: timerItem && timerItem.isRunning ? "Stop" : "Start"
                
                background: Rectangle {
                    color: {
                        if (!parent.enabled) return "#bdc3c7"
                        if (parent.pressed) return Qt.darker(timerItem && timerItem.isRunning ? window.dangerColor : window.successColor)
                        return timerItem && timerItem.isRunning ? window.dangerColor : window.successColor
                    }
                    radius: 6
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 10
                    font.bold: true
                }
                
                onClicked: {
                    if (timerItem && timerItem.isRunning) {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }
            }
            
            // Actions Menu Button (replaces all the other buttons)
            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 32
                text: "⋯"  // Three dots menu
                
                background: Rectangle {
                    color: parent.pressed ? Qt.darker(window.primaryColor) : window.primaryColor
                    radius: 6
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                    font.bold: true
                }
                
                onClicked: timerActionsMenu.openMenu()
                
                ToolTip.visible: hovered
                ToolTip.text: "Timer actions"
            }
        }
    }
    
    // Mouse area for timer selection
    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                timerActionsMenu.openMenu()
            } else {
                selectTimer()
            }
        }
    }
    
    // Timer Actions Menu using SimplePopupMenu
    SimplePopupMenu {
        id: timerActionsMenu
        menuTitle: timerItem ? timerItem.name : "Timer Actions"
        iconSource: timerItem && timerItem.type === "countdown" ? "⏲️" : "⏱️"
        
        // Dynamic menu items based on timer state
        menuItems: {
            var items = []
            
            if (timerItem) {
                // Primary actions
                items.push({
                    title: timerItem.isRunning ? "Stop Timer" : "Start Timer",
                    subtitle: timerItem.isRunning ? "Stop the running timer" : "Start timing",
                    icon: timerItem.isRunning ? "⏹️" : "▶️"
                })
                
                items.push({
                    title: "Reset Timer",
                    subtitle: "Reset timer to zero",
                    icon: "🔄"
                })
                
                // Time adjustments (only show if not running)
                if (!timerItem.isRunning) {
                    items.push({
                        title: "-1 Hour",
                        subtitle: "Subtract one hour",
                        icon: "⬇️"
                    })
                    items.push({
                        title: "-1 Minute", 
                        subtitle: "Subtract one minute",
                        icon: "⬇️"
                    })
                    items.push({
                        title: "+1 Minute",
                        subtitle: "Add one minute", 
                        icon: "⬆️"
                    })
                    items.push({
                        title: "+1 Hour",
                        subtitle: "Add one hour",
                        icon: "⬆️"
                    })
                }
                
                // Management actions
                items.push({
                    title: "Rename Timer",
                    subtitle: "Change the timer name",
                    icon: "✏️"
                })
                
                items.push({
                    title: timerItem.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    subtitle: timerItem.isFavorite ? "Remove favorite status" : "Mark as favorite",
                    icon: timerItem.isFavorite ? "☆" : "★"
                })
                
                // Destructive action at bottom
                items.push({
                    title: "Delete Timer",
                    subtitle: "Permanently delete this timer",
                    icon: "🗑️"
                })
            }
            
            return items
        }
        
        onItemSelected: {
            console.log("Timer action selected:", item.title)
            
            // Handle the action based on the title
            switch(item.title) {
                case "Stop Timer":
                    stopTimer()
                    break
                case "Start Timer":
                    startTimer()
                    break
                case "Reset Timer":
                    resetTimer()
                    break
                case "-1 Hour":
                    adjustTime(-3600)
                    break
                case "-1 Minute":
                    adjustTime(-60)
                    break
                case "+1 Minute":
                    adjustTime(60)
                    break
                case "+1 Hour":
                    adjustTime(3600)
                    break
                case "Rename Timer":
                    renameTimer()
                    break
                case "Add to Favorites":
                case "Remove from Favorites":
                    toggleFavorite()
                    break
                case "Delete Timer":
                    deleteTimer()
                    break
            }
        }
    }
    
    // Subtle shadow effect
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1
        anchors.leftMargin: 1
        radius: parent.radius
        color: "#000000"
        opacity: 0.05
        z: parent.z - 1
    }
}