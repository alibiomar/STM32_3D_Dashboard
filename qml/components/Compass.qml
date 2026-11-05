import QtQuick
import QtQuick.Controls

Item {
    id: root
    property real yaw: dashboardWindow.computedPitch
    property real prevYaw: 0

    // Responsive scaling factor
    readonly property real scaleFactor: dashboardWindow.isSmallScreen ? 0.8 : 1.0
    readonly property real fontScale: dashboardWindow.isSmallScreen ? 0.7 : 1.0

    Behavior on yaw {
        enabled: Math.abs(yaw - prevYaw) < 90
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    onYawChanged: {
        prevYaw = yaw;
    }

    Rectangle {
        id: compassBackground
        anchors.fill: parent
        color: "#0a0a0a"
        radius: width / 2
        border.color: "#536878"
        border.width: 3 * scaleFactor
        clip: true

        Item {
            id: compassDial
            anchors.centerIn: parent
            width: parent.width * 0.9 * scaleFactor
            height: parent.height * 0.9 * scaleFactor
            transform: Rotation {
                origin.x: compassDial.width / 2
                origin.y: compassDial.height / 2
                axis { x: 0; y: 0; z: 1 }
                angle: yaw
            }

            Repeater {
                model: [
                    { dir: "N", angle: 0 },
                    { dir: "E", angle: 90 },
                    { dir: "S", angle: 180 },
                    { dir: "W", angle: 270 },
                    { dir: "NE", angle: 45 },
                    { dir: "SE", angle: 135 },
                    { dir: "SW", angle: 225 },
                    { dir: "NW", angle: 315 }
                ]

                Text {
                    property real radius: compassDial.width * 0.35
                    property real angleRad: (modelData.angle * Math.PI) / 180
                    x: compassDial.width/2 + radius * Math.sin(angleRad) - width/2
                    y: compassDial.height/2 - radius * Math.cos(angleRad) - height/2
                    text: modelData.dir
                    color: "white"
                    font.pixelSize: (modelData.dir.length === 1 ? 20 : 14) * fontScale
                    font.bold: modelData.dir.length === 1
                }
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    var centerX = width / 2;
                    var centerY = height / 2;
                    var radius = width * 0.45;

                    for (var i = 0; i < 360; i += 5) {
                        var angle = (i * Math.PI) / 180;
                        var markerLength = (i % 10 === 0) ? 15 : 7;
                        if (i % 30 === 0) {
                            ctx.lineWidth = 3 * scaleFactor;
                            markerLength = 20 * scaleFactor;
                        } else {
                            ctx.lineWidth = 1 * scaleFactor;
                        }
                        var startX = centerX + (radius - markerLength) * Math.sin(angle);
                        var startY = centerY - (radius - markerLength) * Math.cos(angle);
                        var endX = centerX + radius * Math.sin(angle);
                        var endY = centerY - radius * Math.cos(angle);
                        ctx.beginPath();
                        ctx.moveTo(startX, startY);
                        ctx.lineTo(endX, endY);
                        ctx.strokeStyle = "white";
                        ctx.stroke();
                        if (i % 30 === 0) {
                            var textRadius = radius - 35 * scaleFactor;
                            var textX = centerX + textRadius * Math.sin(angle);
                            var textY = centerY - textRadius * Math.cos(angle);
                            ctx.fillStyle = "white";
                            ctx.font = (14 * fontScale) + "px Arial";
                            ctx.textAlign = "center";
                            ctx.textBaseline = "middle";
                            ctx.fillText(i.toString(), textX, textY);
                        }
                    }
                }
            }
        }

        Rectangle {
            id: headingIndicator
            width: 20 * scaleFactor
            height: 20 * scaleFactor
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10 * scaleFactor
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.beginPath();
                    ctx.moveTo(width/2, 0);
                    ctx.lineTo(width, height);
                    ctx.lineTo(0, height);
                    ctx.closePath();
                    ctx.fillStyle = "yellow";
                    ctx.fill();
                }
            }
        }


    }
}
