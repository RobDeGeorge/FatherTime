import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * SettingsDialogResponsive - Fully responsive settings dialog
 * 
 * Features:
 * - Responsive theme grid that adapts to screen size
 * - Modern card-based layout with proper visual hierarchy
 * - Touch-friendly theme selection chips
 * - Enhanced visual feedback and animations
 * - All original theme functionality preserved
 */
Dialog {
    id: root
    
    // === PROPER RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.9, 700)
    height: Math.min(parent.height * 0.9, 600)
    
    // Always center and stay within bounds
    anchors.centerIn: parent
    modal: true
    
    
    // === SMOOTH ANIMATIONS ===
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 250
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.95
                to: 1.0
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }
    
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 200
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.95
                duration: 200
                easing.type: Easing.InCubic
            }
        }
    }
    
    // === MODERN BACKGROUND STYLING ===
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.primaryColor
        border.width: 2
        radius: Math.max(root.baseWidth * 0.015, 12)
        
        // Simple shadow effect
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
                    text: "⚙️"
                    font.pixelSize: 20
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: "Settings"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.backgroundColor
                }
                
                Text {
                    text: "Customize your Father Time experience"
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
            console.log("Key pressed in SettingsDialog:", event.key)
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                console.log("ESC/ENTER in SettingsDialog")
                root.close()
                window.restoreFocus()
                event.accepted = true
            }
        }
    }

    // === SCROLLABLE CONTENT ===
    ScrollView {
        anchors.fill: parent
        anchors.margins: 25
        contentWidth: availableWidth
        
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        ColumnLayout {
            width: parent.width
            spacing: 24
            
            // === APPEARANCE SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 360
                color: window.cardBackgroundColor
                border.color: window.cardBorderColor
                border.width: 1
                radius: 12
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 25
                    spacing: 18
                    
                    // Section header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Rectangle {
                            width: 32
                            height: 32
                            color: Qt.rgba(window.primaryColor.r, window.primaryColor.g, window.primaryColor.b, 0.15)
                            radius: Math.max(width * 0.25, 8)
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🎨"
                                font.pixelSize: Math.max(parent.width * 0.5, 14)
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: "Appearance"
                                font.pixelSize: 16
                                font.bold: true
                                color: window.textColor
                            }
                            
                            Text {
                                text: "Customize the visual theme and colors - Quick cycling: Ctrl+Alt+Shift+T"
                                font.pixelSize: 11
                                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            }
                        }
                    }
                    
                    // Theme selection section
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Color Theme"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: window.textColor
                        }
                        
                        // Responsive theme grid
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 240
                            contentWidth: availableWidth
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            
                            GridLayout {
                                width: parent.width
                                columns: 3 // Responsive columns
                                columnSpacing: 10
                                rowSpacing: 10
                                
                                property var themeNames: [
                                    { key: "default", name: "Default" },
                                    { key: "dracula", name: "Dracula" },
                                    { key: "nightOwl", name: "Night Owl" },
                                    { key: "githubDark", name: "GitHub Dark" },
                                    { key: "catppuccin", name: "Catppuccin" },
                                    { key: "tokyoNight", name: "Tokyo Night" },
                                    { key: "gruvboxDark", name: "Gruvbox Dark" },
                                    { key: "nordDark", name: "Nord Dark" },
                                    { key: "oneDark", name: "One Dark" },
                                    { key: "solarizedLight", name: "Solarized Light" },
                                    { key: "solarizedDark", name: "Solarized Dark" },
                                    { key: "materialLight", name: "Material Light" },
                                    { key: "highContrast", name: "High Contrast" },
                                    { key: "cyberpunk", name: "Cyberpunk" },
                                    { key: "forest", name: "Forest" },
                                    { key: "ocean", name: "Ocean" },
                                    { key: "sunset", name: "Sunset" }
                                ]
                                
                                Repeater {
                                    model: parent.themeNames
                                    
                                    Rectangle {
                                        Layout.preferredWidth: 140
                                        Layout.preferredHeight: 44
                                        radius: 8
                                        
                                        property bool isSelected: false
                                        property bool hovered: false
                                        property var themeColors: themeManager.getTheme(modelData.key)
                                        
                                        // Update selection when theme changes
                                        Connections {
                                            target: themeManager
                                            function onThemeChanged() {
                                                isSelected = themeManager.getCurrentTheme() === modelData.key
                                            }
                                        }
                                        
                                        Component.onCompleted: {
                                            isSelected = themeManager.getCurrentTheme() === modelData.key
                                        }
                                        
                                        color: {
                                            if (isSelected) return window.accentColor
                                            if (hovered) return Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.1)
                                            return window.cardBackgroundColor
                                        }
                                        
                                        border.color: {
                                            if (isSelected) return window.accentColor
                                            if (hovered) return Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.4)
                                            return window.cardBorderColor
                                        }
                                        border.width: isSelected ? 2 : 1
                                        
                                        // Smooth transitions
                                        Behavior on color { ColorAnimation { duration: 200 } }
                                        Behavior on border.color { ColorAnimation { duration: 200 } }
                                        Behavior on scale { NumberAnimation { duration: 150 } }
                                        
                                        scale: hovered ? 1.02 : 1.0
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: Math.max(parent.width * 0.08, 12)
                                            spacing: Math.max(parent.width * 0.06, 8)
                                            
                                            // Color preview dots
                                            Row {
                                                spacing: 3
                                                
                                                Rectangle {
                                                    width: 12
                                                    height: width
                                                    radius: width / 2
                                                    color: parent.parent.parent.themeColors.background || "#ecf0f1"
                                                    border.color: Qt.darker(color, 1.3)
                                                    border.width: 1
                                                }
                                                
                                                Rectangle {
                                                    width: 12
                                                    height: width
                                                    radius: width / 2
                                                    color: parent.parent.parent.themeColors.primary || "#3498db"
                                                    border.color: Qt.darker(color, 1.3)
                                                    border.width: 1
                                                }
                                                
                                                Rectangle {
                                                    width: 12
                                                    height: width
                                                    radius: width / 2
                                                    color: parent.parent.parent.themeColors.accent || "#2ecc71"
                                                    border.color: Qt.darker(color, 1.3)
                                                    border.width: 1
                                                }
                                            }
                                            
                                            // Theme name
                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 12
                                                font.weight: parent.parent.isSelected ? Font.Medium : Font.Normal
                                                color: parent.parent.isSelected ? "white" : window.textColor
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                            
                                            // Selection indicator
                                            Text {
                                                text: parent.parent.isSelected ? "✓" : ""
                                                font.pixelSize: Math.max(root.baseWidth * 0.02, 14)
                                                font.bold: true
                                                color: "white"
                                                visible: parent.parent.isSelected
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onEntered: parent.hovered = true
                                            onExited: parent.hovered = false
                                            onClicked: {
                                                themeManager.setTheme(modelData.key)
                                            }
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Flexible spacer
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 12
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
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 36
                    
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
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    
                    onClicked: {
                        root.close()
                        window.restoreFocus()
                    }
                }
                
                Button {
                    text: "Done"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    
                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(window.primaryColor, 1.1) : 
                               parent.hovered ? Qt.lighter(window.primaryColor, 1.1) : window.primaryColor
                        radius: 6
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    
                    onClicked: {
                        root.close()
                        window.restoreFocus()
                    }
                }
            }
        }
    }
    
    // === EVENT HANDLERS ===
    
    onOpened: {
        forceActiveFocus()
    }
}