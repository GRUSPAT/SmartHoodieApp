import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
ApplicationWindow {
    id: applicationWindow
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    Material.primary: Material.Blue
    width: 430
    height: 932
    visible: true
    title: qsTr("Inteligentna Bluza")
    property bool disconnect: true
    header: ToolBar {
        contentHeight: toolButtonScan.implicitHeight
        Row{
            ToolButton {
                id: toolButtonScan
                text: "\u2630"
                font.pixelSize: Qt.application.font.pixelSize * 1.6
                onClicked: {
                    scanButton.enabled=true;
                    scanButton.text = disconnect ? "Scan" : "Disconnect"
                    drawer.open()
                }
            }
            ToolButton {
                id: toolButtonSend
                text: "\u23CE"
                font.pixelSize: Qt.application.font.pixelSize * 2.0
                enabled: false
                onClicked: {
                    bledevice.writeData(textTX.text.toString())
                }
            }
            ToolButton {
                id: toolButtonErase
                text: "\u232B"
                font.pixelSize: Qt.application.font.pixelSize * 2.0
                onClicked: {
                    textTX.text =
                            ""
                    textRX.text =
                            ""
                }
            }
        }
    }
    Drawer {
        id: drawer
        width: 250
        height: applicationWindow.height

        Button {
            id: scanButton
            width: parent.width
            text: "Scan"
            onClicked: {
                listView.enabled=false
                if(disconnect) {
                    text="Scanning..."
                    enabled = false
                    busyIndicator.running=true
                    bledevice.startScan()
                } else {
                    bledevice.disconnectFromDevice()
                }
            }
        }
        ListView {
            id: listView
            anchors.fill: parent
            anchors.topMargin: 50
            anchors.bottomMargin: 50
            width: parent.width
            clip: true
            model: bledevice.deviceListModel
            delegate: RadioDelegate {
                id: radioDelegate
                text: (index+1)+". "+modelData
                width: listView.width
                onCheckedChanged: {
                    console.log("checked", modelData, index)
                    scanButton.enabled=false;
                    scanButton.text="Connecting to "+modelData
                    listView.enabled = false;
                    bledevice.startConnect(index)
                }
            }
        }
        BusyIndicator {
            id: busyIndicator
            Material.accent: "Blue"
            anchors.centerIn: parent
            running: false
        }
    }
    Column {
        anchors.fill: parent
        anchors.topMargin: 540
        anchors.bottomMargin: 10
        anchors.leftMargin: 0
        anchors.rightMargin: 0

        TextField {
            id: textTX
            width: parent.width
            placeholderText: qsTr("Send Text")
            color: "LightBlue"
            font.pixelSize: 18
        }
        TextArea {
            id: textRX
            width: parent.width
            placeholderText: qsTr("Received Text")
            readOnly: true
            color: "LightBlue"
            font.pixelSize: 18
        }
        Item {
            width: 480
            height: 480

            Dial {
                id: customDial
                width: 430
                height: 430
                //anchors.centerIn: parent
                from: -45
                to: 45
                startAngle: -90
                endAngle: 90
                stepSize: 1
                snapMode: Dial.SnapAlways
                property int minAngle: -90
                property int maxAngle: 90;
                property int currentValue: 0;

                onRotationChanged: {
                                // Tutaj możesz dodać logikę, która będzie wywoływać opinie zwrotną (haptic feedback)
                                if (Qt.platform.os === "android") {
                                    // Haptic feedback na Androidzie (dostępne od wersji Android 8+)
                                    QtFeedback.playEffect(QtFeedback.ImpactFeedback)
                                } else if (Qt.platform.os === "ios") {
                                    // Haptic feedback na iOS (dostępne od wersji iOS 10+)
                                    QtFeedback.playEffect(QtFeedback.SelectionFeedback)
                                }
                            }

                background: Image {
                    source: "qrc:/images/DialBG.svg"
                           //source: "file://Users/patrykgruszowski/Inteligentna_Bluza/DialBackground.png"
                           sourceSize: Qt.size(parent.width, parent.height) // Dopasowanie rozmiaru obrazu do Dial

                           transform: Rotation {
                                           id: backgroundRotation
                                           origin.x: customDial.width / 2
                                           origin.y: customDial.height / 2
                                           angle: {
                                               // Ograniczenie obrotu do zakresu 90 do 90 stopni
                                               const minAngle = -90;
                                               const maxAngle = 90;
                                               if (customDial.angle < customDial.minAngle) {
                                                   return minAngle;
                                               } else if (customDial.angle > maxAngle) {
                                                   return maxAngle;
                                               } else {
                                                   return customDial.angle;
                                               }
                                           }
                                       }
                       }
                Item {
                           width: 50
                           height: 25
                           anchors.centerIn: customDial // Umiejscowienie przycisku na środku pokrętła

                           Button {
                               id: autoButton
                               text: "AUTO"
                               anchors.fill: parent

                               onClicked: {
                                   if (customDial.enabled) {
                                       console.log("Przełączono na tryb automatyczny")
                                       customDial.enabled = false // Wyłączenie możliwości obracania pokrętłem
                                   } else {
                                       console.log("Tryb manualny")
                                       customDial.enabled = true // Włączenie możliwości obracania pokrętłem
                                   }
                               }
                           }
                       }


                Text {
                       id: valueDisplay
                       text: customDial.currentValue// Wyświetlenie aktualnej wartości pokrętła
                       font.pixelSize: 20
                       color: "white"
                       anchors.horizontalCenter: parent.horizontalCenter
                               y: parent.height * 0.3
                   }
/*
                background: Image {
                    x: customDial.width / 2 - width / 2
                    y: customDial.height / 2 - height / 2
                    width: Math.max(64, Math.min(customDial.width, customDial.height))
                    height: width
                    //source: "qrc:/DIAL_BG.jpg"
                    //sourceSize: Qt.size(parent.width, parent.height) // Dopasowanie rozmiaru obrazu do Dial

                    //color: "transparent"
                    //radius: width / 2
                    // border.color: customDial.pressed ? "#FF6B00" : "#FF9B00"
                    opacity: customDial.enabled ? 1 : 0.3
                }
*/
                handle: Rectangle {
                    id: handleItem
                    x: customDial.background.x + customDial.background.width / 2 - width / 2
                    y: customDial.background.y + customDial.background.height / 2 - height / 2
                    width: 16
                    height: 16
                    visible:false

                    //color: customDial.pressed ? "#FF6B00" : "#FF9B00"
                    radius: 8
                    antialiasing: true
                    opacity: customDial.enabled ? 1 : 0.3
                    onRotationChanged: {
                                    backgroundRotation.angle = rotation // Obrót tła zgodnie z uchwytem
                                }
                    transform: [
                        Translate {
                            y: -Math.min(customDial.background.width, customDial.background.height) * 0.4 + handleItem.height / 2
                        },
                        Rotation {
                            /*angle: {
                                // Ograniczenie obrotu do zakresu 90 do 90 stopni
                                const minAngle = -93;
                                const maxAngle = 93;
                                if (customDial.angle < minAngle) {
                                    customDial.currentValue = minAngle /3;
                                    return minAngle;
                                } else if (customDial.angle > maxAngle) {
                                    customDial.currentValue = maxAngle /3;
                                    return maxAngle;
                                } else {
                                    customDial.currentValue = customDial.angle /3;
                                    //customDial.currentValue = customDial.value;
                                    return customDial.angle;
                                }
                            }*/
                            origin.x: handleItem.width / 2
                            origin.y: handleItem.height / 2
                        }
                    ]
                }

                onValueChanged: {
                    // Obsługa zmiany wartości pokrętła
                    valueDisplay.text = customDial.currentValue + 31;
                    //console.log("Nowa wartość:", customDial.currentValue)
                    console.log("Nowa wartość:", customDial.value)
                }
            }
        }




        Connections {
            target: bledevice
            function onNewData(data) {
                textRX.text = data
                console.log("Read:", data)
            }
            function onScanningFinished() {
                listView.enabled=true
                scanButton.enabled=true
                scanButton.text="Scan"
                listView.enabled=true
                busyIndicator.running=false
                scanButton.enabled=true
                console.log("ScanningFinished")
            }
            function onConnectionStart() {
                disconnect = false
                busyIndicator.running=false
                toolButtonSend.enabled=true
                drawer.close()
                console.log("ConnectionStart")
            }
            function onConnectionEnd() {
                disconnect = true
                scanButton.text = "Connection End - Scan again"
                scanButton.enabled = true
                toolButtonSend.enabled = false
                bledevice.resetDeviceListModel()
                console.log("ConnectionEnd")
            }
        }
    }
}
