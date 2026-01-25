import Flutter
import UIKit
import NetworkExtension
import CoreTelephony
import SystemConfiguration.CaptiveNetwork

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let channelName = "com.xenosignal/signal"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        setupMethodChannel()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupMethodChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }

        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "Handler unavailable", details: nil))
                return
            }

            switch call.method {
            case "getWifiSignal":
                self.getWifiSignal(result: result)
            case "getCellularSignal":
                self.getCellularSignal(result: result)
            case "isWifiEnabled":
                self.isWifiEnabled(result: result)
            case "isCellularEnabled":
                self.isCellularEnabled(result: result)
            case "getConnectionType":
                self.getConnectionType(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - WiFi Signal

    private func getWifiSignal(result: @escaping FlutterResult) {
        // iOS restricts direct WiFi signal strength access
        // NEHotspotNetwork provides limited info with Location permission
        // Using fallback approach - Dart layer will use ping-based measurement

        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { network in
                guard let network = network else {
                    result(nil)
                    return
                }

                // iOS doesn't provide dBm directly
                // signalStrength is 0.0-1.0 but only available with special entitlement
                let signalData: [String: Any?] = [
                    "dbm": nil, // Not available on iOS
                    "networkName": network.ssid,
                    "connectionType": "WiFi",
                    "latencyMs": nil,
                    "location": nil
                ]

                result(signalData)
            }
        } else {
            // Fallback for older iOS versions using deprecated CNCopyCurrentNetworkInfo
            if let ssid = self.getWifiSSIDLegacy() {
                let signalData: [String: Any?] = [
                    "dbm": nil,
                    "networkName": ssid,
                    "connectionType": "WiFi",
                    "latencyMs": nil,
                    "location": nil
                ]
                result(signalData)
            } else {
                result(nil)
            }
        }
    }

    private func getWifiSSIDLegacy() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }

        for interface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                  let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            return ssid
        }
        return nil
    }

    // MARK: - Cellular Signal

    private func getCellularSignal(result: @escaping FlutterResult) {
        let networkInfo = CTTelephonyNetworkInfo()

        // Get carrier info
        var carrierName: String? = nil
        var connectionType: String? = nil

        if #available(iOS 12.0, *) {
            if let carriers = networkInfo.serviceSubscriberCellularProviders {
                carrierName = carriers.values.first?.carrierName
            }
            if let radioTypes = networkInfo.serviceCurrentRadioAccessTechnology {
                connectionType = self.radioAccessToString(radioTypes.values.first)
            }
        } else {
            carrierName = networkInfo.subscriberCellularProvider?.carrierName
            connectionType = self.radioAccessToString(networkInfo.currentRadioAccessTechnology)
        }

        // iOS doesn't provide cellular dBm without private APIs
        let signalData: [String: Any?] = [
            "dbm": nil, // Not available on iOS
            "networkName": carrierName,
            "connectionType": connectionType,
            "latencyMs": nil,
            "location": nil
        ]

        result(signalData)
    }

    private func radioAccessToString(_ technology: String?) -> String {
        guard let tech = technology else { return "Unknown" }

        switch tech {
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
            return "5G"
        case CTRadioAccessTechnologyLTE:
            return "LTE"
        case CTRadioAccessTechnologyeHRPD,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyWCDMA:
            return "3G"
        case CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyCDMA1x:
            return "2G"
        default:
            return "Unknown"
        }
    }

    // MARK: - Connection State

    private func isWifiEnabled(result: @escaping FlutterResult) {
        // Check if WiFi interface is active
        // This is a simplified check - full implementation would use Reachability
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { network in
                result(network != nil)
            }
        } else {
            result(self.getWifiSSIDLegacy() != nil)
        }
    }

    private func isCellularEnabled(result: @escaping FlutterResult) {
        let networkInfo = CTTelephonyNetworkInfo()

        if #available(iOS 12.0, *) {
            let hasRadio = networkInfo.serviceCurrentRadioAccessTechnology?.isEmpty == false
            result(hasRadio)
        } else {
            result(networkInfo.currentRadioAccessTechnology != nil)
        }
    }

    private func getConnectionType(result: @escaping FlutterResult) {
        // Check WiFi first, then cellular
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { [weak self] network in
                if network != nil {
                    result("WiFi")
                } else {
                    // Check cellular
                    let networkInfo = CTTelephonyNetworkInfo()
                    if #available(iOS 12.0, *) {
                        if networkInfo.serviceCurrentRadioAccessTechnology?.isEmpty == false {
                            result("Cellular")
                            return
                        }
                    } else {
                        if networkInfo.currentRadioAccessTechnology != nil {
                            result("Cellular")
                            return
                        }
                    }
                    result("None")
                }
            }
        } else {
            if self.getWifiSSIDLegacy() != nil {
                result("WiFi")
            } else {
                let networkInfo = CTTelephonyNetworkInfo()
                if networkInfo.currentRadioAccessTechnology != nil {
                    result("Cellular")
                } else {
                    result("None")
                }
            }
        }
    }
}
