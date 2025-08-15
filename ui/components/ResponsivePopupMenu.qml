import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * ResponsivePopupMenu - A modern, fully responsive popup menu component
 * 
 * Design Philosophy:
 * - Always anchored within parent boundaries using Overlay system
 * - Proportional sizing that scales with screen dimensions
 * - Maintains aspect ratios for all visual elements
 * - Follows Microsoft Fluent Design principles with clean typography
 * - Smooth animations and accessibility support
 * 
 * Sizing Strategy:
 * - Base width: 40% of parent width (min 280px, max 480px)
 * - Height: Auto-calculated based on content with aspect ratio constraints
 * - All internal spacing/margins scale proportionally
 * - Typography scales with screen size but maintains readability
 */
Popup {
    id: root
    
    // === PROPERTIES ===
    
    // Content configuration
    property alias menuTitle: titleText.text
    property alias menuItems: menuRepeater.model
    property string iconSource: ""
    property bool showCloseButton: true
    
    // Callbacks
    signal itemSelected(int index, var item)
    signal menuClosed()
    
    // === RESPONSIVE SIZING ===
    
    // Calculate responsive dimensions based on parent/screen size
    readonly property real baseWidth: Math.min(Math.max(parent.width * 0.4, 280), 480)
    readonly property real baseHeight: Math.min(parent.height * 0.6, baseWidth * 1.2)
    
    // Scaling factors for consistent proportions
    readonly property real scaleFactor: Math.min(parent.width / 1200, parent.height / 800)
    readonly property real minScaleFactor: Math.max(scaleFactor, 0.6)
    
    // Responsive spacing and sizing
    readonly property real menuSpacing: Math.max(baseWidth * 0.02, 8)
    readonly property real menuPadding: Math.max(baseWidth * 0.04, 16)
    readonly property real cornerRadius: Math.max(baseWidth * 0.02, 12)
    
    // === POPUP CONFIGURATION ===
    
    width: baseWidth
    height: Math.min(baseHeight, contentColumn.implicitHeight + menuPadding * 2)
    
    // Always center in parent and ensure it stays within bounds
    anchors.centerIn: Overlay.overlay ? Overlay.overlay : parent
    
    // Overlay ensures popup is always on top and properly managed
    parent: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    // Smooth entrance/exit animations following Fluent Design
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.9
                to: 1.0
                duration: 200
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
                duration: 150
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.95
                duration: 150
                easing.type: Easing.InCubic
            }
        }
    }
    
    // === KEYBOARD NAVIGATION ===
    
    Keys.onPressed: {
        switch (event.key) {
            case Qt.Key_Escape:
                close()
                event.accepted = true
                break
            case Qt.Key_Up:
                if (menuListView.currentIndex > 0) {
                    menuListView.currentIndex--
                }
                event.accepted = true
                break
            case Qt.Key_Down:
                if (menuListView.currentIndex < menuRepeater.count - 1) {
                    menuListView.currentIndex++
                }
                event.accepted = true
                break
            case Qt.Key_Return:
            case Qt.Key_Enter:
                if (menuListView.currentIndex >= 0) {
                    var item = menuRepeater.model[menuListView.currentIndex]
                    itemSelected(menuListView.currentIndex, item)
                    close()
                }
                event.accepted = true
                break
        }
    }
    
    // === VISUAL STYLING ===
    
    background: Rectangle {
        color: "#F9F9F9"  // Fluent Design neutral background
        border.color: "#E0E0E0"
        border.width: 1
        radius: root.cornerRadius
        
        // Simple shadow using layered rectangles
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            color: "#20000000"
            radius: parent.radius
            z: parent.z - 1
        }
        
        // Smooth color transitions
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    // === CONTENT LAYOUT ===
    
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: root.menuPadding
        spacing: root.menuSpacing
        
        // === HEADER SECTION ===
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(root.baseWidth * 0.12, 48)
            spacing: root.menuSpacing
            
            // Optional icon
            Image {
                id: headerIcon
                visible: root.iconSource !== ""
                source: root.iconSource
                
                // Responsive sizing while preserving aspect ratio
                Layout.preferredWidth: Math.max(root.baseWidth * 0.08, 32)
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignVCenter
                
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                
                // Smooth transitions
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }
            
            // Title text
            Text {
                id: titleText
                text: "Menu"
                
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                
                // Responsive typography
                font.pixelSize: Math.max(root.baseWidth * 0.04, 18)
                font.weight: Font.Medium
                font.family: "Segoe UI, system-ui, sans-serif"  // Fluent Design typography
                
                color: "#1F1F1F"  // High contrast text
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                
                // Accessibility
                Accessible.role: Accessible.Heading
                Accessible.name: text
            }
            
            // Close button
            Button {
                id: closeButton
                visible: root.showCloseButton
                
                Layout.preferredWidth: Math.max(root.baseWidth * 0.08, 32)
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignVCenter
                
                // Minimal styling for close button
                background: Rectangle {
                    color: parent.pressed ? "#E0E0E0" : 
                           parent.hovered ? "#F0F0F0" : "transparent"
                    radius: parent.width * 0.5
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
                
                contentItem: Text {
                    text: "×"
                    font.pixelSize: Math.max(root.baseWidth * 0.035, 16)
                    font.weight: Font.Bold
                    color: "#666666"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    root.close()
                    root.menuClosed()
                }
                
                // Accessibility
                Accessible.role: Accessible.Button
                Accessible.name: "Close menu"
            }
        }
        
        // Separator line
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#E0E0E0"
            Layout.topMargin: root.menuSpacing * 0.5
            Layout.bottomMargin: root.menuSpacing * 0.5
        }
        
        // === MENU ITEMS SECTION ===
        ScrollView {
            id: menuScrollView
            
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: Math.max(root.baseWidth * 0.2, 80)
            
            // Responsive scrollbar styling
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            
            clip: true
            
            ListView {
                id: menuListView
                
                // Responsive item sizing
                spacing: Math.max(root.baseWidth * 0.005, 2)
                
                // Keyboard navigation support
                focus: true
                keyNavigationEnabled: true
                currentIndex: -1
                
                model: menuRepeater.model
                
                delegate: ItemDelegate {
                    id: menuItem
                    
                    // Full width with responsive height
                    width: menuListView.width
                    height: Math.max(root.baseWidth * 0.12, 48)
                    
                    // Visual states
                    property bool isCurrentItem: ListView.isCurrentItem
                    
                    background: Rectangle {
                        color: {
                            if (parent.pressed) return "#E0E0E0"
                            if (parent.hovered || parent.isCurrentItem) return "#F5F5F5"
                            return "transparent"
                        }
                        radius: Math.max(root.baseWidth * 0.01, 6)
                        
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                    
                    contentItem: RowLayout {
                        spacing: root.menuSpacing
                        anchors.fill: parent
                        anchors.margins: root.menuSpacing
                        
                        // Item icon (if provided)
                        Image {
                            visible: modelData.icon !== undefined && modelData.icon !== ""
                            source: modelData.icon || ""
                            
                            Layout.preferredWidth: Math.max(root.baseWidth * 0.06, 24)
                            Layout.preferredHeight: Layout.preferredWidth
                            Layout.alignment: Qt.AlignVCenter
                            
                            fillMode: Image.PreserveAspectFit
                            antialiasing: true
                        }
                        
                        // Item text
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Math.max(root.menuSpacing * 0.25, 2)
                            
                            Text {
                                text: modelData.title || modelData.text || ""
                                
                                Layout.fillWidth: true
                                
                                font.pixelSize: Math.max(root.baseWidth * 0.035, 14)
                                font.weight: Font.Normal
                                font.family: "Segoe UI, system-ui, sans-serif"
                                
                                color: "#1F1F1F"
                                elide: Text.ElideRight
                                
                                // Accessibility
                                Accessible.role: Accessible.MenuItem
                                Accessible.name: text
                            }
                            
                            // Optional subtitle
                            Text {
                                visible: modelData.subtitle !== undefined && modelData.subtitle !== ""
                                text: modelData.subtitle || ""
                                
                                Layout.fillWidth: true
                                
                                font.pixelSize: Math.max(root.baseWidth * 0.025, 12)
                                font.weight: Font.Normal
                                font.family: "Segoe UI, system-ui, sans-serif"
                                
                                color: "#666666"
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }
                        }
                        
                        // Optional trailing element (arrow, checkmark, etc.)
                        Text {
                            visible: modelData.trailing !== undefined && modelData.trailing !== ""
                            text: modelData.trailing || ""
                            
                            Layout.alignment: Qt.AlignVCenter
                            
                            font.pixelSize: Math.max(root.baseWidth * 0.03, 12)
                            color: "#666666"
                        }
                    }
                    
                    onClicked: {
                        menuListView.currentIndex = index
                        root.itemSelected(index, modelData)
                        root.close()
                    }
                    
                    // Keyboard navigation
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            menuListView.currentIndex = index
                        }
                    }
                }
                
                // Smooth scrolling animations
                Behavior on contentY {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
    
    // === UTILITY METHODS ===
    
    /**
     * Opens the popup and sets initial focus for keyboard navigation
     */
    function openMenu() {
        open()
        menuListView.forceActiveFocus()
        if (menuRepeater.count > 0) {
            menuListView.currentIndex = 0
        }
    }
    
    /**
     * Closes the popup and emits closed signal
     */
    function closeMenu() {
        close()
        menuClosed()
    }
    
    // === EVENT HANDLERS ===
    
    onOpened: {
        // Ensure proper focus for accessibility
        forceActiveFocus()
    }
    
    onClosed: {
        // Reset state
        menuListView.currentIndex = -1
        menuClosed()
    }
    
    // Handle window resize to maintain proper positioning
    Connections {
        target: parent
        function onWidthChanged() { root.anchors.centerIn = root.parent }
        function onHeightChanged() { root.anchors.centerIn = root.parent }
    }
}