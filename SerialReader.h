#pragma once
#include <QObject>
#include <QSerialPort>
#include <QDebug>

class SerialReader : public QObject {
    Q_OBJECT
    // QML-exposed properties
    Q_PROPERTY(float q0 READ q0 NOTIFY q0Changed)
    Q_PROPERTY(float q1 READ q1 NOTIFY q1Changed)
    Q_PROPERTY(float q2 READ q2 NOTIFY q2Changed)
    Q_PROPERTY(float q3 READ q3 NOTIFY q3Changed)
    Q_PROPERTY(float accelX READ accelX NOTIFY accelXChanged)
    Q_PROPERTY(float accelY READ accelY NOTIFY accelYChanged)
    Q_PROPERTY(float accelZ READ accelZ NOTIFY accelZChanged)
    Q_PROPERTY(float gyroX READ gyroX NOTIFY gyroXChanged)
    Q_PROPERTY(float gyroY READ gyroY NOTIFY gyroYChanged)
    Q_PROPERTY(float gyroZ READ gyroZ NOTIFY gyroZChanged)

public:
    explicit SerialReader(QObject *parent = nullptr);
    ~SerialReader();

    // Public methods
    Q_INVOKABLE bool openSerial(const QString &portName, int baudRate = 230400);
    Q_INVOKABLE void closeSerial();
    Q_INVOKABLE QStringList getAvailablePorts();

    // Getters for properties
    float q0() const { return m_q0; }
    float q1() const { return m_q1; }
    float q2() const { return m_q2; }
    float q3() const { return m_q3; }
    float accelX() const { return m_accelX; }
    float accelY() const { return m_accelY; }
    float accelZ() const { return m_accelZ; }
    float gyroX() const { return m_gyroX; }
    float gyroY() const { return m_gyroY; }
    float gyroZ() const { return m_gyroZ; }

signals:
    // Signals emitted when data changes
    void newDataReceived();
    void q0Changed();
    void q1Changed();
    void q2Changed();
    void q3Changed();
    void accelXChanged();
    void accelYChanged();
    void accelZChanged();
    void gyroXChanged();
    void gyroYChanged();
    void gyroZChanged();
    void connectionStatusChanged(bool connected, const QString &message);

private slots:
    void readData();
    void handleError(QSerialPort::SerialPortError error);

private:
    QSerialPort *m_serial;
    QByteArray m_buffer;

    // Data fields
    float m_q0 = 0.0f; // Initialize quaternion to identity (1,0,0,0)
    float m_q1 = 0.0f;
    float m_q2 = 0.0f;
    float m_q3 = 0.0f;
    float m_accelX = 0.0f;
    float m_accelY = 0.0f;
    float m_accelZ = 0.0f;
    float m_gyroX = 0.0f;
    float m_gyroY = 0.0f;
    float m_gyroZ = 0.0f;

    void parseData(const QByteArray &data);
    void updateValue(float &target, float newValue, void (SerialReader::*signal)());
};
