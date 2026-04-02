import ActivityKit
import Foundation

// MARK: - LiveActivityManager
// Called from the Capacitor bridge to start/update/end Live Activities

@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<MatchAttributes>?

    // MARK: Start
    func startActivity(
        matchId: String,
        homeTeam: String,
        awayTeam: String,
        homeShort: String,
        awayShort: String,
        competition: String
    ) async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw LiveActivityError.notAuthorized
        }

        let attributes = MatchAttributes(
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            homeTeamShort: homeShort,
            awayTeamShort: awayShort,
            competition: competition,
            matchId: matchId
        )

        let initialState = MatchAttributes.ContentState(
            homeScore: 0,
            awayScore: 0,
            minute: 0,
            isHalfTime: false,
            lastEvent: nil,
            winProbabilityHome: 0.5
        )

        let content = ActivityContent(state: initialState, staleDate: nil)
        currentActivity = try Activity.request(attributes: attributes, content: content)
        print("[LiveActivity] Started: \(currentActivity?.id ?? "unknown")")
    }

    // MARK: Update (called via Supabase Realtime push)
    func updateActivity(
        homeScore: Int,
        awayScore: Int,
        minute: Int,
        isHalfTime: Bool = false,
        lastEvent: String? = nil,
        winProbabilityHome: Double
    ) async {
        guard let activity = currentActivity else { return }

        let updatedState = MatchAttributes.ContentState(
            homeScore: homeScore,
            awayScore: awayScore,
            minute: minute,
            isHalfTime: isHalfTime,
            lastEvent: lastEvent,
            winProbabilityHome: winProbabilityHome
        )

        await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        print("[LiveActivity] Updated: \(homeScore)-\(awayScore) @ \(minute)'")
    }

    // MARK: End
    func endActivity(finalHomeScore: Int, finalAwayScore: Int) async {
        guard let activity = currentActivity else { return }

        let finalState = MatchAttributes.ContentState(
            homeScore: finalHomeScore,
            awayScore: finalAwayScore,
            minute: 90,
            isHalfTime: false,
            lastEvent: "Full Time",
            winProbabilityHome: finalHomeScore > finalAwayScore ? 1.0 : 0.0
        )

        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .after(Date.now.addingTimeInterval(3600)) // keep for 1hr
        )
        currentActivity = nil
        print("[LiveActivity] Ended")
    }
}

enum LiveActivityError: Error {
    case notAuthorized
    case alreadyRunning
}
