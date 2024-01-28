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
               //source: "file://Users/patrykgruszowski/Inteligentna_Bluza/DialBackground.png"
               sourceSize: Qt.size(parent.width, parent.height) // Dopasowanie rozmiaru obrazu do D
           }
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
        anchors.topMargin: 565
        anchors.bottomMargin: 10
        anchors.leftMargin: 0
        anchors.rightMargin: 0

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
