#include "SerialReader.h"
#include <QSerialPortInfo>
#include <cmath>

SerialReader::SerialReader(QObject *parent) : QObject(parent), m_serial(new QSerialPort(this)) {
    connect(m_serial, &QSerialPort::readyRead, this, &SerialReader::readData);
    connect(m_serial, &QSerialPort::errorOccurred, this, &SerialReader::handleError);
}

SerialReader::~SerialReader() {
    if (m_serial->isOpen()) {
        m_serial->close();
    }
}

bool SerialReader::openSerial(const QString &portName, int baudRate) {
    if (m_serial->isOpen()) {
        m_serial->close();
    }
    m_serial->setPortName(portName);
    m_serial->setBaudRate(baudRate);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);
    if (m_serial->open(QIODevice::ReadOnly)) {
        m_buffer.clear();
        emit connectionStatusChanged(true, "Connected to " + portName);
        return true;
    } else {
        emit connectionStatusChanged(false, "Failed to connect: " + m_serial->errorString());
        return false;
    }
}

void SerialReader::closeSerial() {
    if (m_serial->isOpen()) {
        m_serial->close();
        emit connectionStatusChanged(false, "Disconnected");
    }
}

QStringList SerialReader::getAvailablePorts() {
    QStringList ports;
    const auto serialPortInfos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : serialPortInfos) {
        ports << info.portName();
    }
    return ports;
}

void SerialReader::readData() {
    m_buffer.append(m_serial->readAll());
    int newlineIndex;
    while ((newlineIndex = m_buffer.indexOf('\n')) != -1) {
        QByteArray line = m_buffer.left(newlineIndex).trimmed();
        m_buffer.remove(0, newlineIndex + 1);
        if (!line.isEmpty()) {
            parseData(line);
        }
    }
}

void SerialReader::parseData(const QByteArray &data) {
    // Expected format: q0,q1,q2,q3,ACCX,ACCY,ACCZ,GYROX,GYROY,GYROZ
    QList<QByteArray> values = data.split(',');
    if (values.size() == 10) {
        bool conversionOk;
        float rawQ0 = values[0].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_q0, rawQ0, &SerialReader::q0Changed);

        float rawQ1 = values[1].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_q1, rawQ1, &SerialReader::q1Changed);

        float rawQ2 = values[2].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_q2, rawQ2, &SerialReader::q2Changed);

        float rawQ3 = values[3].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_q3, rawQ3, &SerialReader::q3Changed);

        float accelX = values[4].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_accelX, accelX, &SerialReader::accelXChanged);

        float accelY = values[5].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_accelY, accelY, &SerialReader::accelYChanged);

        float accelZ = values[6].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_accelZ, accelZ, &SerialReader::accelZChanged);

        float gyroX = values[7].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_gyroX, gyroX, &SerialReader::gyroXChanged);

        float gyroY = values[8].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_gyroY, gyroY, &SerialReader::gyroYChanged);

        float gyroZ = values[9].toFloat(&conversionOk);
        if (conversionOk) updateValue(m_gyroZ, gyroZ, &SerialReader::gyroZChanged);

        emit newDataReceived();
    }
}


void SerialReader::updateValue(float &target, float newValue, void (SerialReader::*signal)()) {
    if (std::abs(target - newValue) > 0.0f) { // Small threshold to avoid noise
        target = newValue;
        emit (this->*signal)();
    }
}

void SerialReader::handleError(QSerialPort::SerialPortError error) {
    if (error != QSerialPort::NoError) {
        emit connectionStatusChanged(false, "Serial error: " + m_serial->errorString());
    }
}
