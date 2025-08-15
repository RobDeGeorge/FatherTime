import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * ResponsiveMenuExample - Shows how to integrate ResponsivePopupMenu into FatherTime
 * This can be added to your main.qml or any other component
 */
Item {
    id: menuExample
    
    // Example menu button that could be added to your main UI
    Button {
        id: menuButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        
        text: "⚙ Actions"
        width: Math.max(parent.width * 0.1, 100)
        height: Math.max(parent.height * 0.06, 40)
        
        background: Rectangle {
            color: parent.pressed ? Qt.darker(window.primaryColor, 1.1) : window.primaryColor
            radius: 8
        }
        
        contentItem: Text {
            text: parent.text
            color: "white"
            font.pixelSize: Math.max(parent.width * 0.12, 12)
            font.weight: Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: actionsMenu.openMenu()
    }
    
    // Responsive popup menu integrated with FatherTime theme
    ResponsivePopupMenu {
        id: actionsMenu
        menuTitle: "Timer Actions"
        iconSource: "⚙️"
        
        // Example menu items that could be useful in FatherTime
        menuItems: [
            {
                title: "Add Stopwatch Timer",
                subtitle: "Create a new elapsed time tracker",
                icon: "⏱️",
                trailing: "Ctrl+T"
            },
            {
                title: "Add Countdown Timer", 
                subtitle: "Create a timer that counts down",
                icon: "⏲️",
                trailing: "Ctrl+D"
            },
            {
                title: "Export Data",
                subtitle: "Export timer data to file",
                icon: "📤"
            },
            {
                title: "Import Data",
                subtitle: "Import timer data from file", 
                icon: "📥"
            },
            {
                title: "Settings",
                subtitle: "Configure application preferences",
                icon: "⚙️",
                trailing: "Ctrl+,"
            },
            {
                title: "About",
                subtitle: "View application information",
                icon: "ℹ️"
            }
        ]
        
        // Handle menu selections
        onItemSelected: function(index, item) {
            console.log("Selected menu item:", item.title)
            
            // You can trigger existing dialog functions here
            switch(index) {
                case 0: // Add Stopwatch Timer
                    // If you have an addTimerDialog, you could call:
                    // addTimerDialog.open()
                    showMessage("Add Stopwatch Timer", "Would open Add Timer dialog")
                    break
                case 1: // Add Countdown Timer
                    // addCountdownDialog.open()
                    showMessage("Add Countdown Timer", "Would open Add Countdown dialog")
                    break
                case 2: // Export Data
                    showMessage("Export Data", "Would trigger data export")
                    break
                case 3: // Import Data
                    showMessage("Import Data", "Would trigger data import")
                    break
                case 4: // Settings
                    // settingsDialog.open()
                    showMessage("Settings", "Would open Settings dialog")
                    break
                case 5: // About
                    showMessage("About FatherTime", "Timer application v1.0")
                    break
            }
        }
        
        onMenuClosed: {
            console.log("Actions menu closed")
        }
    }
    
    // Simple feedback dialog (you can replace this with your existing dialogs)
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
            color: "#1F1F1F"
            wrapMode: Text.WordWrap
            width: Math.min(300, parent.width * 0.8)
        }
        
        standardButtons: Dialog.Ok
    }
    
    // Helper function to show messages
    function showMessage(title, text) {
        feedbackDialog.messageTitle = title
        feedbackDialog.messageText = text
        feedbackDialog.open()
    }
}