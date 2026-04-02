import Foundation
import Capacitor

// MARK: - SportsPulsePlugin
// Capacitor bridge — exposes native Swift APIs to the Next.js / React web layer
// Usage from JS:
//   import { SportsPulsePlugin } from '../plugins/SportsPulsePlugin';
//   await SportsPulsePlugin.startLiveActivity({ matchId, homeTeam, ... });

@objc(SportsPulsePlugin)
public class SportsPulsePlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "SportsPulsePlugin"
    public let jsName = "SportsPulse"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "startLiveActivity",  returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "updateLiveActivity", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "endLiveActivity",    returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPushToken",       returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "requestNotificationPermission", returnType: CAPPluginReturnPromise),
    ]

    // MARK: Live Activity — Start
    @objc func startLiveActivity(_ call: CAPPluginCall) {
        guard
            let matchId    = call.getString("matchId"),
            let homeTeam   = call.getString("homeTeam"),
            let awayTeam   = call.getString("awayTeam"),
            let homeShort  = call.getString("homeTeamShort"),
            let awayShort  = call.getString("awayTeamShort"),
            let competition = call.getString("competition")
        else {
            call.reject("Missing required match parameters")
            return
        }

        Task {
            do {
                try await LiveActivityManager.shared.startActivity(
                    matchId: matchId,
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    homeShort: homeShort,
                    awayShort: awayShort,
                    competition: competition
                )
                call.resolve(["status": "started"])
            } catch {
                call.reject("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Live Activity — Update
    @objc func updateLiveActivity(_ call: CAPPluginCall) {
        let homeScore          = call.getInt("homeScore") ?? 0
        let awayScore          = call.getInt("awayScore") ?? 0
        let minute             = call.getInt("minute") ?? 0
        let isHalfTime         = call.getBool("isHalfTime") ?? false
        let lastEvent          = call.getString("lastEvent")
        let winProbabilityHome = call.getDouble("winProbabilityHome") ?? 0.5

        Task {
            await LiveActivityManager.shared.updateActivity(
                homeScore: homeScore,
                awayScore: awayScore,
                minute: minute,
                isHalfTime: isHalfTime,
                lastEvent: lastEvent,
                winProbabilityHome: winProbabilityHome
            )
            call.resolve(["status": "updated"])
        }
    }

    // MARK: Live Activity — End
    @objc func endLiveActivity(_ call: CAPPluginCall) {
        let homeScore = call.getInt("finalHomeScore") ?? 0
        let awayScore = call.getInt("finalAwayScore") ?? 0

        Task {
            await LiveActivityManager.shared.endActivity(
                finalHomeScore: homeScore,
                finalAwayScore: awayScore
            )
            call.resolve(["status": "ended"])
        }
    }

    // MARK: Get APNs Push Token
    @objc func getPushToken(_ call: CAPPluginCall) {
        guard let token = UserDefaults.standard.string(forKey: "apns_device_token") else {
            call.reject("Push token not available yet")
            return
        }
        call.resolve(["token": token])
    }

    // MARK: Request Notification Permission
    @objc func requestNotificationPermission(_ call: CAPPluginCall) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                call.reject(error.localizedDescription)
            } else {
                call.resolve(["granted": granted])
            }
        }
    }
}
