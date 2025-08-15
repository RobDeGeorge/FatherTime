import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    anchors.centerIn: parent
    width: window.width * 0.9
    height: window.height * 0.9
    modal: true
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            doneButton.clicked()
        }
    }
    
    Shortcut {
        sequence: "Return"
        onActivated: root.close()
    }
    
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.primaryColor
        border.width: 2
        radius: 8
    }
    
    header: Rectangle {
        height: 50
        color: window.primaryColor
        radius: 8
        
        Text {
            anchors.centerIn: parent
            text: "⚙ Settings"
            font.pixelSize: 16
            font.bold: true
            color: window.backgroundColor
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: Math.max(window.width * 0.02, 10)
        contentWidth: availableWidth
        
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        ColumnLayout {
            width: parent.width
            spacing: Math.max(window.height * 0.03, 15)
            
            // Appearance Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: appearanceContent.implicitHeight + 40
                color: window.cardBackgroundColor
                border.color: window.cardBorderColor
                border.width: 1
                radius: 12
                
                ColumnLayout {
                    id: appearanceContent
                    anchors.fill: parent
                    anchors.margins: Math.max(window.width * 0.02, 12)
                    spacing: Math.max(window.height * 0.025, 12)
                    
                    // Section header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Rectangle {
                            width: Math.max(window.width * 0.03, 24)
                            height: Math.max(window.width * 0.03, 24)
                            color: Qt.rgba(window.primaryColor.r, window.primaryColor.g, window.primaryColor.b, 0.15)
                            radius: Math.max(window.width * 0.008, 6)
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🎨"
                                font.pixelSize: Math.max(window.width * 0.018, 12)
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: "Appearance"
                                font.pixelSize: Math.max(window.width * 0.018, 14)
                                font.bold: true
                                color: window.textColor
                            }
                            
                            Text {
                                text: "Customize the visual theme and colors"
                                font.pixelSize: Math.max(window.width * 0.012, 10)
                                color: Qt.darker(window.textColor, 1.3)
                                opacity: 0.8
                            }
                        }
                    }
                    
                    // Theme selection with chips
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        
                        Text {
                            text: "Color Theme"
                            font.pixelSize: Math.max(window.width * 0.014, 11)
                            font.weight: Font.Medium
                            color: window.textColor
                        }
                        
                        // Theme chips grid
                        Flow {
                            Layout.fillWidth: true
                            spacing: Math.max(window.width * 0.01, 6)
                            
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
                                    width: chipContent.implicitWidth + 16
                                    height: Math.min(Math.max(window.height * 0.06, 32), 45)
                                    radius: height / 2
                                    
                                    property bool isSelected: themeManager.getCurrentTheme() === modelData.key
                                    property bool hovered: false
                                    property var themeColors: themeManager.getTheme(modelData.key)
                                    
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
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    
                                    RowLayout {
                                        id: chipContent
                                        anchors.centerIn: parent
                                        spacing: 8
                                        
                                        // Color preview dots using actual theme colors
                                        Row {
                                            spacing: 2
                                            
                                            Rectangle {
                                                width: Math.min(Math.max(window.width * 0.015, 10), 14)
                                                height: Math.min(Math.max(window.width * 0.015, 10), 14)
                                                radius: width / 2
                                                color: parent.parent.parent.themeColors.background || "#ecf0f1"
                                                border.color: Qt.darker(color, 1.3)
                                                border.width: 1
                                            }
                                            
                                            Rectangle {
                                                width: Math.min(Math.max(window.width * 0.015, 10), 14)
                                                height: Math.min(Math.max(window.width * 0.015, 10), 14)
                                                radius: width / 2
                                                color: parent.parent.parent.themeColors.primary || "#3498db"
                                                border.color: Qt.darker(color, 1.3)
                                                border.width: 1
                                            }
                                            
                                            Rectangle {
                                                width: Math.min(Math.max(window.width * 0.015, 10), 14)
                                                height: Math.min(Math.max(window.width * 0.015, 10), 14)
                                                radius: width / 2
                                                color: parent.parent.parent.themeColors.accent || "#2ecc71"
                                                border.color: Qt.darker(color, 1.3)
                                                border.width: 1
                                            }
                                        }
                                        
                                        Text {
                                            text: modelData.name
                                            font.pixelSize: Math.min(Math.max(window.width * 0.014, 10), 13)
                                            font.weight: parent.parent.isSelected ? Font.Medium : Font.Normal
                                            color: parent.parent.isSelected ? "white" : window.textColor
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
                                    }
                                }
                            }
                        }
                        
                        // Keyboard shortcut info
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 35
                            color: Qt.rgba(window.primaryColor.r, window.primaryColor.g, window.primaryColor.b, 0.05)
                            radius: 8
                            border.color: Qt.rgba(window.primaryColor.r, window.primaryColor.g, window.primaryColor.b, 0.15)
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                
                                Text {
                                    text: "💡"
                                    font.pixelSize: 14
                                }
                                
                                Text {
                                    text: "Quick cycling:"
                                    font.pixelSize: 11
                                    color: window.textColor
                                    opacity: 0.8
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: shortcutText.implicitWidth + 8
                                    Layout.preferredHeight: 20
                                    color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.1)
                                    radius: 3
                                    border.color: Qt.rgba(window.accentColor.r, window.accentColor.g, window.accentColor.b, 0.2)
                                    border.width: 1
                                    
                                    Text {
                                        id: shortcutText
                                        anchors.centerIn: parent
                                        text: "Ctrl+Alt+Shift+T"
                                        font.pixelSize: 9
                                        font.family: "monospace"
                                        color: window.textColor
                                        opacity: 0.9
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 20
            }
            
            // Close button
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                Layout.bottomMargin: 5
                
                Item {
                    Layout.fillWidth: true
                }
                
                Button {
                    id: doneButton
                    text: "Done"
                    Layout.preferredWidth: Math.max(window.width * 0.12, 100)
                    Layout.preferredHeight: Math.max(window.height * 0.05, 36)
                    
                    background: Rectangle {
                        color: parent.pressed ? Qt.darker(window.primaryColor, 1.1) : window.primaryColor
                        radius: 8
                        
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Math.max(window.width * 0.015, 13)
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
}