package io.xenosignal.xenosignal

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.os.Build
import android.telephony.CellInfoLte
import android.telephony.CellInfoNr
import android.telephony.CellInfoWcdma
import android.telephony.CellInfoGsm
import android.telephony.CellInfoCdma
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.xenosignal/signal"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWifiSignal" -> result.success(getWifiSignal())
                    "getCellularSignal" -> result.success(getCellularSignal())
                    "isWifiEnabled" -> result.success(isWifiEnabled())
                    "isCellularEnabled" -> result.success(isCellularEnabled())
                    "getConnectionType" -> result.success(getConnectionType())
                    else -> result.notImplemented()
                }
            }
    }

    private fun getWifiSignal(): Map<String, Any?>? {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
            ?: return null

        if (!wifiManager.isWifiEnabled) return null

        val wifiInfo = wifiManager.connectionInfo ?: return null

        // RSSI is the signal strength in dBm
        val rssi = wifiInfo.rssi
        if (rssi == -127) return null // Invalid reading

        return mapOf(
            "dbm" to rssi.toDouble(),
            "networkName" to wifiInfo.ssid?.removeSurrounding("\""),
            "connectionType" to getWifiFrequencyBand(wifiInfo.frequency),
            "latencyMs" to null,
            "location" to null
        )
    }

    private fun getWifiFrequencyBand(frequency: Int): String {
        return when {
            frequency in 2400..2500 -> "2.4 GHz"
            frequency in 4900..5900 -> "5 GHz"
            frequency in 5925..7125 -> "6 GHz"
            else -> "Unknown"
        }
    }

    private fun getCellularSignal(): Map<String, Any?>? {
        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            ?: return null

        val networkType = getNetworkTypeName(telephonyManager)
        var dbm: Double? = null

        // Try to get signal strength if we have permission
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE)
            == PackageManager.PERMISSION_GRANTED
        ) {
            dbm = getCellularDbm(telephonyManager)
        }

        return mapOf(
            "dbm" to dbm,
            "networkName" to telephonyManager.networkOperatorName,
            "connectionType" to networkType,
            "latencyMs" to null,
            "location" to null
        )
    }

    @Suppress("DEPRECATION")
    private fun getCellularDbm(telephonyManager: TelephonyManager): Double? {
        try {
            val cellInfoList = telephonyManager.allCellInfo ?: return null

            // Find the registered (active) cell and get its signal strength
            for (cellInfo in cellInfoList) {
                if (!cellInfo.isRegistered) continue

                val dbm = when (cellInfo) {
                    is CellInfoLte -> cellInfo.cellSignalStrength.dbm
                    is CellInfoWcdma -> cellInfo.cellSignalStrength.dbm
                    is CellInfoGsm -> cellInfo.cellSignalStrength.dbm
                    is CellInfoCdma -> cellInfo.cellSignalStrength.dbm
                    else -> {
                        // Handle 5G NR on API 29+
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && cellInfo is CellInfoNr) {
                            (cellInfo.cellSignalStrength as? android.telephony.CellSignalStrengthNr)?.dbm
                        } else {
                            null
                        }
                    }
                }

                // Return first valid reading from registered cell
                if (dbm != null && dbm != Int.MAX_VALUE && dbm != Int.MIN_VALUE) {
                    return dbm.toDouble()
                }
            }
        } catch (e: SecurityException) {
            // Permission not granted at runtime
            return null
        }
        return null
    }

    @Suppress("DEPRECATION")
    private fun getNetworkTypeName(telephonyManager: TelephonyManager): String {
        return when (telephonyManager.networkType) {
            TelephonyManager.NETWORK_TYPE_NR -> "5G"
            TelephonyManager.NETWORK_TYPE_LTE -> "LTE"
            TelephonyManager.NETWORK_TYPE_HSPAP,
            TelephonyManager.NETWORK_TYPE_HSPA,
            TelephonyManager.NETWORK_TYPE_HSDPA,
            TelephonyManager.NETWORK_TYPE_HSUPA -> "3G"
            TelephonyManager.NETWORK_TYPE_EDGE,
            TelephonyManager.NETWORK_TYPE_GPRS -> "2G"
            else -> "Unknown"
        }
    }

    private fun isWifiEnabled(): Boolean {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        return wifiManager?.isWifiEnabled ?: false
    }

    private fun isCellularEnabled(): Boolean {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return false

        val network = connectivityManager.activeNetwork ?: return false
        val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return false

        return capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
    }

    private fun getConnectionType(): String {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return "None"

        val network = connectivityManager.activeNetwork ?: return "None"
        val capabilities = connectivityManager.getNetworkCapabilities(network) ?: return "None"

        return when {
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "WiFi"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Cellular"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "Ethernet"
            else -> "Unknown"
        }
    }
}
