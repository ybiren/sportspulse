import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Widget Views

struct MatchLiveActivityView: View {
    let context: ActivityViewContext<MatchAttributes>

    var body: some View {
        HStack(spacing: 12) {
            // Home team
            VStack(spacing: 2) {
                Text(context.attributes.homeTeamShort)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text("\(context.state.homeScore)")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 0.9, blue: 0.46))
            }

            Spacer()

            // Center: minute + event
            VStack(spacing: 4) {
                if context.state.isHalfTime {
                    Text("HT")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.orange)
                } else {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 0, green: 0.9, blue: 0.46))
                            .frame(width: 6, height: 6)
                        Text("\(context.state.minute)'")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 0, green: 0.9, blue: 0.46))
                    }
                }
                Text(context.attributes.competition)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.gray)

                // Win probability bar
                winProbBar
            }

            Spacer()

            // Away team
            VStack(spacing: 2) {
                Text(context.attributes.awayTeamShort)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text("\(context.state.awayScore)")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.05, green: 0.08, blue: 0.15))
    }

    var winProbBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)
                Capsule()
                    .fill(Color(red: 0, green: 0.9, blue: 0.46))
                    .frame(width: geo.size.width * context.state.winProbabilityHome, height: 4)
            }
        }
        .frame(width: 60, height: 4)
    }
}

// MARK: - Dynamic Island Compact View
struct MatchDynamicIslandCompact: View {
    let context: ActivityViewContext<MatchAttributes>

    var body: some View {
        HStack(spacing: 4) {
            Text(context.attributes.homeTeamShort)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
            Text("\(context.state.homeScore)-\(context.state.awayScore)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(red: 0, green: 0.9, blue: 0.46))
            Text(context.attributes.awayTeamShort)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
        }
    }
}

// MARK: - Dynamic Island Expanded View
struct MatchDynamicIslandExpanded: View {
    let context: ActivityViewContext<MatchAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(context.attributes.homeTeam)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("\(context.state.homeScore) – \(context.state.awayScore)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 0.9, blue: 0.46))
                Spacer()
                Text(context.attributes.awayTeam)
                    .font(.system(size: 13, weight: .semibold))
            }
            if let event = context.state.lastEvent {
                Text(event)
                    .font(.system(size: 11))
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - Widget Entry Point
struct MatchWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MatchAttributes.self) { context in
            MatchLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    MatchDynamicIslandExpanded(context: context)
                }
            } compactLeading: {
                Text(context.attributes.homeTeamShort)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
            } compactTrailing: {
                Text("\(context.state.homeScore)-\(context.state.awayScore)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 0.9, blue: 0.46))
            } minimal: {
                Text("\(context.state.homeScore)-\(context.state.awayScore)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
        }
    }
}
