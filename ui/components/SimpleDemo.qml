import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "Simple Popup Menu Demo"
    
    property var sampleItems: [
        { title: "New Document", icon: "📄", trailing: "Ctrl+N" },
        { title: "Open File", icon: "📁", trailing: "Ctrl+O" },
        { title: "Save", icon: "💾", trailing: "Ctrl+S" },
        { title: "Print", icon: "🖨️", trailing: "Ctrl+P" },
        { title: "Exit", icon: "🚪", trailing: "Alt+F4" }
    ]
    
    property var detailedItems: [
        { 
            title: "User Settings", 
            subtitle: "Manage your account preferences",
            icon: "👤" 
        },
        { 
            title: "Privacy Controls", 
            subtitle: "Configure privacy and security options",
            icon: "🔒" 
        },
        { 
            title: "Notifications", 
            subtitle: "Set up notification preferences",
            icon: "🔔" 
        }
    ]
    
    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f0f0f0" }
            GradientStop { position: 1.0; color: "#e0e0e0" }
        }
    }
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "Simple Popup Menu Demo"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        
        Text {
            text: "Click the buttons below to test different menu configurations"
            font.pixelSize: 14
            color: "#666"
            Layout.alignment: Qt.AlignHCenter
        }
        
        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter
            
            Button {
                text: "File Menu"
                onClicked: fileMenu.openMenu()
                
                background: Rectangle {
                    color: parent.pressed ? "#0066CC" : "#0078D4"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "Settings Menu"
                onClicked: settingsMenu.openMenu()
                
                background: Rectangle {
                    color: parent.pressed ? "#2E7D32" : "#4CAF50"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "Simple Menu"
                onClicked: simpleMenu.openMenu()
                
                background: Rectangle {
                    color: parent.pressed ? "#6A1B9A" : "#9C27B0"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        Text {
            text: "• Try resizing the window to see responsive behavior\n• Use Escape to close menus\n• Click outside menus to close them"
            font.pixelSize: 12
            color: "#888"
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
    
    // Menu instances
    SimplePopupMenu {
        id: fileMenu
        menuTitle: "File"
        iconSource: "📁"
        menuItems: window.sampleItems
        
        onItemSelected: {
            resultDialog.showResult("File Menu", "Selected: " + item.title)
        }
    }
    
    SimplePopupMenu {
        id: settingsMenu
        menuTitle: "Settings"
        iconSource: "⚙️"
        menuItems: window.detailedItems
        
        onItemSelected: {
            resultDialog.showResult("Settings Menu", "Selected: " + item.title)
        }
    }
    
    SimplePopupMenu {
        id: simpleMenu
        menuTitle: "Quick Actions"
        showCloseButton: false
        menuItems: [
            { title: "Copy" },
            { title: "Paste" },
            { title: "Delete" }
        ]
        
        onItemSelected: {
            resultDialog.showResult("Quick Actions", "Selected: " + item.title)
        }
    }
    
    // Result dialog
    Dialog {
        id: resultDialog
        anchors.centerIn: parent
        modal: true
        
        property string resultTitle: ""
        property string resultText: ""
        
        function showResult(title, text) {
            resultTitle = title
            resultText = text
            open()
        }
        
        title: resultTitle
        
        contentItem: Text {
            text: resultDialog.resultText
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }
        
        standardButtons: Dialog.Ok
    }
}