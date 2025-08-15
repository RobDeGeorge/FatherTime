import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    anchors.centerIn: parent
    width: window.width * 0.8
    height: window.height * 0.7
    modal: true
    
    property alias confirmationSlider: confirmSlider
    
    // Reset slider when dialog opens
    onOpened: {
        confirmSlider.value = 0
    }
    
    Shortcut {
        sequence: "Escape"
        onActivated: {
            cancelButton.clicked()
        }
    }
    
    background: Rectangle {
        color: window.backgroundColor
        border.color: window.dangerColor
        border.width: 3
        radius: 8
    }
    
    header: Rectangle {
        height: 60
        color: window.dangerColor
        radius: 8
        
        Text {
            anchors.centerIn: parent
            text: "⚠️ DANGER: Reset All Data"
            font.pixelSize: 18
            font.bold: true
            color: window.backgroundColor
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Math.max(window.width * 0.025, 20)
        spacing: Math.max(window.height * 0.025, 20)
        
        Text {
            text: "⚠️ DANGER: Complete Data Reset"
            font.pixelSize: 18
            font.bold: true
            color: window.dangerColor
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.topMargin: 5
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            color: Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.08)
            radius: 10
            border.color: Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.3)
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12
                
                Text {
                    text: "This will permanently delete:"
                    font.pixelSize: 14
                    font.bold: true
                    color: window.textColor
                    Layout.fillWidth: true
                }
                
                Column {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "• All timer definitions and configurations"
                        font.pixelSize: 12
                        color: window.textColor
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        text: "• All work sessions and time tracking history"
                        font.pixelSize: 12
                        color: window.textColor
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        text: "• All daily statistics and breakdowns"
                        font.pixelSize: 12
                        color: window.textColor
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        text: "• All date-specific timer states"
                        font.pixelSize: 12
                        color: window.textColor
                        wrapMode: Text.WordWrap
                    }
                }
                
                Text {
                    text: "⚠️ This action cannot be undone!"
                    font.pixelSize: 12
                    font.bold: true
                    color: window.dangerColor
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.topMargin: 15
                    Layout.bottomMargin: 10
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: parent.width - 40
                }
            }
        }
        
        // Confirmation slider section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            color: Qt.rgba(window.warningColor.r, window.warningColor.g, window.warningColor.b, 0.08)
            radius: 10
            border.color: Qt.rgba(window.warningColor.r, window.warningColor.g, window.warningColor.b, 0.3)
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16
                
                Text {
                    text: "Slide all the way to the right to confirm deletion:"
                    font.pixelSize: 13
                    font.bold: true
                    color: window.textColor
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Text {
                        text: "SAFE"
                        font.pixelSize: 11
                        font.bold: true
                        color: window.successColor
                        Layout.alignment: Qt.AlignVCenter
                    }
                    
                    Slider {
                        id: confirmSlider
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        from: 0
                        to: 100
                        value: 0
                        
                        background: Rectangle {
                            x: confirmSlider.leftPadding
                            y: confirmSlider.topPadding + confirmSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 8
                            width: confirmSlider.availableWidth
                            height: implicitHeight
                            radius: 4
                            color: "#e8e8e8"
                            
                            Rectangle {
                                width: confirmSlider.visualPosition * parent.width
                                height: parent.height
                                color: confirmSlider.value < 95 ? window.warningColor : window.dangerColor
                                radius: 4
                            }
                        }
                        
                        handle: Rectangle {
                            x: confirmSlider.leftPadding + confirmSlider.visualPosition * (confirmSlider.availableWidth - width)
                            y: confirmSlider.topPadding + confirmSlider.availableHeight / 2 - height / 2
                            implicitWidth: 28
                            implicitHeight: 28
                            radius: 14
                            color: confirmSlider.pressed ? Qt.darker(confirmSlider.value < 95 ? window.warningColor : window.dangerColor, 1.2) : (confirmSlider.value < 95 ? window.warningColor : window.dangerColor)
                            border.color: "#ffffff"
                            border.width: 2
                        }
                    }
                    
                    Text {
                        text: "DELETE"
                        font.pixelSize: 11
                        font.bold: true
                        color: window.dangerColor
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 20
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            Layout.bottomMargin: 5
            
            Item {
                Layout.fillWidth: true
            }
            
            Button {
                id: cancelButton
                text: "Cancel"
                Layout.preferredWidth: Math.max(window.width * 0.08, 80)
                Layout.preferredHeight: Math.max(window.height * 0.05, 36)
                
                background: Rectangle {
                    color: parent.pressed ? Qt.darker(window.cardBorderColor, 1.1) : window.cardBorderColor
                    radius: 8
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: window.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Math.max(window.width * 0.015, 13)
                    font.weight: Font.Medium
                }
                
                onClicked: {
                    confirmSlider.value = 0
                    root.close()
                }
            }
            
            Button {
                text: confirmSlider.value >= 95 ? "CONFIRM RESET" : "Slide to confirm →"
                enabled: confirmSlider.value >= 95
                Layout.preferredWidth: Math.max(window.width * 0.12, 100)
                Layout.preferredHeight: Math.max(window.height * 0.05, 36)
                
                background: Rectangle {
                    color: {
                        if (!parent.enabled) return Qt.rgba(window.cardBorderColor.r, window.cardBorderColor.g, window.cardBorderColor.b, 0.5)
                        if (parent.pressed) return Qt.darker(window.dangerColor, 1.1)
                        return confirmSlider.value >= 95 ? window.dangerColor : Qt.rgba(window.dangerColor.r, window.dangerColor.g, window.dangerColor.b, 0.3)
                    }
                    radius: 8
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "white" : Qt.rgba(1, 1, 1, 0.5)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Math.max(window.width * 0.015, 13)
                    font.weight: Font.Medium
                    wrapMode: Text.WordWrap
                }
                
                onClicked: {
                    timerManager.resetAllData()
                    confirmSlider.value = 0
                    root.close()
                }
            }
        }
    }
}