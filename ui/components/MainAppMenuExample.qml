import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * MainAppMenuExample - Shows how to add responsive menus to your main FatherTime UI
 * 
 * This demonstrates adding a main application menu bar and other responsive
 * popup menus throughout your application
 */
Item {
    id: mainMenuExample
    
    // Top Menu Bar with Responsive Menu
    Rectangle {
        id: topMenuBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(parent.height * 0.08, 50)
        color: window.primaryColor
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Math.max(parent.width * 0.02, 15)
            
            // App title
            Text {
                text: "Father Time"
                font.pixelSize: Math.max(parent.width * 0.015, 18)
                font.bold: true
                color: "white"
                Layout.fillWidth: true
            }
            
            // Main menu button
            Button {
                text: "☰ Menu"
                Layout.preferredWidth: Math.max(parent.width * 0.08, 80)
                Layout.preferredHeight: Math.max(parent.height * 0.7, 35)
                
                background: Rectangle {
                    color: parent.pressed ? Qt.darker("white", 1.2) : 
                           parent.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    radius: 6
                    border.color: "white"
                    border.width: 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: Math.max(parent.width * 0.15, 12)
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: mainAppMenu.openMenu()
            }
        }
    }
    
    // Main Application Menu
    ResponsivePopupMenu {
        id: mainAppMenu
        menuTitle: "Father Time"
        iconSource: "⏰"
        
        menuItems: [
            {
                title: "New Stopwatch Timer",
                subtitle: "Create a timer that tracks elapsed time",
                icon: "⏱️",
                trailing: "Ctrl+T"
            },
            {
                title: "New Countdown Timer",
                subtitle: "Create a timer that counts down from a set time",
                icon: "⏲️",
                trailing: "Ctrl+D"
            },
            {
                title: "Timer Management",
                subtitle: "",
                icon: "📋"
            },
            {
                title: "  View All Timers",
                subtitle: "See all your timers at once",
                icon: "👁️"
            },
            {
                title: "  Bulk Operations",
                subtitle: "Manage multiple timers",
                icon: "⚡"
            },
            {
                title: "Data & Export",
                subtitle: "",
                icon: "💾"
            },
            {
                title: "  Export Timer Data",
                subtitle: "Save your timer data to file",
                icon: "📤"
            },
            {
                title: "  Import Timer Data",
                subtitle: "Load timer data from file",
                icon: "📥"
            },
            {
                title: "  Reset All Data",
                subtitle: "Clear all timer data (dangerous!)",
                icon: "🗑️"
            },
            {
                title: "Settings",
                subtitle: "Configure application preferences and themes",
                icon: "⚙️",
                trailing: "Ctrl+,"
            },
            {
                title: "Help & About",
                subtitle: "Get help and view application information",
                icon: "ℹ️",
                trailing: "F1"
            }
        ]
        
        onItemSelected: function(index, item) {
            console.log("Main menu action:", item.title)
            
            // Route to existing dialog functions or create new ones
            switch(item.title) {
                case "New Stopwatch Timer":
                    // Trigger existing addTimerDialog if it exists
                    showMessage("Add Stopwatch", "Would open Add Stopwatch Timer dialog")
                    break
                case "New Countdown Timer":
                    // Trigger existing addCountdownDialog if it exists
                    showMessage("Add Countdown", "Would open Add Countdown Timer dialog")
                    break
                case "  Export Timer Data":
                    showMessage("Export Data", "Would trigger data export functionality")
                    break
                case "  Import Timer Data":
                    showMessage("Import Data", "Would trigger data import functionality")
                    break
                case "  Reset All Data":
                    // Trigger existing resetDataDialog if it exists
                    showMessage("Reset Data", "Would open Reset All Data dialog")
                    break
                case "Settings":
                    // Trigger existing settingsDialog if it exists
                    showMessage("Settings", "Would open Settings dialog")
                    break
                case "Help & About":
                    aboutDialog.open()
                    break
                default:
                    showMessage("Action", "Selected: " + item.title)
            }
        }
    }
    
    // Quick Actions Floating Menu (could be positioned anywhere)
    Rectangle {
        id: quickActionsButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Math.max(parent.width * 0.03, 20)
        
        width: Math.max(parent.width * 0.08, 60)
        height: width
        radius: width / 2
        color: window.accentColor
        
        // Simple shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            color: "#40000000"
            radius: parent.radius
            z: parent.z - 1
        }
        
        Text {
            anchors.centerIn: parent
            text: "+"
            font.pixelSize: Math.max(parent.width * 0.4, 24)
            font.bold: true
            color: "white"
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: quickActionsMenu.openMenu()
            cursorShape: Qt.PointingHandCursor
        }
        
        // Hover animation
        scale: quickActionsMouseArea.pressed ? 0.95 : 
               quickActionsMouseArea.containsMouse ? 1.05 : 1.0
        
        MouseArea {
            id: quickActionsMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: quickActionsMenu.openMenu()
        }
        
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }
    
    // Quick Actions Menu
    ResponsivePopupMenu {
        id: quickActionsMenu
        menuTitle: "Quick Actions"
        iconSource: "⚡"
        showCloseButton: false  // More minimal for quick actions
        
        menuItems: [
            {
                title: "Start All Timers",
                icon: "▶️"
            },
            {
                title: "Stop All Timers", 
                icon: "⏹️"
            },
            {
                title: "Add Quick Timer",
                icon: "⏱️"
            },
            {
                title: "Export Today's Data",
                icon: "📤"
            }
        ]
        
        onItemSelected: function(index, item) {
            showMessage("Quick Action", "Selected: " + item.title)
        }
    }
    
    // About Dialog (Enhanced)
    Dialog {
        id: aboutDialog
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.6, 400)
        height: Math.min(parent.height * 0.7, 500)
        modal: true
        
        title: "About Father Time"
        
        background: Rectangle {
            color: window.backgroundColor
            border.color: window.primaryColor
            border.width: 2
            radius: 12
        }
        
        contentItem: ColumnLayout {
            spacing: Math.max(aboutDialog.width * 0.04, 15)
            
            Image {
                source: "⏰"  // You could replace with actual logo
                Layout.preferredWidth: Math.max(aboutDialog.width * 0.2, 64)
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignHCenter
                fillMode: Image.PreserveAspectFit
            }
            
            Text {
                text: "Father Time"
                font.pixelSize: Math.max(aboutDialog.width * 0.06, 24)
                font.bold: true
                color: window.primaryColor
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            
            Text {
                text: "Professional Timer Application\nVersion 1.0"
                font.pixelSize: Math.max(aboutDialog.width * 0.035, 14)
                color: window.textColor
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: window.cardBorderColor
            }
            
            Text {
                text: "Features:\n• Stopwatch and countdown timers\n• Session tracking and statistics\n• Multiple themes\n• Data export and import\n• Responsive design"
                font.pixelSize: Math.max(aboutDialog.width * 0.03, 12)
                color: window.textColor
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            Item { Layout.fillHeight: true }
        }
        
        standardButtons: Dialog.Ok
    }
    
    // Feedback dialog (reusable)
    Dialog {
        id: feedbackDialog
        anchors.centerIn: parent
        modal: true
        
        property string messageTitle: ""
        property string messageText: ""
        
        title: messageTitle
        
        contentItem: Text {
            text: feedbackDialog.messageText
            font.pixelSize: 14
            color: window.textColor
            wrapMode: Text.WordWrap
            width: Math.min(300, parent.width * 0.8)
        }
        
        standardButtons: Dialog.Ok
    }
    
    function showMessage(title, text) {
        feedbackDialog.messageTitle = title
        feedbackDialog.messageText = text
        feedbackDialog.open()
    }
}