import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * PopupMenuDemo - Demonstrates ResponsivePopupMenu usage patterns
 * 
 * This demo shows various popup menu configurations and test scenarios
 * for different screen sizes and content types.
 */
ApplicationWindow {
    id: demoWindow
    width: 1200
    height: 800
    visible: true
    title: "Responsive Popup Menu Demo"
    
    // Test different screen sizes
    property var testSizes: [
        { width: 360, height: 640, name: "Mobile Portrait" },
        { width: 640, height: 360, name: "Mobile Landscape" },
        { width: 768, height: 1024, name: "Tablet Portrait" },
        { width: 1024, height: 768, name: "Tablet Landscape" },
        { width: 1200, height: 800, name: "Desktop Small" },
        { width: 1920, height: 1080, name: "Desktop Large" }
    ]
    
    // Sample menu data for different scenarios
    property var simpleMenuItems: [
        { title: "New Document", icon: "📄", trailing: "Ctrl+N" },
        { title: "Open", icon: "📁", trailing: "Ctrl+O" },
        { title: "Save", icon: "💾", trailing: "Ctrl+S" },
        { title: "Save As...", icon: "💾", trailing: "Ctrl+Shift+S" },
        { title: "Print", icon: "🖨️", trailing: "Ctrl+P" },
        { title: "Exit", icon: "🚪", trailing: "Alt+F4" }
    ]
    
    property var detailedMenuItems: [
        { 
            title: "Profile Settings", 
            subtitle: "Manage your account and preferences",
            icon: "👤" 
        },
        { 
            title: "Privacy & Security", 
            subtitle: "Control your privacy settings and security options",
            icon: "🔒" 
        },
        { 
            title: "Notifications", 
            subtitle: "Configure how and when you receive notifications",
            icon: "🔔" 
        },
        { 
            title: "Appearance", 
            subtitle: "Customize themes, colors, and display options",
            icon: "🎨" 
        },
        { 
            title: "Advanced", 
            subtitle: "Advanced settings and developer options",
            icon: "⚙️" 
        }
    ]
    
    property var longMenuItems: [
        { title: "Very Long Menu Item Name That Might Wrap", subtitle: "This demonstrates text wrapping behavior" },
        { title: "Short Item", subtitle: "Brief description" },
        { title: "Another Extremely Long Menu Item That Tests Ellipsis", subtitle: "Testing ellipsis and text handling in constrained spaces" },
        { title: "Medium Length Item", subtitle: "Medium length subtitle that provides context" },
        { title: "Final Item", subtitle: "Last item in the list" }
    ]
    
    background: Rectangle {
        color: "#F5F5F5"
        
        // Subtle gradient
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#F8F8F8" }
            GradientStop { position: 1.0; color: "#F0F0F0" }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Title
        Text {
            text: "Responsive Popup Menu System Demo"
            font.pixelSize: 24
            font.weight: Font.Bold
            color: "#1F1F1F"
            Layout.alignment: Qt.AlignHCenter
        }
        
        // Size controls
        GroupBox {
            title: "Window Size Testing"
            Layout.fillWidth: true
            
            RowLayout {
                anchors.fill: parent
                spacing: 10
                
                Repeater {
                    model: demoWindow.testSizes
                    
                    Button {
                        text: modelData.name + "\n" + modelData.width + "×" + modelData.height
                        
                        onClicked: {
                            demoWindow.width = modelData.width
                            demoWindow.height = modelData.height
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#E0E0E0" : 
                                   parent.hovered ? "#F0F0F0" : "#FFFFFF"
                            border.color: "#D0D0D0"
                            border.width: 1
                            radius: 6
                        }
                    }
                }
            }
        }
        
        // Menu demo buttons
        GroupBox {
            title: "Menu Variations"
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            GridLayout {
                anchors.fill: parent
                columns: 3
                columnSpacing: 20
                rowSpacing: 20
                
                // Simple menu
                Button {
                    text: "Simple Menu\n(File Operations)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    onClicked: simpleMenu.openMenu()
                    
                    background: Rectangle {
                        color: parent.pressed ? "#0066CC" : 
                               parent.hovered ? "#0078D4" : "#0066CC"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
                
                // Detailed menu
                Button {
                    text: "Detailed Menu\n(Settings)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    onClicked: detailedMenu.openMenu()
                    
                    background: Rectangle {
                        color: parent.pressed ? "#8B5A2B" : 
                               parent.hovered ? "#A0522D" : "#8B4513"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
                
                // Long text menu
                Button {
                    text: "Long Text Menu\n(Text Handling)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    onClicked: longTextMenu.openMenu()
                    
                    background: Rectangle {
                        color: parent.pressed ? "#2E7D32" : 
                               parent.hovered ? "#388E3C" : "#4CAF50"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
                
                // Dynamic menu
                Button {
                    text: "Dynamic Menu\n(Runtime Changes)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    onClicked: {
                        // Generate dynamic content
                        var dynamicItems = []
                        for (var i = 0; i < Math.floor(Math.random() * 10) + 3; i++) {
                            dynamicItems.push({
                                title: "Dynamic Item " + (i + 1),
                                subtitle: "Generated at " + new Date().toLocaleTimeString(),
                                icon: ["🎲", "⭐", "🎯", "🎪", "🎨"][i % 5]
                            })
                        }
                        dynamicMenu.menuItems = dynamicItems
                        dynamicMenu.openMenu()
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#6A1B9A" : 
                               parent.hovered ? "#7B1FA2" : "#9C27B0"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
                
                // No icon menu
                Button {
                    text: "Text-Only Menu\n(No Icons)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    onClicked: textOnlyMenu.openMenu()
                    
                    background: Rectangle {
                        color: parent.pressed ? "#D84315" : 
                               parent.hovered ? "#F4511E" : "#FF5722"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
                
                // Minimal menu
                Button {
                    text: "Minimal Menu\n(Essential Only)"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    
                    onClicked: minimalMenu.openMenu()
                    
                    background: Rectangle {
                        color: parent.pressed ? "#424242" : 
                               parent.hovered ? "#616161" : "#757575"
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
        
        // Instructions
        Text {
            text: "• Try different window sizes to test responsive behavior\n" +
                  "• Use keyboard navigation (↑/↓ arrows, Enter, Escape)\n" +
                  "• Click outside menus or press Escape to close\n" +
                  "• Observe how menus adapt to content and screen size"
            font.pixelSize: 12
            color: "#666666"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
    
    // === POPUP MENU INSTANCES ===
    
    ResponsivePopupMenu {
        id: simpleMenu
        menuTitle: "File"
        menuItems: demoWindow.simpleMenuItems
        iconSource: "📁"
        
        onItemSelected: {
            console.log("Selected:", item.title)
            resultDialog.showResult("File Menu", "Selected: " + item.title)
        }
    }
    
    ResponsivePopupMenu {
        id: detailedMenu
        menuTitle: "Settings"
        menuItems: demoWindow.detailedMenuItems
        iconSource: "⚙️"
        
        onItemSelected: {
            console.log("Selected:", item.title)
            resultDialog.showResult("Settings Menu", "Selected: " + item.title)
        }
    }
    
    ResponsivePopupMenu {
        id: longTextMenu
        menuTitle: "Text Handling Demo"
        menuItems: demoWindow.longMenuItems
        iconSource: "📝"
        
        onItemSelected: {
            console.log("Selected:", item.title)
            resultDialog.showResult("Text Menu", "Selected: " + item.title)
        }
    }
    
    ResponsivePopupMenu {
        id: dynamicMenu
        menuTitle: "Dynamic Content"
        iconSource: "🎲"
        
        onItemSelected: {
            console.log("Selected:", item.title)
            resultDialog.showResult("Dynamic Menu", "Selected: " + item.title)
        }
    }
    
    ResponsivePopupMenu {
        id: textOnlyMenu
        menuTitle: "Text Only"
        menuItems: [
            { title: "Simple Text Item" },
            { title: "Another Text Item" },
            { title: "Third Text Item" },
            { title: "Final Text Item" }
        ]
        
        onItemSelected: {
            console.log("Selected:", item.title)
            resultDialog.showResult("Text-Only Menu", "Selected: " + item.title)
        }
    }
    
    ResponsivePopupMenu {
        id: minimalMenu
        menuTitle: "Quick Actions"
        showCloseButton: false
        menuItems: [
            { title: "Copy" },
            { title: "Paste" },
            { title: "Delete" }
        ]
        
        onItemSelected: {
            console.log("Selected:", item.title)
            resultDialog.showResult("Minimal Menu", "Selected: " + item.title)
        }
    }
    
    // Result feedback dialog
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
            color: "#1F1F1F"
            wrapMode: Text.WordWrap
        }
        
        standardButtons: Dialog.Ok
    }
}

// Import statement for the ResponsivePopupMenu component
// Note: Ensure ResponsivePopupMenu.qml is in the same directory or properly imported