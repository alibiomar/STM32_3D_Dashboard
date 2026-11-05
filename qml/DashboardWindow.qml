import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "components"

Window {
    id: dashboardWindow
    width: 1920
    height: 768
    visible: true
    title: "PFA 2 - Drone Simulator"
    color: "#121212"  // Darker base background

    Material.theme: Material.Dark
    Material.accent: "#00E5FF"  // Brighter cyan accent
    Material.primary: "#00E5FF"

    property bool isConnected: false
    property bool sidebarCollapsed: false
    property bool isSmallScreen: width < 800  // Property to determine if screen is small

    // Computed Euler angles from quaternion
    property real computedPitch: 0
    property real computedRoll: 0
    property real computedYaw: 0

    // JavaScript helper to compute Euler angles from quaternion
    function computeEulerAngles(q0, q1, q2, q3) {
        // Yaw (z-axis rotation)
        computedYaw = Math.atan2(
            2.0 * (q1 * q2 + q0 * q3),
            q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        ) * (180 / Math.PI);

        // Pitch (y-axis rotation)
        const sinp = 2.0 * (q1 * q3 - q0 * q2);
        if (Math.abs(sinp) >= 1) {
            computedPitch = Math.sign(sinp) * 90; // ±90 degrees
        } else {
            computedPitch = -Math.asin(sinp) * (180 / Math.PI); // Negative to match original
        }

        // Roll (x-axis rotation)
        computedRoll = Math.atan2(
            2.0 * (q0 * q1 + q2 * q3),
            q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        ) * (180 / Math.PI);

    }

    // Update Euler angles when quaternion changes
    Connections {
        target: serialReader
        function onQ0Changed() { computeEulerAngles(serialReader.q0, serialReader.q1, serialReader.q2, serialReader.q3) }
        function onQ1Changed() { computeEulerAngles(serialReader.q0, serialReader.q1, serialReader.q2, serialReader.q3) }
        function onQ2Changed() { computeEulerAngles(serialReader.q0, serialReader.q1, serialReader.q2, serialReader.q3) }
        function onQ3Changed() { computeEulerAngles(serialReader.q0, serialReader.q1, serialReader.q2, serialReader.q3) }
    }

    FontLoader {
        id: digitalFont
        source: "assets/fonts/digital-7.ttf"
    }

    FontLoader {
        id: mainFont
        source: "assets/fonts/Roboto-Regular.ttf"
    }

    FontLoader {
        id: lightFont
        source: "assets/fonts/Roboto-Light.ttf"
    }

    // App header bar
    Rectangle {
        id: headerBar
        width: parent.width
        height: 60
        color: "#1E1E1E"
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 15

            // App logo/title
            Row {
                spacing: 12

                Rectangle {
                    id: menuButton
                    width: 50
                    height: 50
                    color: "transparent"

                    Image {
                        id: logoImage
                        anchors.centerIn: parent
                        source: "assets/icons/logo.png"
                        fillMode: Image.PreserveAspectFit
                        width: parent.width * 0.8
                        height: parent.height * 0.8
                    }
                }

                Text {
                    text: "DRONE SIMULATOR"
                    font.family: mainFont.name
                    font.pixelSize: 18
                    font.bold: true
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { Layout.fillWidth: true }

            // Connection status indicator
            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: isConnected ? "#4CAF50" : "#F44336"
            }

            Text {
                text: isConnected ? "CONNECTED" : "DISCONNECTED"
                font.family: mainFont.name
                font.pixelSize: 14
                color: isConnected ? "#4CAF50" : "#F44336"
            }
        }
    }

    // Main content area with sidebar and panels
    Item {
        id: contentArea
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // Left sidebar for connection settings
        Rectangle {
            id: sidebar
            width: sidebarCollapsed ? 60 : (isSmallScreen ? 180 : 300)
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: "#1E1E1E"

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
            }

            // Sidebar toggle button
            Button {
                id: sidebarToggle
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 8
                width: 30
                height: 30
                z: 1

                background: Rectangle {
                    color: "transparent"
                    radius: 4
                }

                contentItem: Text {
                    text: sidebarCollapsed ? "›" : "‹"
                    font.pixelSize: 40
                    color: "#00E5FF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    sidebarCollapsed = !sidebarCollapsed
                }
            }

            ColumnLayout {
                id: expandedSidebar
                anchors.fill: parent
                anchors.margins: 16
                spacing: 20
                opacity: sidebarCollapsed ? 0 : 1
                visible: !sidebarCollapsed
                enabled: !sidebarCollapsed

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                // Section title
                Text {
                    text: "CONNECTION SETTINGS"
                    color: "#FFFFFF"
                    font.family: mainFont.name
                    font.pixelSize: 14
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                }

                // Serial port selection
                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true

                    Text {
                        text: "Serial Port"
                        color: "#AAAAAA"
                        font.family: mainFont.name
                        font.pixelSize: 12
                    }

                    ComboBox {
                        id: portSelector
                        Layout.fillWidth: true
                        model: serialReader.getAvailablePorts()
                        Material.foreground: "#FFFFFF"
                        font.family: mainFont.name
                        font.pixelSize: 14

                        background: Rectangle {
                            color: "#2A2A2A"
                            radius: 4
                            border.color: "#333333"
                            border.width: 1
                        }
                        contentItem: Text {
                            leftPadding: 10
                            rightPadding: portSelector.indicator.width + 10
                            text: portSelector.displayText
                            font: portSelector.font
                            color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        onPressedChanged: {
                            if (pressed) {
                                model = serialReader.getAvailablePorts()
                            }
                        }
                    }
                }

                // Baud rate selection
                ColumnLayout {
                    spacing: 6
                    Layout.fillWidth: true

                    Text {
                        text: "Baud Rate"
                        color: "#AAAAAA"
                        font.family: mainFont.name
                        font.pixelSize: 12
                    }

                    ComboBox {
                        id: baudSelector
                        Layout.fillWidth: true
                        model: ["9600", "19200", "38400", "57600", "115200", "230400"]
                        currentIndex: 4
                        Material.foreground: "#FFFFFF"
                        font.family: mainFont.name
                        font.pixelSize: 14
                        contentItem: Text {
                            leftPadding: 10
                            rightPadding: baudSelector.indicator.width + 10
                            text: baudSelector.displayText
                            font: baudSelector.font
                            color: "#FFFFFF"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            color: "#2A2A2A"
                            radius: 4
                            border.color: "#333333"
                            border.width: 1
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Connection buttons
                Button {
                    id: connectButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    text: isConnected ? "DISCONNECT" : "CONNECT"
                    font.family: mainFont.name
                    font.pixelSize: 13
                    font.bold: true

                    background: Rectangle {
                        color: isConnected ? "#B71C1C" : "#00796B"
                        radius: 4

                        Rectangle {
                            width: parent.width
                            height: 2
                            color: isConnected ? "#F44336" : "#00E5FF"
                            anchors.bottom: parent.bottom
                        }
                    }

                    onClicked: {
                        if (!isConnected) {
                            isConnected = serialReader.openSerial(portSelector.currentText, parseInt(baudSelector.currentText))
                        } else {
                            serialReader.closeSerial()
                            isConnected = false
                        }
                    }
                }

                Button {
                    id: refreshButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    Layout.bottomMargin: 8
                    text: "REFRESH PORTS"
                    font.family: mainFont.name
                    font.pixelSize: 13

                    background: Rectangle {
                        color: "#2A2A2A"
                        radius: 4
                    }

                    onClicked: {
                        portSelector.model = serialReader.getAvailablePorts()
                    }
                }
            }

            // Collapsed sidebar content
            ColumnLayout {
                id: collapsedSidebar
                anchors.fill: parent
                anchors.topMargin: 60
                spacing: 20
                visible: sidebarCollapsed
                enabled: sidebarCollapsed
                opacity: sidebarCollapsed ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                // Vertical text for collapsed sidebar
                Text {
                    text: "CONNECTION"
                    color: "#FFFFFF"
                    font.family: mainFont.name
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                    rotation: -90
                    Layout.topMargin: 40
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: isConnected ? "#00796B" : "#2A2A2A"
                    border.color: isConnected ? "#00E5FF" : "#444444"
                    border.width: 1
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        anchors.centerIn: parent
                        text: isConnected ? "D" : "C"
                        color: "#FFFFFF"
                        font.family: mainFont.name
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!isConnected) {
                                isConnected = serialReader.openSerial(portSelector.currentText, parseInt(baudSelector.currentText))
                            } else {
                                serialReader.closeSerial()
                                isConnected = false
                            }
                        }
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: "#2A2A2A"
                    border.color: "#444444"
                    border.width: 1
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        anchors.centerIn: parent
                        text: "R"
                        color: "#FFFFFF"
                        font.family: mainFont.name
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            portSelector.model = serialReader.getAvailablePorts()
                        }
                    }
                }
            }
        }

        // Main dashboard panels
        Item {
            id: mainDashboard
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            // Main content grid
            Item {
                id: dashboardContent
                anchors.fill: parent
                anchors.margins: 20

                // ScrollView for small screens
                ScrollView {
                    anchors.fill: parent
                    visible: isSmallScreen
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    ColumnLayout {
                        width: dashboardContent.width - 40  // Account for margins
                        spacing: 20

                        // 3D Model - fixed height
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            color: "#1E1E1E"
                            radius: 8
                            layer.enabled: true

                            // Panel header
                            Rectangle {
                                id: modelHeaderSmall
                                height: 40
                                width: parent.width
                                color: "#252525"
                                radius: 8

                                Rectangle {
                                    width: parent.width
                                    height: parent.height - radius
                                    color: parent.color
                                    anchors.bottom: parent.bottom
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15

                                    Text {
                                        text: "3D MODEL"
                                        color: "#FFFFFF"
                                        font.family: mainFont.name
                                        font.pixelSize: 14
                                        font.bold: true
                                    }

                                    Item { Layout.fillWidth: true }

                                }
                            }

                            Drone3D {
                                anchors.fill: parent
                                anchors.topMargin: modelHeaderSmall.height
                                anchors.margins: 15
                                propellerSpeed: 80
                                property bool updateTrigger: false
                            }
                        }

                        // Instruments panel - increased fixed height
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 350  // Increased from 250 to 350
                            color: "#1E1E1E"
                            radius: 8
                            layer.enabled: true

                            // Panel header
                            Rectangle {
                                id: instrumentsHeaderSmall
                                height: 40
                                width: parent.width
                                color: "#252525"
                                radius: 8

                                Rectangle {
                                    width: parent.width
                                    height: parent.height - radius
                                    color: parent.color
                                    anchors.bottom: parent.bottom
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "FLIGHT INSTRUMENTS"
                                    color: "#FFFFFF"
                                    font.family: mainFont.name
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            // Instrument contents
                            RowLayout {
                                anchors.fill: parent
                                anchors.topMargin: instrumentsHeaderSmall.height + 15
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15
                                anchors.bottomMargin: 15
                                spacing: 15

                                // Attitude indicator
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "#252525"
                                    radius: 8

                                    Text {
                                        anchors.top: parent.top
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.topMargin: 10
                                        text: "ATTITUDE"
                                        color: "#AAAAAA"
                                        font.family: mainFont.name
                                        font.pixelSize: 12
                                    }

                                    Horizon {
                                        anchors.fill: parent
                                        anchors.margins: 30
                                    }

                                    // Digital readout
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottomMargin: 10
                                        width: 80
                                        height: 30
                                        color: "#1A1A1A"
                                        radius: 4

                                        Text {
                                            anchors.centerIn: parent
                                            text: computedYaw.toFixed(1) + "°"
                                            color: "#00E5FF"
                                            font.family: digitalFont.name
                                            font.pixelSize: 16
                                        }
                                    }
                                }

                                // Heading indicator
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "#252525"
                                    radius: 8

                                    Text {
                                        anchors.top: parent.top
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.topMargin: 10
                                        text: "HEADING"
                                        color: "#AAAAAA"
                                        font.family: mainFont.name
                                        font.pixelSize: 12
                                    }

                                    Compass {
                                        anchors.fill: parent
                                        anchors.margins: 30
                                    }

                                    // Digital readout
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottomMargin: 10
                                        width: 80
                                        height: 30
                                        color: "#1A1A1A"
                                        radius: 4

                                        Text {
                                            anchors.centerIn: parent
                                            text: {
                                                let displayYaw = -computedPitch;
                                                while (displayYaw < 0) displayYaw += 360;
                                                while (displayYaw >= 360) displayYaw -= 360;
                                                return displayYaw.toFixed(1) + "°";
                                            }
                                            color: "#00E5FF"
                                            font.family: digitalFont.name
                                            font.pixelSize: 16
                                        }
                                    }
                                }
                            }
                        }

                        // Sensor data panel - increased fixed height
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 600  // Increased from 400 to 600
                            color: "#1E1E1E"
                            radius: 8
                            layer.enabled: true

                            // Panel header
                            Rectangle {
                                id: sensorHeaderSmall
                                height: 40
                                width: parent.width
                                color: "#252525"
                                radius: 8

                                Rectangle {
                                    width: parent.width
                                    height: parent.height - radius
                                    color: parent.color
                                    anchors.bottom: parent.bottom
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 15
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "SENSOR DATA"
                                    color: "#FFFFFF"
                                    font.family: mainFont.name
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }

                            Gauges {
                                anchors.fill: parent
                                anchors.topMargin: sensorHeaderSmall.height + 10
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15
                                anchors.bottomMargin: 15
                                accelX: isNaN(serialReader.accelX) ? 0 : serialReader.accelX
                                accelY: isNaN(serialReader.accelY) ? 0 : serialReader.accelY
                                accelZ: isNaN(serialReader.accelZ) ? 0 : serialReader.accelZ
                                gyroX: isNaN(serialReader.gyroX) ? 0 : serialReader.gyroX
                                gyroY: isNaN(serialReader.gyroY) ? 0 : serialReader.gyroY
                                gyroZ: isNaN(serialReader.gyroZ) ? 0 : serialReader.gyroZ
                            }
                        }
                    }
                }

                // Original GridLayout for large screens
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    rowSpacing: 20
                    columnSpacing: 20
                    visible: !isSmallScreen

                    // 3D Model
                    Rectangle {
                        Layout.row: 0
                        Layout.column: 0
                        Layout.columnSpan: 1
                        Layout.rowSpan: 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1E1E1E"
                        radius: 8
                        layer.enabled: true

                        // Panel header
                        Rectangle {
                            id: modelHeader
                            height: 40
                            width: parent.width
                            color: "#252525"
                            radius: 8

                            Rectangle {
                                width: parent.width
                                height: parent.height - radius
                                color: parent.color
                                anchors.bottom: parent.bottom
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15

                                Text {
                                    text: "3D MODEL"
                                    color: "#FFFFFF"
                                    font.family: mainFont.name
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                Item { Layout.fillWidth: true }


                            }
                        }

                        Timer {
                            interval: 16
                            running: true
                            repeat: true
                            onTriggered: {
                                drone3D.updateTrigger = !drone3D.updateTrigger
                            }
                        }

                        Drone3D {
                            id: drone3D
                            anchors.fill: parent
                            anchors.topMargin: modelHeader.height
                            anchors.margins: 15
                            propellerSpeed: 80  // Set default speed
                            property bool updateTrigger: false
                        }
                    }

                    // Instruments panel
                    Rectangle {
                        Layout.row: 0
                        Layout.column: 1
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.45
                        color: "#1E1E1E"
                        radius: 8
                        layer.enabled: true

                        // Panel header
                        Rectangle {
                            id: instrumentsHeader
                            height: 40
                            width: parent.width
                            color: "#252525"
                            radius: 8

                            Rectangle {
                                width: parent.width
                                height: parent.height - radius
                                color: parent.color
                                anchors.bottom: parent.bottom
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 15
                                anchors.verticalCenter: parent.verticalCenter
                                text: "FLIGHT INSTRUMENTS"
                                color: "#FFFFFF"
                                font.family: mainFont.name
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        // Instrument contents
                        RowLayout {
                            anchors.fill: parent
                            anchors.topMargin: instrumentsHeader.height + 15
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            anchors.bottomMargin: 15
                            spacing: 15

                            // Attitude indicator
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "#252525"
                                radius: 8

                                Text {
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.topMargin: 10
                                    text: "ATTITUDE"
                                    color: "#AAAAAA"
                                    font.family: mainFont.name
                                    font.pixelSize: 12
                                }

                                Horizon {
                                    anchors.fill: parent
                                    anchors.margins: 30
                                }

                                // Digital readout
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: 10
                                    width: 80
                                    height: 30
                                    color: "#1A1A1A"
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: computedYaw.toFixed(1) + "°"
                                        color: "#00E5FF"
                                        font.family: digitalFont.name
                                        font.pixelSize: 16
                                    }
                                }
                            }

                            // Heading indicator
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "#252525"
                                radius: 8

                                Text {
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.topMargin: 10
                                    text: "HEADING"
                                    color: "#AAAAAA"
                                    font.family: mainFont.name
                                    font.pixelSize: 12
                                }

                                Compass {
                                    anchors.fill: parent
                                    anchors.margins: 30
                                }

                                // Digital readout
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: 10
                                    width: 80
                                    height: 30
                                    color: "#1A1A1A"
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            let displayYaw = -computedPitch;
                                            while (displayYaw < 0) displayYaw += 360;
                                            while (displayYaw >= 360) displayYaw -= 360;
                                            return displayYaw.toFixed(1) + "°";
                                        }
                                        color: "#00E5FF"
                                        font.family: digitalFont.name
                                        font.pixelSize: 16
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.row: 1
                        Layout.column: 1
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1E1E1E"
                        radius: 8
                        layer.enabled: true

                        // Panel header
                        Rectangle {
                            id: sensorHeader
                            height: 40
                            width: parent.width
                            color: "#252525"
                            radius: 8

                            Rectangle {
                                width: parent.width
                                height: parent.height - radius
                                color: parent.color
                                anchors.bottom: parent.bottom
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 15
                                anchors.verticalCenter: parent.verticalCenter
                                text: "SENSOR DATA"
                                color: "#FFFFFF"
                                font.family: mainFont.name
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        Gauges {
                            anchors.fill: parent
                            anchors.topMargin: sensorHeader.height + 10
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            anchors.bottomMargin: 15
                            accelX: isNaN(serialReader.accelX) ? 0 : serialReader.accelX
                            accelY: isNaN(serialReader.accelY) ? 0 : serialReader.accelY
                            accelZ: isNaN(serialReader.accelZ) ? 0 : serialReader.accelZ
                            gyroX: isNaN(serialReader.gyroX) ? 0 : serialReader.gyroX
                            gyroY: isNaN(serialReader.gyroY) ? 0 : serialReader.gyroY
                            gyroZ: isNaN(serialReader.gyroZ) ? 0 : serialReader.gyroZ
                        }
                    }}
            }

            // Status bar at the bottom
            Rectangle {
                id: statusBar
                height: 28
                width: parent.width
                color: "#1A1A1A"
                anchors.bottom: parent.bottom

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20

                    Text {
                        id: statusMessage
                        text: "Ready"
                        color: isConnected ? "#00E5FF" : "#AAAAAA"
                        font.family: mainFont.name
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                        color: "#AAAAAA"
                        font.family: mainFont.name
                        font.pixelSize: 12

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
                        }
                    }
                }
            }
        }

        // Window resize handling
        onWidthChanged: {
            // Update responsive layout when window size changes
            isSmallScreen = width < 800
            // Auto-collapse sidebar on small screens
            if (isSmallScreen && !sidebarCollapsed) {
                sidebarCollapsed = true
            }
        }

        Connections {
            target: serialReader
            function onConnectionStatusChanged(connected, message) {
                isConnected = connected
                statusMessage.text = message
                statusMessage.color = connected ? "#00E5FF" : "#F44336"
            }
        }
    }
}
