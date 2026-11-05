import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    // Properties to receive sensor data
    property real accelX: 0
    property real accelY: 0
    property real accelZ: 0
    property real gyroX: 0
    property real gyroY: 0
    property real gyroZ: 0

    // Responsive properties
    readonly property real scaleFactor:  1.0
    readonly property real fontScale:  1.0

    ColumnLayout {
        anchors.fill: parent
        spacing: 10 * scaleFactor

        // Accelerometer gauges
        GroupBox {
            title: "Accelerometer (g)"
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.45

            background: Rectangle {
                color: "#0a0a0a"
                border.color: "#536878"
                border.width: 1 * scaleFactor
                radius: 5 * scaleFactor
            }

            label: Text {
                color: "white"
                text: parent.title
                font.bold: true
                font.pixelSize: 14 * fontScale
            }


            GridLayout {
                anchors.fill: parent
                columns: 3
                rows: 2

                // X axis gauge
                CircularGauge {
                    id: accelXGaugeLarge
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: accelX
                    from: -3
                    to: 3
                    axisName: "X"
                }

                // Y axis gauge
                CircularGauge {
                    id: accelYGaugeLarge
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: accelY
                    from: -3
                    to: 3
                    axisName: "Y"
                }

                // Z axis gauge
                CircularGauge {
                    id: accelZGaugeLarge
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: accelZ
                    from: -3
                    to: 3
                    axisName: "Z"
                }
            }
        }

        // Gyroscope gauges
        GroupBox {
            title: "Gyroscope (°/s)"
            Layout.fillWidth: true
            Layout.fillHeight: true

            background: Rectangle {
                color: "#0a0a0a"
                border.color: "#536878"
                border.width: 1 * scaleFactor
                radius: 5 * scaleFactor
            }

            label: Text {
                color: "white"
                text: parent.title
                font.bold: true
                font.pixelSize: 14 * fontScale
            }



            GridLayout {
                anchors.fill: parent
                columns: 3
                rows: 1

                // X axis gauge
                CircularGauge {
                    id: gyroXGaugeLarge
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: gyroX
                    from: -180
                    to: 180
                    axisName: "X"
                }

                // Y axis gauge
                CircularGauge {
                    id: gyroYGaugeLarge
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: gyroY
                    from: -180
                    to: 180
                    axisName: "Y"
                }

                // Z axis gauge
                CircularGauge {
                    id: gyroZGaugeLarge
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    value: gyroZ
                    from: -180
                    to: 180
                    axisName: "Z"
                }
            }
        }
    }

    // Custom circular gauge component
    component CircularGauge: Item {
        id: gauge

        property real value: 0
        property real from: -1
        property real to: 1
        property string axisName: ""

        Rectangle {
            id: background
            anchors.fill: parent
            color: "transparent"
            border.color: "#536878"
            border.width: 1 * scaleFactor
            radius: width / 2

            Canvas {
                id: gaugeCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    var centerX = width / 2;
                    var centerY = height / 2;
                    var radius = Math.min(width, height) / 2 - 5 * scaleFactor;

                    // Draw gauge background
                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                    ctx.strokeStyle = "#536878";
                    ctx.lineWidth = 2 * scaleFactor;
                    ctx.stroke();

                    // Draw value needle
                    var valueRange = gauge.to - gauge.from;
                    var valueAngle = (gauge.value - gauge.from) / valueRange * 2 * Math.PI;

                    ctx.beginPath();
                    ctx.moveTo(centerX, centerY);
                    ctx.lineTo(
                        centerX + radius * 0.8 * Math.cos(valueAngle - Math.PI/2),
                        centerY + radius * 0.8 * Math.sin(valueAngle - Math.PI/2)
                    );
                    ctx.strokeStyle = "#ff3e4d";
                    ctx.lineWidth = 3 * scaleFactor;
                    ctx.stroke();

                    // Draw marks
                    for (var i = 0; i <= 8; i++) {
                        var angle = i / 8 * 2 * Math.PI;
                        var markLength = (i % 2 === 0) ? 15 : 10 * scaleFactor;

                        ctx.beginPath();
                        ctx.moveTo(
                            centerX + (radius - markLength) * Math.cos(angle - Math.PI/2),
                            centerY + (radius - markLength) * Math.sin(angle - Math.PI/2)
                        );
                        ctx.lineTo(
                            centerX + radius * Math.cos(angle - Math.PI/2),
                            centerY + radius * Math.sin(angle - Math.PI/2)
                        );
                        ctx.strokeStyle = "white";
                        ctx.lineWidth = (i % 2 === 0) ? 2 * scaleFactor : 1 * scaleFactor;
                        ctx.stroke();

                        if (i % 2 === 0) {
                            var markValue = gauge.from + (i / 8) * valueRange;
                            var textX = centerX + (radius - 25 * scaleFactor) * Math.cos(angle - Math.PI/2);
                            var textY = centerY + (radius - 25 * scaleFactor) * Math.sin(angle - Math.PI/2);

                            ctx.fillStyle = "white";
                            ctx.font = (10 * fontScale) + "px Arial";
                            ctx.textAlign = "center";
                            ctx.textBaseline = "middle";
                            ctx.fillText(markValue.toFixed(0), textX, textY);
                        }
                    }
                }

                Connections {
                    target: gauge
                    function onValueChanged() { gaugeCanvas.requestPaint() }
                }

                Component.onCompleted: requestPaint()
            }

            // Center text
            Column {
                anchors.centerIn: parent
                spacing: 2 * scaleFactor

                Text {
                    text: gauge.axisName
                    color: "white"
                    font.pixelSize: 14 * fontScale
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: gauge.value.toFixed(2)
                    color: "#00ff00"
                    font.pixelSize: 12 * fontScale
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
