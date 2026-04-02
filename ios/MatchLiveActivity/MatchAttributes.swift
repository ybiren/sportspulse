import ActivityKit
import Foundation

// MARK: - Match Activity Attributes
// Defines the static + dynamic data for the Live Activity

struct MatchAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var homeScore: Int
        var awayScore: Int
        var minute: Int
        var isHalfTime: Bool
        var lastEvent: String?          // e.g. "GOAL - Rashford 71'"
        var winProbabilityHome: Double  // 0.0 - 1.0, from AI engine
    }

    var homeTeam: String
    var awayTeam: String
    var homeTeamShort: String
    var awayTeamShort: String
    var competition: String
    var matchId: String
}
