import CoreBluetooth

final class CentralManagerDelegate: NSObject, CBCentralManagerDelegate {
	var didUpdateState: (CBCentralManager) -> Void = { _ in }
	var didDiscover: (CBCentralManager, CBPeripheral, [String: Any], NSNumber) -> Void = { _, _, _, _ in }
	var didConnect: (CBCentralManager, CBPeripheral) -> Void = { _, _ in }
	var didDisconnect: (CBCentralManager, CBPeripheral, Error?) -> Void = { _, _, _ in }

	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		didUpdateState(central)
	}

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		didDiscover(central, peripheral, advertisementData, RSSI)
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		didConnect(central, peripheral)
	}

	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		didDisconnect(central, peripheral, error)
	}
}

final class PeripheralDelegate: NSObject, CBPeripheralDelegate {
	var didDiscoverServices: (CBPeripheral, Error?) -> Void = { _, _ in }
	var didDiscoverCharacteristicsFor: (CBPeripheral, CBService, Error?) -> Void = { _, _, _ in }
	var didWriteValue: (CBPeripheral, CBCharacteristic, Error?) -> Void = { _, _, _ in }

	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		didDiscoverServices(peripheral, error)
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		didDiscoverCharacteristicsFor(peripheral, service, error)
	}

	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		didWriteValue(peripheral, characteristic, error)
	}
}
