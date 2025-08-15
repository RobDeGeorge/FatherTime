import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/**
 * SimplePopupMenu - A working responsive popup menu without complex features
 * This version avoids FINAL property issues and complex alias references
 */
Popup {
    id: root
    
    // === PROPERTIES ===
    property string menuTitle: "Menu"
    property var menuItems: []
    property string iconSource: ""
    property bool showCloseButton: true
    
    // Callbacks
    signal itemSelected(int index, var item)
    signal menuClosed()
    
    // === RESPONSIVE SIZING ===
    readonly property real baseWidth: Math.min(Math.max(parent.width * 0.4, 280), 480)
    readonly property real baseHeight: Math.min(parent.height * 0.6, baseWidth * 1.2)
    
    // === POPUP CONFIGURATION ===
    width: baseWidth
    height: Math.min(baseHeight, 400)
    
    anchors.centerIn: parent
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    // === ANIMATIONS ===
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 200
        }
    }
    
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 150
        }
    }
    
    // === VISUAL STYLING ===
    background: Rectangle {
        color: "#F9F9F9"
        border.color: "#E0E0E0"
        border.width: 1
        radius: 12
        
        // Simple shadow
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            anchors.leftMargin: 2
            color: "#20000000"
            radius: parent.radius
            z: parent.z - 1
        }
    }
    
    // === CONTENT ===
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: root.iconSource
                font.pixelSize: 20
                visible: root.iconSource !== ""
            }
            
            Text {
                text: root.menuTitle
                font.pixelSize: 18
                font.weight: Font.Medium
                color: "#1F1F1F"
                Layout.fillWidth: true
            }
            
            Button {
                visible: root.showCloseButton
                text: "×"
                width: 30
                height: 30
                
                background: Rectangle {
                    color: parent.pressed ? "#E0E0E0" : "transparent"
                    radius: 15
                }
                
                onClicked: root.close()
            }
        }
        
        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#E0E0E0"
        }
        
        // Menu Items
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: listView
                model: root.menuItems
                spacing: 2
                
                delegate: ItemDelegate {
                    width: listView.width
                    height: 48
                    
                    background: Rectangle {
                        color: parent.hovered ? "#F5F5F5" : "transparent"
                        radius: 6
                    }
                    
                    contentItem: RowLayout {
                        spacing: 12
                        
                        Text {
                            text: modelData.icon || ""
                            font.pixelSize: 16
                            visible: text !== ""
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: modelData.title || modelData.text || ""
                                font.pixelSize: 14
                                color: "#1F1F1F"
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: modelData.subtitle || ""
                                font.pixelSize: 12
                                color: "#666666"
                                visible: text !== ""
                                Layout.fillWidth: true
                            }
                        }
                        
                        Text {
                            text: modelData.trailing || ""
                            font.pixelSize: 12
                            color: "#666666"
                            visible: text !== ""
                        }
                    }
                    
                    onClicked: {
                        root.itemSelected(index, modelData)
                        root.close()
                    }
                }
            }
        }
    }
    
    // === METHODS ===
    function openMenu() {
        open()
    }
    
    function closeMenu() {
        close()
        menuClosed()
    }
    
    onClosed: menuClosed()
}