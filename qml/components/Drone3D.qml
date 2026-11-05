import QtQuick
import QtQuick3D
import QtQuick.Controls
import QtQuick3D.Helpers
import QtQuick.Layouts

Item {
    id: root
    property real propellerSpeed: 50  // 0-100%
    property bool cameraOrbit: true
    property bool showWireframe: false
    property bool updateTrigger: false

    View3D {
        id: view3D
        anchors.fill: parent
        environment: SceneEnvironment {
            clearColor: "#87ceeb"  // Sky blue
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
            fog: Fog {
                enabled: true
                color: "#a0c0e0"
                depthFar: 1500
                density: 0.3
            }
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 150, 400)
            eulerRotation: Qt.vector3d(-15, 0, 0)
            fieldOfView: 45
        }

        DirectionalLight {
            scale: Qt.vector3d(1500, 1500, 1500)
            eulerRotation.x: -55
            eulerRotation.y: 45
            x: 0
            y: 700
            z: 500
            brightness: 2.5
            ambientColor: Qt.rgba(1, 1, 1, 1.0)
            castsShadow: true
            shadowMapQuality: Light.ShadowMapQualityHigh
            shadowFactor: 50
        }

        PointLight {
            position: Qt.vector3d(0, 200, 0)
            brightness: 1.5
            ambientColor: Qt.rgba(0.15, 0.15, 0.2, 1.0)
        }

        // Ground plane
        Model {
            source: "#Rectangle"
            scale: Qt.vector3d(1500, 1500, 1500)
            position: Qt.vector3d(0, -500, 0)
            eulerRotation: Qt.vector3d(-90, 0, 0)
            materials: PrincipledMaterial {
                baseColor: "#155418"
                roughness: 0.8
            }
            receivesShadows: true
        }

        // Cloud system
        Node {
            id: cloudSystem
            Repeater3D {
                model: 20
                delegate: Node {
                    position: Qt.vector3d(
                        Math.random() * 3000 - 1500,
                        Math.random() * 300 + 500,
                        Math.random() * 3000 - 1500
                    )
                    scale: Qt.vector3d(
                        Math.random() * 2 + 1,
                        Math.random() * 1 + 0.5,
                        Math.random() * 2 + 1
                    )
                    NumberAnimation on position.x {
                        from: position.x
                        to: position.x + 500
                        duration: 60000 + Math.random() * 40000
                        loops: Animation.Infinite
                        running: true
                    }
                    Model {
                        source: "#Sphere"
                        scale: Qt.vector3d(1.0, 0.6, 1.0)
                        position: Qt.vector3d(400, 100, 500)
                        materials: PrincipledMaterial {
                            baseColor: "#ffffff"
                            opacity: 0.75
                            roughness: 0.9
                        }
                    }
                    Model {
                        source: "#Sphere"
                        scale: Qt.vector3d(0.8, 0.5, 0.7)
                        position: Qt.vector3d(300, 100, 200)
                        materials: PrincipledMaterial {
                            baseColor: "#ffffff"
                            opacity: 0.7
                            roughness: 0.9
                        }
                    }
                    Model {
                        source: "#Sphere"
                        scale: Qt.vector3d(0.9, 0.5, 0.8)
                        position: Qt.vector3d(-250, 50, -150)
                        materials: PrincipledMaterial {
                            baseColor: "#ffffff"
                            opacity: 0.8
                            roughness: 0.9
                        }
                    }
                    Model {
                        source: "#Sphere"
                        scale: Qt.vector3d(0.7, 0.4, 0.9)
                        position: Qt.vector3d(150, -100, -300)
                        materials: PrincipledMaterial {
                            baseColor: "#ffffff"
                            opacity: 0.65
                            roughness: 0.9
                        }
                    }
                }
            }
        }

        // Tree system
        Node {
            id: treeSystem
            Repeater3D {
                model: 50
                delegate: Node {
                    property int treeType: Math.floor(Math.random() * 3)
                    position: Qt.vector3d(
                        Math.random() * 2000 - 1000,
                        -495,
                        Math.random() * 2000 - 1000
                    )
                    scale: Qt.vector3d(
                        0.7 + Math.random() * 0.6,
                        0.7 + Math.random() * 0.6,
                        0.7 + Math.random() * 0.6
                    )
                    eulerRotation.y: Math.random() * 360
                    Model {
                        source: "#Cylinder"
                        scale: Qt.vector3d(0.15, 1.2, 0.15)
                        position: Qt.vector3d(0, 60, 0)
                        materials: PrincipledMaterial {
                            baseColor: "#5d4037"
                            roughness: 0.9
                        }
                        receivesShadows: true
                    }
                    Model {
                        source: treeType === 0 ? "#Cone" : (treeType === 1 ? "#Sphere" : "#Cube")
                        scale: {
                            if (treeType === 0)
                                return Qt.vector3d(0.8, 2.0, 0.8);
                            else if (treeType === 1)
                                return Qt.vector3d(1.0, 1.0, 1.0);
                            else
                                return Qt.vector3d(0.8, 0.8, 0.8);
                        }
                        position: {
                            if (treeType === 0)
                                return Qt.vector3d(0, 170, 0);
                            else if (treeType === 1)
                                return Qt.vector3d(0, 140, 0);
                            else
                                return Qt.vector3d(0, 140, 0);
                        }
                        materials: PrincipledMaterial {
                            baseColor: {
                                if (treeType === 0)
                                    return "#2e7d32";
                                else if (treeType === 1)
                                    return "#43a047";
                                else
                                    return "#66bb6a";
                            }
                            roughness: 0.8
                        }
                        receivesShadows: true
                    }
                    Model {
                        visible: treeType === 0
                        source: "#Cone"
                        scale: Qt.vector3d(0.95, 1.5, 0.95)
                        position: Qt.vector3d(0, 120, 0)
                        materials: PrincipledMaterial {
                            baseColor: "#2e7d32"
                            roughness: 0.8
                        }
                        receivesShadows: true
                    }
                    Model {
                        visible: treeType === 1
                        source: "#Sphere"
                        scale: Qt.vector3d(0.7, 0.7, 0.7)
                        position: Qt.vector3d(0, 190, 0)
                        materials: PrincipledMaterial {
                            baseColor: "#43a047"
                            roughness: 0.8
                        }
                        receivesShadows: true
                    }
                }
            }
        }

        // Main drone
        Node {
            id: droneNode
            position: Qt.vector3d(0, 0, 0)
            rotation: Qt.quaternion(serialReader.q0, serialReader.q1, serialReader.q2, serialReader.q3)
            // Drone body
            Model {
                source: "#Cube"
                position: Qt.vector3d(0, 0, 0)
                scale: Qt.vector3d(1.5, 0.3, 1.5)
                materials: PrincipledMaterial {
                    baseColor: "#e0e0e0"
                    metalness: 0.5
                    roughness: 0.3
                }
                receivesShadows: true
            }

            // Drone label
            Model {
                id: droneLabel
                source: "#Cube"
                position: Qt.vector3d(0, 10, 0)
                scale: Qt.vector3d(1.3, 0.4, 1.3)
                materials: PrincipledMaterial {
                    baseColor: "#ffffff"
                    metalness: 0.5
                    roughness: 0.3
                }
            }

            // Status bar
            Model {
                id: statusBar
                source: "#Cube"
                position: Qt.vector3d(0, 5, 0)
                scale: Qt.vector3d(1.51, 0.07, 1.7)
                materials: PrincipledMaterial {
                    baseColor: "#dd0000"
                    metalness: 0.5
                    roughness: 0.3
                }
            }

            // Arms
            Node {
                id: armsNode
                Model {
                    source: "#Cube"
                    position: Qt.vector3d(55, -10, 55)
                    scale: Qt.vector3d(0.25, 0.1, 2)
                    eulerRotation: Qt.vector3d(0, 45, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Model {
                    source: "#Cube"
                    position: Qt.vector3d(-55, -10, 55)
                    scale: Qt.vector3d(0.25, 0.1, 2)
                    eulerRotation: Qt.vector3d(0, -45, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Model {
                    source: "#Cube"
                    position: Qt.vector3d(55, -10, -55)
                    scale: Qt.vector3d(0.25, 0.1, 2)
                    eulerRotation: Qt.vector3d(0, -45, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Model {
                    source: "#Cube"
                    position: Qt.vector3d(-55, -10, -55)
                    scale: Qt.vector3d(0.25, 0.1, 2)
                    eulerRotation: Qt.vector3d(0, 45, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
            }

            // Four motor/propeller assemblies
            // Front-right
            Node {
                position: Qt.vector3d(110, 0, 110)
                Model {
                    id: motorFR
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.4, 0.25, 0.4)
                    position: Qt.vector3d(0, -10, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.2, 0.3, 0.2)
                    position: Qt.vector3d(0, 0, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#252525"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Node {
                    id: propFRNode
                    position: Qt.vector3d(0, 10, 0)
                    NumberAnimation on eulerRotation.y {
                        running: propellerSpeed > 0
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1000 - (propellerSpeed * 8)
                    }
                    Model {
                        id: propFR
                        source: "#Cube"
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                    Model {
                        source: "#Cube"
                        eulerRotation: Qt.vector3d(0, 90, 0)
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                }
            }

            // Front-left
            Node {
                position: Qt.vector3d(-110, 0, 110)
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.4, 0.25, 0.4)
                    position: Qt.vector3d(0, -10, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.2, 0.3, 0.2)
                    position: Qt.vector3d(0, 0, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#252525"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Node {
                    id: propFLNode
                    position: Qt.vector3d(0, 10, 0)
                    NumberAnimation on eulerRotation.y {
                        running: propellerSpeed > 0
                        loops: Animation.Infinite
                        from: 360
                        to: 0
                        duration: 1000 - (propellerSpeed * 8)
                    }
                    Model {
                        id: propFL
                        source: "#Cube"
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                    Model {
                        source: "#Cube"
                        eulerRotation: Qt.vector3d(0, 90, 0)
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                }
            }

            // Back-right
            Node {
                position: Qt.vector3d(110, 0, -110)
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.4, 0.25, 0.4)
                    position: Qt.vector3d(0, -10, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.2, 0.3, 0.2)
                    position: Qt.vector3d(0, 0, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#252525"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Node {
                    id: propBRNode
                    position: Qt.vector3d(0, 10, 0)
                    NumberAnimation on eulerRotation.y {
                        running: propellerSpeed > 0
                        loops: Animation.Infinite
                        from: 360
                        to: 0
                        duration: 1000 - (propellerSpeed * 8)
                    }
                    Model {
                        id: propBR
                        source: "#Cube"
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                    Model {
                        source: "#Cube"
                        eulerRotation: Qt.vector3d(0, 90, 0)
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                }
            }

            // Back-left
            Node {
                position: Qt.vector3d(-110, 0, -110)
                Model {
                    source: "#Cube"
                    scale: Qt.vector3d(0.4, 0.25, 0.4)
                    position: Qt.vector3d(0, -10, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#dd0000"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(0.2, 0.3, 0.2)
                    position: Qt.vector3d(0, 0, 0)
                    materials: PrincipledMaterial {
                        baseColor: "#252525"
                        metalness: 0.5
                        roughness: 0.3
                    }
                }
                Node {
                    id: propBLNode
                    position: Qt.vector3d(0, 10, 0)
                    NumberAnimation on eulerRotation.y {
                        running: propellerSpeed > 0
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1000 - (propellerSpeed * 8)
                    }
                    Model {
                        id: propBL
                        source: "#Cube"
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                    Model {
                        source: "#Cube"
                        eulerRotation: Qt.vector3d(0, 90, 0)
                        scale: Qt.vector3d(1, 0.05, 0.15)
                        materials: PrincipledMaterial {
                            baseColor: "#444444"
                            metalness: 0.4
                            roughness: 0.3
                        }
                    }
                }
            }

            // LED navigation lights
            Model {
                source: "#Sphere"
                position: Qt.vector3d(120, 0, 120)
                scale: Qt.vector3d(0.1, 0.1, 0.1)
                materials: PrincipledMaterial {
                    baseColor: "#00ff00" // Green - Right
                    emissiveFactor: Qt.vector3d(0.5, 2.0, 0.5)
                }
            }
            Model {
                source: "#Sphere"
                position: Qt.vector3d(-120, 0, 120)
                scale: Qt.vector3d(0.1, 0.1, 0.1)
                materials: PrincipledMaterial {
                    baseColor: "#ff0000" // Red - Left
                    emissiveFactor: Qt.vector3d(2.0, 0.5, 0.5)
                }
            }

            // Coordinate system indicators
            Node {
                id: coordinateSystem
                Model {
                    source: "#Cube"
                    scale: Qt.vector3d(100, 0.02, 0.02)
                    materials: DefaultMaterial {
                        diffuseColor: "#FF0000"
                    }
                }
                Model {
                    source: "#Cube"
                    scale: Qt.vector3d(0.02, 0.02, 100)
                    materials: DefaultMaterial {
                        diffuseColor: "#FFFF00"
                    }
                }
                Model {
                    source: "#Cube"
                    scale: Qt.vector3d(0.02, 100, 0.02)
                    materials: DefaultMaterial {
                        diffuseColor: "#0000FF"
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: true
            property point lastPos: "0,0"
            onPressed: lastPos = Qt.point(mouseX, mouseY)
            onPositionChanged: if (pressed) {
                camera.eulerRotation.x -= (mouseY - lastPos.y) * 0.5
                camera.eulerRotation.y -= (mouseX - lastPos.x) * 0.5
                lastPos = Qt.point(mouseX, mouseY)
            }
            onWheel: camera.position.z = Math.max(100, Math.min(1000, camera.position.z + wheel.angleDelta.y * 0.1))
        }

        WasdController {
            controlledObject: camera
            speed: 2.0
            enabled: true
        }

}
}
