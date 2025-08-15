import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * TimerCardWithMenu - Enhanced TimerCard using ResponsivePopupMenu
 * 
 * Replaces the cluttered horizontal button layout with a clean,
 * responsive popup menu that scales properly and provides better UX
 */
Rectangle {
    id: root
    height: Math.max(window.height * 0.12, 80)  // Responsive height
    color: configManager.cardBackground
    radius: Math.max(width * 0.01, 8)  // Proportional radius
    border.color: isSelected ? accentColor : configManager.cardBorder
    border.width: isSelected ? 2 : 1
    
    property var timerItem
    property bool isSelected: false
    property color primaryColor: configManager.primary
    property color accentColor: configManager.accent
    property color successColor: configManager.success
    property color dangerColor: configManager.danger
    property color warningColor: configManager.warning
    
    // Signals (same as original)
    signal deleteTimer()
    signal startTimer()
    signal stopTimer()
    signal resetTimer()
    signal adjustTime(int seconds)
    signal setCountdown(int seconds)
    signal toggleFavorite()
    signal selectTimer()
    signal renameTimer()  // New signal for rename functionality
    
    // Smooth transitions
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: Math.max(width * 0.015, 12)  // Responsive margins
        spacing: Math.max(width * 0.02, 15)  // Responsive spacing
        
        // Timer Info Section (Enhanced)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Math.max(height * 0.06, 5)
            
            // Timer name, type, and favorite
            RowLayout {
                spacing: Math.max(width * 0.01, 8)
                
                Text {
                    text: timerItem ? timerItem.name : ""
                    font.pixelSize: Math.max(root.width * 0.015, 16)  // Responsive font
                    font.bold: true
                    color: primaryColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    
                    // Make name clickable for selection
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectTimer()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                
                // Type badge
                Rectangle {
                    width: Math.max(root.width * 0.08, 70)
                    height: Math.max(root.height * 0.2, 18)
                    radius: height / 2
                    color: timerItem && timerItem.type === "countdown" ? successColor : accentColor
                    
                    Text {
                        anchors.centerIn: parent
                        text: timerItem && timerItem.type === "countdown" ? "Countdown" : "Stopwatch"
                        color: "white"
                        font.pixelSize: Math.max(parent.width * 0.11, 8)
                        font.bold: true
                    }
                }
                
                // Favorite star (simplified)
                Button {
                    Layout.preferredWidth: Math.max(root.width * 0.035, 28)
                    Layout.preferredHeight: Layout.preferredWidth
                    
                    background: Rectangle {
                        radius: parent.width / 2
                        color: "transparent"
                        border.color: timerItem && timerItem.isFavorite ? warningColor : "#bdc3c7"
                        border.width: 1
                        
                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    contentItem: Text {
                        text: "★"
                        color: timerItem && timerItem.isFavorite ? warningColor : "#bdc3c7"
                        font.pixelSize: Math.max(parent.width * 0.5, 12)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    onClicked: toggleFavorite()
                    
                    ToolTip.visible: hovered
                    ToolTip.text: timerItem && timerItem.isFavorite ? "Remove from favorites" : "Add to favorites"
                }
            }
            
            // Display time and status (Enhanced)
            RowLayout {
                spacing: Math.max(width * 0.015, 10)
                
                Text {
                    text: timerItem ? timerItem.displayTime : "00:00:00"
                    font.pixelSize: Math.max(root.width * 0.022, 24)  // Responsive font
                    font.bold: true
                    color: timerItem && timerItem.isRunning ? successColor : primaryColor
                    font.family: "monospace"
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                Rectangle {
                    width: Math.max(root.width * 0.08, 60)
                    height: Math.max(root.height * 0.15, 16)
                    radius: height / 2
                    color: timerItem && timerItem.isRunning ? successColor : "#7f8c8d"
                    opacity: 0.8
                    
                    Text {
                        anchors.centerIn: parent
                        text: timerItem && timerItem.isRunning ? "Running" : "Stopped"
                        font.pixelSize: Math.max(parent.width * 0.12, 9)
                        color: "white"
                        font.bold: true
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
        }
        
        // Primary Action Buttons (Clean and Minimal)
        RowLayout {
            spacing: Math.max(root.width * 0.01, 8)
            
            // Main Start/Stop Button
            Button {
                Layout.preferredWidth: Math.max(root.width * 0.08, 60)
                Layout.preferredHeight: Math.max(root.height * 0.4, 32)
                
                text: timerItem && timerItem.isRunning ? "Stop" : "Start"
                
                background: Rectangle {
                    color: {
                        if (!parent.enabled) return "#bdc3c7"
                        if (parent.pressed) return Qt.darker(timerItem && timerItem.isRunning ? dangerColor : successColor, 1.1)
                        if (parent.hovered) return Qt.lighter(timerItem && timerItem.isRunning ? dangerColor : successColor, 1.1)
                        return timerItem && timerItem.isRunning ? dangerColor : successColor
                    }
                    radius: Math.max(parent.width * 0.1, 6)
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Math.max(parent.width * 0.18, 10)
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
            
            // Actions Menu Button (Replaces all the individual buttons)
            Button {
                Layout.preferredWidth: Math.max(root.width * 0.06, 40)
                Layout.preferredHeight: Math.max(root.height * 0.4, 32)
                
                text: "⋯"  // Three dots menu indicator
                
                background: Rectangle {
                    color: {
                        if (parent.pressed) return Qt.darker(primaryColor, 1.1)
                        if (parent.hovered) return Qt.lighter(primaryColor, 1.1)
                        return primaryColor
                    }
                    radius: Math.max(parent.width * 0.15, 6)
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Math.max(parent.width * 0.4, 14)
                    font.bold: true
                }
                
                onClicked: timerActionsMenu.openMenu()
                
                ToolTip.visible: hovered
                ToolTip.text: "Timer actions"
            }
        }
    }
    
    // Mouse area for timer selection (same z-order handling)
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: selectTimer()
        
        // Add right-click context menu
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                timerActionsMenu.openMenu()
            } else {
                selectTimer()
            }
        }
    }
    
    // Enhanced Actions Menu using ResponsivePopupMenu
    ResponsivePopupMenu {
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
                    icon: timerItem.isRunning ? "⏹️" : "▶️",
                    trailing: "Space"
                })
                
                items.push({
                    title: "Reset Timer",
                    subtitle: "Reset timer to zero",
                    icon: "🔄",
                    trailing: "R"
                })
                
                // Time adjustments (only show if not running)
                if (!timerItem.isRunning) {
                    items.push({
                        title: "Quick Adjustments",
                        subtitle: "",
                        icon: "⏱️"
                    })
                    items.push({
                        title: "  -1 Hour",
                        subtitle: "Subtract one hour",
                        icon: "⬇️"
                    })
                    items.push({
                        title: "  -1 Minute", 
                        subtitle: "Subtract one minute",
                        icon: "⬇️"
                    })
                    items.push({
                        title: "  +1 Minute",
                        subtitle: "Add one minute", 
                        icon: "⬆️"
                    })
                    items.push({
                        title: "  +1 Hour",
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
        
        onItemSelected: function(index, item) {
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
                case "  -1 Hour":
                    adjustTime(-3600)
                    break
                case "  -1 Minute":
                    adjustTime(-60)
                    break
                case "  +1 Minute":
                    adjustTime(60)
                    break
                case "  +1 Hour":
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
    
    // Subtle shadow effect (enhanced)
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1
        anchors.leftMargin: 1
        radius: parent.radius
        color: "#000000"
        opacity: root.isSelected ? 0.1 : 0.05
        z: parent.z - 1
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }
}