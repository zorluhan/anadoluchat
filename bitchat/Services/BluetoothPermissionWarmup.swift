import Foundation

#if os(iOS)
import CoreBluetooth

/// Minimal CBCentralManager bootstrap to trigger Bluetooth permission prompt early.
/// Performs a brief scan once the manager is powered on, then stops.
final class BluetoothPermissionWarmup: NSObject, CBCentralManagerDelegate {
    static let shared = BluetoothPermissionWarmup()

    private var central: CBCentralManager?
    private var didScan = false

    func start() {
        if central == nil {
            central = CBCentralManager(delegate: self, queue: nil)
        } else if central?.state == .poweredOn {
            beginScanIfNeeded()
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            beginScanIfNeeded()
        default:
            break
        }
    }

    private func beginScanIfNeeded() {
        guard !didScan, let central = central else { return }
        didScan = true
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        // Stop quickly; goal is only to surface the prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.central?.stopScan()
        }
    }
}
#endif

