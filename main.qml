import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Shapes
import QtCharts 2.15
import QtCore



ApplicationWindow {
    id: applicationWindow
    Material.theme: Material.Dark
    Material.accent: Material.Blue
    Material.primary: Material.Blue
    width: 430
    height: 932
    visible: true
    title: qsTr("Inteligentna Bluza")
    background: Image {
        source: "qrc:/images/MainScreen.svg"
        sourceSize: Qt.size(parent.width, parent.height) // Dopasowanie rozmiaru obrazu do D
    }
    property bool disconnect: true
    property int dialValue: 0
    property real externalTemperature: 0
    property real externalPressure: 0
    property real externalHumidity: 0
    property bool timerRunning: false
    property string bufforText: ""

    property color backgroundColor: "#1C1B1F"
    property color primaryColor: "#2C302E"
    property color textColor: "#F7FFF7"
    property color accentColor: "#FF6B00"



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
                    // bledevice.writeData("AT")
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
        BluetoothPermission {
            id: permission
            communicationModes: BluetoothPermission.Access
            onStatusChanged: {
                if (permission.status === Qt.PermissionStatus.Denied)
                    Device.update = "Bluetooth permission required"
                else if (permission.status === Qt.PermissionStatus.Granted)
                    devicesPage.toggleDiscovery()
            }
        }
        Button {
            id: scanButton
            width: parent.width
            text: "Scan"
            onClicked: {
                listView.enabled=false
                if (permission.status === Qt.PermissionStatus.Undetermined){
                    permission.request()}
                else if (permission.status === Qt.PermissionStatus.Granted){
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
        spacing: 9
        FontLoader { id: font; source: "qrc:/fonts/Montserrat-Bold.ttf" }

        Timer {
                id: timer
                interval: 1000 // czas w milisekundach (1000ms = 1s)
                repeat: true // powtarzaj co określony interwał
                running: timerRunning // uruchom timer od razu
                onTriggered: bledevice.writeData("TEMPERATURA") // wywołaj funkcję sendText() przy każdym wyzwaleniu timera
            }

        function checkAndSplitString(inputString) {
            var values = inputString.trim().split(" ");

            if (values.length === 3 && values[0] === "W:") {
                externalTemperature = parseFloat(values[1]);
                externalHumidity = parseFloat(values[2]);
                externalPressure = parseFloat(values[3]);


            } else {
                console.log("Nieprawidłowy format łańcucha");
            }
        }

        Rectangle {
            width: parent.width
            height: 55
            color: primaryColor
            radius: 20
            anchors.left: parent.left
            anchors.right: parent.right
            Text {
                id: valueExternalTemperature
                font.family: font.name
                // font.styleName: "Bold"
                //font.bold: true
                text: externalTemperature.toString()
                font.pixelSize: 12
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter


            }
        }

        Row {
            spacing: 9
            width: parent.width
            height: 277

            Rectangle {
                width: parent.width * 0.5 - 9
                height: 277
                color: accentColor
                radius: 10
            }

            Column {
                spacing: 9
                width: parent.width * 0.5 - 9
                Rectangle {
                    width: parent.width
                    height: 134
                    color: primaryColor
                    radius: 20
                    Text {
                        id: valueExternalPressure
                        font.family: font.name
                        // font.styleName: "Bold"
                        //font.bold: true
                        text: externalPressure.toString()
                        font.pixelSize: 12
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter


                    }
                }

                Rectangle {
                    width: parent.width
                    height: 134
                    color: primaryColor
                    radius: 20
                    Text {
                        id: valueExternalHumidity
                        font.family: font.name
                        // font.styleName: "Bold"
                        //font.bold: true
                        text: externalHumidity.toString()
                        font.pixelSize: 12
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter


                    }
                }
            }
        }

        Rectangle {

            width: parent.width - 18
            height: 200
            color: primaryColor
            radius: 20
            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.left: parent.left
            //anchors.right: parent.right
            TextField {
                id: textTX
                width: parent.width - 18
                placeholderText: qsTr("Send Text")
                color: "LightBlue"
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height * 0.1
            }
            TextArea {
                id: textRX
                width: parent.width - 18
                placeholderText: qsTr("Received Text")
                readOnly: true
                color: "LightBlue"
                font.pixelSize: 18
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height * 0.5
            }
            /*Text {
                id: valueTemperatureInternal
                font.family: font.name
                // font.styleName: "Bold"
                //font.bold: true
                text: "35"// Wyświetlenie aktualnej wartości pokrętła
                font.pixelSize: 48
                color: textColor
                anchors.horizontalCenter: parent.horizontalCenter
                //y: parent.height * 0.3
            }*/

        }
        Rectangle {
            width: parent.width
            height: 117
            color: "transparent"

            radius: 20
            anchors.left: parent.left
            anchors.right: parent.right



            Text {
                id: valueDis
                font.family: font.name
                // font.styleName: "Bold"
                //font.bold: true
                text: dialValue// Wyświetlenie aktualnej wartości pokrętła
                font.pixelSize: 96
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                //y: parent.height * 0.3

            }
        }

        /*
        ChartView {
            title: "Spline"
            anchors.fill: parent
            antialiasing: true
            backgroundColor: "transparent"
            width: parent.width

            SplineSeries {
                XYPoint { x: 0; y: 0.0 }
                XYPoint { x: 1.1; y: 3.2 }
                XYPoint { x: 1.9; y: 2.4 }
                XYPoint { x: 2.1; y: 2.1 }
                XYPoint { x: 2.9; y: 2.6 }
                XYPoint { x: 3.4; y: 2.3 }
                XYPoint { x: 4.1; y: 3.1 }

                // Usunięcie siatki dla serii danych
                axisX: ValueAxis {
                    visible: false
                }
                axisY: ValueAxis {
                    visible: false
                }
            }

            // Ukrycie legendy
            legend.visible: false
        }*/
        /*Button {
            id: settingsButton
            width: parent.width
            text: "USTAWIENIA"
            onClicked: {
                stackView.push("settings.qml")
            }
        }
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
*/
        /*
        Item {
                   width: 50
                   height: 25
                   //anchors.centerIn: customDial


                   Button {
                       id: autoButton2
                       text: "Increase"
                       property int testu: 0;
                      // anchors.fill: parent

                       onClicked: {
                        for(testu=0;testu<=60;testu++){
                           customDial.increase();

                        }
                       }
                   }
               }
             */
        Item {
            width: 480
            height: 480
            /*
                       Button {
                           id: autoButton
                           text: "AUTO"
                           anchors.fill: customDial

                           onClicked: {
                               if (customDial.enabled) {
                                   console.log("Przełączono na tryb automatyczny")
                                   customDial.enabled = false // Wyłączenie możliwości obracania pokrętłem
                               } else {
                                   console.log("Tryb manualny")
                                   customDial.enabled = true // Włączenie możliwości obracania pokrętłem
                               }
                           }
                       }*/
            Rectangle {
                width: 430
                height: 195
                color: "transparent"
                clip: true
                Dial {
                    id: customDial
                    width: 430
                    height: 430
                    //anchors.centerIn: parent
                    from: 60
                    to: 0
                    startAngle: -90
                    endAngle: 90
                    stepSize: 1
                    snapMode: Dial.SnapAlways
                    property int minAngle: -90
                    property int maxAngle: 90;
                    property int currentValue: 0;

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
                        Image {
                            source: "qrc:/images/DialRing.svg"
                            width: parent.width
                            height: parent.height
                            transformOrigin: Item.Center
                            rotation: -customDial.angle // Obrót obrazka w przeciwną stronę do pokrętła
                        }
                    }


                    Button {
                        id: autoButton
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height * 0.25
                        Text {
                            id: valueAuto
                            font.family: font.name
                            // font.styleName: "Bold"
                            //font.bold: true
                            text: "AUTO"
                            font.pixelSize: 24
                            color: "white"
                            anchors.horizontalCenter: parent.horizontalCenter


                        }
                        onClicked: {
                            if (customDial.handle.enabled) {
                                console.log("Przełączono na tryb automatyczny")
                                customDial.handle.enabled = false
                                valueAuto.color = accentColor
                                valueManual.color = textColor
                            } else {
                                console.log("Tryb manualny")
                                customDial.handle.enabled = true
                                valueManual.color = accentColor
                            valueAuto.color = textColor
                            }
                        }
                    }

                    Text {
                        id: valueManual
                        font.family: font.name
                        // font.styleName: "Bold"
                        //font.bold: true
                        text: "MANUAL"// Wyświetlenie aktualnej wartości pokrętła
                        font.pixelSize: 24
                        color: accentColor
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.height * 0.35

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
                       // valueDisplay.text = customDial.value;
                        dialValue = customDial.value;
                        console.log("Nowa wartość:", customDial.value)
                    }}
            }
        }

        Connections {
            target: bledevice
            function onNewData(data) {
                textRX.text = data
                console.log("Read:", data)
                bufforText = data
                var values = bufforText.trim().split(" ");

                if (values.length === 4 && values[0] === "W:") {
                    externalTemperature = parseFloat(values[1]);
                    externalHumidity = parseFloat(values[2]);
                    externalPressure = parseFloat(values[3]);
                } else {
                    console.log("Nieprawidłowy format łańcucha");
                }
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
                timerRunning = true
                console.log("ConnectionStart")
            }
            function onConnectionEnd() {
                timerRunning = false
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
