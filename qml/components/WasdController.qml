import QtQuick
import QtQuick3D

Item {
    id: root

    // Properties
    property Node controlledObject: null // The camera or node to control
    property real speed: 2.0 // Movement speed (units per second)
    property real rotationSpeed: 0.5 // Rotation speed (degrees per pixel)
    property bool enabled: true // Enable/disable input handling

    // Internal state
    QtObject {
        id: internal
        property bool movingForward: false
        property bool movingBackward: false
        property bool movingLeft: false
        property bool movingRight: false
        property bool movingUp: false
        property bool movingDown: false
        property real mouseStartX: 0
        property real mouseStartY: 0
        property bool rotating: false
    }

    // Ensure controlledObject is valid
    onControlledObjectChanged: {
        if (!controlledObject) {
            console.warn("WasdController: controlledObject is null")
        }
    }

    // Keyboard input handling
    focus: enabled // Receive keyboard events when enabled
    Keys.onPressed: (event) => {
        if (!enabled) return
        switch (event.key) {
            case Qt.Key_W: internal.movingForward = true; break
            case Qt.Key_S: internal.movingBackward = true; break
            case Qt.Key_A: internal.movingLeft = true; break
            case Qt.Key_D: internal.movingRight = true; break
            case Qt.Key_Q: internal.movingUp = true; break
            case Qt.Key_E: internal.movingDown = true; break
        }
        event.accepted = true
    }
    Keys.onReleased: (event) => {
        if (!enabled) return
        switch (event.key) {
            case Qt.Key_W: internal.movingForward = false; break
            case Qt.Key_S: internal.movingBackward = false; break
            case Qt.Key_A: internal.movingLeft = false; break
            case Qt.Key_D: internal.movingRight = false; break
            case Qt.Key_Q: internal.movingUp = false; break
            case Qt.Key_E: internal.movingDown = false; break
        }
        event.accepted = true
    }

    // Mouse input for rotation
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        enabled: root.enabled

        onPressed: (mouse) => {
            internal.mouseStartX = mouse.x
            internal.mouseStartY = mouse.y
            internal.rotating = true
            mouse.accepted = true
        }

        onReleased: {
            internal.rotating = false
        }

        onPositionChanged: (mouse) => {
            if (internal.rotating && controlledObject) {
                let deltaX = mouse.x - internal.mouseStartX
                let deltaY = mouse.y - internal.mouseStartY

                // Update yaw (Y-axis rotation)
                controlledObject.eulerRotation.y -= deltaX * rotationSpeed
                // Update pitch (X-axis rotation), clamp to avoid flipping
                let newPitch = controlledObject.eulerRotation.x - deltaY * rotationSpeed
                controlledObject.eulerRotation.x = Math.max(-90, Math.min(90, newPitch))

                internal.mouseStartX = mouse.x
                internal.mouseStartY = mouse.y
            }
        }
    }

    // Timer for continuous movement
    Timer {
        id: movementTimer
        interval: 16 // ~60 FPS
        running: enabled && controlledObject && (
            internal.movingForward || internal.movingBackward ||
            internal.movingLeft || internal.movingRight ||
            internal.movingUp || internal.movingDown)
        repeat: true

        onTriggered: {
            if (!controlledObject) return

            let deltaTime = interval / 1000 // Time in seconds
            let moveVector = Qt.vector3d(0, 0, 0)

            // Forward/backward (along local Z-axis)
            if (internal.movingForward) moveVector.z -= speed * deltaTime
            if (internal.movingBackward) moveVector.z += speed * deltaTime

            // Left/right (along local X-axis)
            if (internal.movingLeft) moveVector.x -= speed * deltaTime
            if (internal.movingRight) moveVector.x += speed * deltaTime

            // Up/down (along local Y-axis)
            if (internal.movingUp) moveVector.y += speed * deltaTime
            if (internal.movingDown) moveVector.y -= speed * deltaTime

            // Transform movement vector to scene space
            if (moveVector.length() > 0) {
                let sceneMoveVector = controlledObject.mapDirectionToScene(moveVector)
                controlledObject.position = controlledObject.position.plus(sceneMoveVector)
            }
        }
    }
}
