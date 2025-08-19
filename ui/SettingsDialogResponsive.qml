import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * Settings Dialog - Responsive version for global app configuration
 * 
 * Features:
 * - Responsive sizing based on screen dimensions  
 * - Theme selection with live preview
 * - Time rounding configuration
 * - Smooth animations and modern design
 */

Dialog {
    id: root
    
    // === RESPONSIVE SIZING ===
    width: Math.min(parent.width * 0.9, 800)
    height: Math.min(parent.height * 0.9, 900)
    
    anchors.centerIn: parent
    modal: true
    
    // === ANIMATIONS ===
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200 }
    }
    
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 150 }
    }
    
    // === BACKGROUND ===
    background: Rectangle {
        color: window.cardBackgroundColor
        border.color: window.cardBorderColor
        border.width: 1
        radius: 16
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: -10
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.1)
            border.width: 1
            radius: parent.radius + 10
            z: parent.z - 1
        }
    }
    
    // === HEADER ===
    header: Rectangle {
        height: 70
        color: window.primaryColor
        radius: 16
        
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
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
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
                Layout.preferredHeight: 500
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
                    
                    // Theme selection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Color Theme"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: window.textColor
                        }
                        
                        // Theme grid - adaptive columns based on screen width
                        GridLayout {
                            Layout.fillWidth: true
                            columns: Math.max(2, Math.min(4, Math.floor(width / 160)))
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
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 44
                                    Layout.minimumWidth: 120
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
                                    
                                    color: isSelected ? Qt.rgba(themeColors.accent.r, themeColors.accent.g, themeColors.accent.b, 0.2) : 
                                           hovered ? Qt.rgba(themeColors.primary.r, themeColors.primary.g, themeColors.primary.b, 0.1) : 
                                           "transparent"
                                    
                                    border.color: isSelected ? themeColors.accent : 
                                                  hovered ? Qt.rgba(themeColors.primary.r, themeColors.primary.g, themeColors.primary.b, 0.3) : 
                                                  Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.5)
                                    border.width: isSelected ? 2 : 1
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: 200 }
                                    }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 6
                                        
                                        // Three color circles
                                        Rectangle {
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: themeColors.background
                                        }
                                        
                                        Rectangle {
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: themeColors.primary
                                        }
                                        
                                        Rectangle {
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: themeColors.accent
                                        }
                                        
                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 11
                                            font.weight: isSelected ? Font.Bold : Font.Normal
                                            color: window.textColor
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
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
            
            // === TIME ROUNDING SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
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
                                text: "⏱️"
                                font.pixelSize: Math.max(parent.width * 0.5, 14)
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: "Time Rounding"
                                font.pixelSize: 16
                                font.bold: true
                                color: window.textColor
                            }
                            
                            Text {
                                text: "Configure how stopwatch times are rounded when stopped"
                                font.pixelSize: 11
                                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            }
                        }
                    }
                    
                    // Time rounding options
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        // Enable/disable toggle
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Enable Rounding:"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: window.textColor
                                Layout.preferredWidth: 120
                            }
                            
                            Switch {
                                id: roundingEnabledSwitch
                                checked: configManager.timeRoundingEnabled
                                onToggled: {
                                    configManager.setTimeRoundingEnabled(checked)
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // Rounding interval selection
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            enabled: roundingEnabledSwitch.checked
                            opacity: enabled ? 1.0 : 0.5
                            
                            Text {
                                text: "Round to:"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: window.textColor
                                Layout.preferredWidth: 120
                            }
                            
                            ComboBox {
                                id: roundingComboBox
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 36
                                
                                property var roundingOptions: [
                                    { value: 15, text: "Quarter hours (15 min)" },
                                    { value: 30, text: "Half hours (30 min)" },
                                    { value: 60, text: "Full hours (60 min)" }
                                ]
                                
                                model: roundingOptions.map(option => option.text)
                                
                                Component.onCompleted: {
                                    let currentValue = configManager.timeRoundingMinutes
                                    for (let i = 0; i < roundingOptions.length; i++) {
                                        if (roundingOptions[i].value === currentValue) {
                                            currentIndex = i
                                            break
                                        }
                                    }
                                }
                                
                                onActivated: function(index) {
                                    let selectedValue = roundingOptions[index].value
                                    configManager.setTimeRoundingMinutes(selectedValue)
                                }
                                
                                background: Rectangle {
                                    color: window.cardBackgroundColor
                                    border.color: parent.activeFocus ? window.accentColor : window.cardBorderColor
                                    border.width: parent.activeFocus ? 2 : 1
                                    radius: 6
                                }
                                
                                contentItem: Text {
                                    text: parent.displayText
                                    color: Qt.darker(parent.parent.background.color, 2.5)
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // Example text
                        Text {
                            text: {
                                if (!roundingEnabledSwitch.checked) return "Example: 1.74h → 1.74h (no rounding)"
                                let minutes = configManager.timeRoundingMinutes
                                if (minutes === 15) return "Example: 1.74h → 1.75h (rounded to quarter hours)"
                                if (minutes === 30) return "Example: 1.74h → 2.00h (rounded to half hours)"
                                if (minutes === 60) return "Example: 1.74h → 2.00h (rounded to full hours)"
                                return "Example: 1.74h → 1.75h (rounded)"
                            }
                            font.pixelSize: 10
                            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.6)
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
            
            // === WINDOW SETTINGS SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 280
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
                                text: "🖥"
                                font.pixelSize: Math.max(parent.width * 0.5, 14)
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: "Window Settings"
                                font.pixelSize: 16
                                font.bold: true
                                color: window.textColor
                            }
                            
                            Text {
                                text: "Configure default window size on startup"
                                font.pixelSize: 11
                                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            }
                        }
                    }
                    
                    // Window size controls
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        // Width setting
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Width:"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: window.textColor
                                Layout.preferredWidth: 80
                            }
                            
                            SpinBox {
                                id: widthSpinBox
                                Layout.preferredWidth: 120
                                from: 800
                                to: 3840
                                stepSize: 50
                                value: configManager.windowWidth
                                
                                onValueModified: {
                                    configManager.setWindowWidth(value)
                                }
                                
                                background: Rectangle {
                                    color: window.backgroundColor
                                    border.color: window.cardBorderColor
                                    border.width: 1
                                    radius: 6
                                }
                            }
                            
                            Text {
                                text: "pixels"
                                font.pixelSize: 12
                                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // Height setting
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Height:"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: window.textColor
                                Layout.preferredWidth: 80
                            }
                            
                            SpinBox {
                                id: heightSpinBox
                                Layout.preferredWidth: 120
                                from: 600
                                to: 2160
                                stepSize: 50
                                value: configManager.windowHeight
                                
                                onValueModified: {
                                    configManager.setWindowHeight(value)
                                }
                                
                                background: Rectangle {
                                    color: window.backgroundColor
                                    border.color: window.cardBorderColor
                                    border.width: 1
                                    radius: 6
                                }
                            }
                            
                            Text {
                                text: "pixels"
                                font.pixelSize: 12
                                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // Current size display
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Text {
                                text: "Current size:"
                                font.pixelSize: 12
                                color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.7)
                            }
                            
                            Text {
                                text: window.width + " × " + window.height
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: window.textColor
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // Info text
                        Text {
                            Layout.fillWidth: true
                            text: "Note: Window size changes will take effect on next application startup"
                            font.pixelSize: 10
                            color: Qt.rgba(window.textColor.r, window.textColor.g, window.textColor.b, 0.6)
                            wrapMode: Text.WordWrap
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
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    
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
                        color: Qt.darker(parent.parent.background.color, 3.0)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    
                    onClicked: {
                        root.close()
                        window.restoreFocus()
                    }
                }
                
                Button {
                    text: "Done"
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 40
                    
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
                        color: Qt.darker(parent.parent.background.color, 3.0)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
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
    
    onOpened: {
        forceActiveFocus()
    }
}