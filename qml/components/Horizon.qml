import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: root
    property real roll: -dashboardWindow.computedRoll
    property real pitch: dashboardWindow.computedYaw

    // Responsive scaling factor
    readonly property real scaleFactor: dashboardWindow.isSmallScreen ? 0.8 : 1.0
    readonly property real fontScale: dashboardWindow.isSmallScreen ? 0.7 : 1.0

    Rectangle {
        id: horizonBackground
        anchors.fill: parent
        color: "#0a0a0a"
        radius: width / 2
        border.color: "#536878"
        border.width: 3 * scaleFactor
        clip: true

        Item {
            id: horizonIndicator
            anchors.centerIn: parent
            width: parent.width * 2 * scaleFactor
            height: parent.height * 2 * scaleFactor
            transform: Rotation {
                origin.x: horizonIndicator.width / 2
                origin.y: horizonIndicator.height / 2
                axis { x: 0; y: 0; z: 1 }
                angle: -pitch
            }
            Rectangle {
                id: sky
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -roll * 2 * scaleFactor
                color: "#87ceeb"
                Rectangle {
                    id: ground
                    width: parent.width
                    height: parent.height / 2
                    anchors.bottom: parent.bottom
                    color: "#155418"
                }
                Repeater {
                    model: 36
                    Rectangle {
                        property int rollAngle: (index - 18) * 5
                        visible: rollAngle !== 0
                        width: rollAngle % 10 === 0 ? parent.width * 0.3 * scaleFactor : parent.width * 0.15 * scaleFactor
                        height: 2 * scaleFactor
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: (parent.height / 2) - (rollAngle * 2 * scaleFactor)
                        Text {
                            visible: rollAngle % 10 === 0
                            anchors.left: parent.right
                            anchors.leftMargin: 5 * scaleFactor
                            anchors.verticalCenter: parent.verticalCenter
                            text: Math.abs(rollAngle).toString()
                            color: "white"
                            font.pixelSize: 12 * fontScale
                        }
                    }
                }
            }
        }

        Canvas {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.6 * scaleFactor
            height: parent.height * 0.2 * scaleFactor
            onPaint: {
                var ctx = getContext("2d");
                var centerX = width / 2;
                var radius = width / 2;
                ctx.beginPath();
                ctx.arc(centerX, height * 1.5, radius, Math.PI, 2 * Math.PI, false);
                ctx.strokeStyle = "white";
                ctx.lineWidth = 2 * scaleFactor;
                ctx.stroke();
                for (var i = -60; i <= 60; i += 10) {
                    var angle = (i * Math.PI / 180) + Math.PI;
                    var markerLength = (i % 30 === 0) ? 15 : 10 * scaleFactor;
                    var startX = centerX + radius * Math.cos(angle);
                    var startY = height * 1.5 + radius * Math.sin(angle);
                    var endX = centerX + (radius - markerLength) * Math.cos(angle);
                    var endY = height * 1.5 + (radius - markerLength) * Math.sin(angle);
                    ctx.beginPath();
                    ctx.moveTo(startX, startY);
                    ctx.lineTo(endX, endY);
                    ctx.strokeStyle = "white";
                    ctx.lineWidth = 2 * scaleFactor;
                    ctx.stroke();
                    if (i % 30 === 0 && i !== 0) {
                        var textX = centerX + (radius - 25 * scaleFactor) * Math.cos(angle);
                        var textY = height * 1.5 + (radius - 25 * scaleFactor) * Math.sin(angle);
                        ctx.fillStyle = "white";
                        ctx.font = (12 * fontScale) + "px Arial";
                        ctx.fillText(Math.abs(i).toString(), textX - 5, textY + 5);
                    }
                }
                var pitchAngle = (pitch * Math.PI / 180) + Math.PI;
                var triangleSize = 10 * scaleFactor;
                var triangleX = centerX + (radius + 5 * scaleFactor) * Math.cos(pitchAngle);
                var triangleY = height * 1.5 + (radius + 5 * scaleFactor) * Math.sin(pitchAngle);
                ctx.beginPath();
                ctx.moveTo(triangleX, triangleY);
                ctx.lineTo(triangleX - triangleSize * Math.cos(pitchAngle - Math.PI/2),
                          triangleY - triangleSize * Math.sin(pitchAngle - Math.PI/2));
                ctx.lineTo(triangleX - triangleSize * Math.cos(pitchAngle + Math.PI/2),
                          triangleY - triangleSize * Math.sin(pitchAngle + Math.PI/2));
                ctx.closePath();
                ctx.fillStyle = "yellow";
                ctx.fill();
            }
        }
    }
}
