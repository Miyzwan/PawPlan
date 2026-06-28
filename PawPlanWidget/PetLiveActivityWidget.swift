import ActivityKit
import WidgetKit
import SwiftUI
import PawPlanShared

// MARK: - PetLiveActivityWidget
// Implements all Live Activity and Dynamic Island layouts for PawPlan:
//   • Lock Screen view (expanded lockscreen area)
//   • Dynamic Island compact (leading + trailing)
//   • Dynamic Island minimal
//   • Dynamic Island expanded

struct PetLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetLiveActivityAttributes.self) { context in
            // MARK: Lock Screen View
            LockScreenLiveActivityView(
                attributes: context.attributes,
                state: context.state
            )
            .activityBackgroundTint(Color(hue: 0.50, saturation: 0.55, brightness: 0.18).opacity(0.95))
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: Dynamic Island Expanded Layout
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(state: context.state)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(
                        attributes: context.attributes,
                        state: context.state
                    )
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(state: context.state)
                }
            } compactLeading: {
                // MARK: Dynamic Island Compact Leading
                Text(context.state.petEmoji)
                    .font(.system(size: 16))
                    .padding(.leading, 4)
            } compactTrailing: {
                // MARK: Dynamic Island Compact Trailing
                CompactTrailingView(
                    attributes: context.attributes,
                    state: context.state
                )
            } minimal: {
                // MARK: Dynamic Island Minimal
                Text(context.state.petEmoji)
                    .font(.system(size: 14))
            }
            .widgetURL(URL(string: context.attributes.deepLinkURL))
            .keylineTint(Color(hue: 0.50, saturation: 0.65, brightness: 0.72))
        }
    }
}

// MARK: - Lock Screen Live Activity View

private struct LockScreenLiveActivityView: View {
    let attributes: PetLiveActivityAttributes
    let state: PetLiveActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            // Pet avatar
            PetAvatarView(state: state, size: 52)

            // Event info
            VStack(alignment: .leading, spacing: 4) {
                // Pet dialogue
                Text(state.dialogueText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)

                // Event title
                Text(attributes.eventTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                // Countdown / status
                EventTimingView(state: state, compact: true)
            }

            Spacer(minLength: 0)

            // Category icon + countdown ring
            VStack(spacing: 4) {
                Image(systemName: attributes.eventCategorySymbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))

                if state.isEventCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                } else {
                    CountdownRingView(
                        startDate: state.eventStartDate,
                        endDate: state.eventEndDate
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Dynamic Island: Expanded Regions

private struct ExpandedLeadingView: View {
    let state: PetLiveActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 6) {
            PetAvatarView(state: state, size: 36)
            VStack(alignment: .leading, spacing: 1) {
                Text(state.petName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(state.dialogueText)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .padding(.leading, 8)
    }
}

private struct ExpandedTrailingView: View {
    let state: PetLiveActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if state.isEventCompleted {
                Label("Selesai", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.green)
            } else if state.isEventOngoing {
                Label("Berlangsung", systemImage: "record.circle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.orange)
            } else {
                Text(timerInterval: state.eventStartDate...max(state.eventStartDate, state.eventEndDate), countsDown: true)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: 70)
                    .multilineTextAlignment(.trailing)
                Text("tersisa")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.trailing, 8)
    }
}

private struct ExpandedCenterView: View {
    let state: PetLiveActivityAttributes.ContentState

    var body: some View {
        EmptyView()
    }
}

private struct ExpandedBottomView: View {
    let attributes: PetLiveActivityAttributes
    let state: PetLiveActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 6) {
            // Divider
            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(height: 0.5)
                .padding(.horizontal, 8)

            HStack {
                // Event title + category
                HStack(spacing: 6) {
                    Image(systemName: attributes.eventCategorySymbol)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Text(attributes.eventTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                Spacer()

                // Time range
                EventTimingView(state: state, compact: false)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }
    }
}

private struct CompactTrailingView: View {
    let attributes: PetLiveActivityAttributes
    let state: PetLiveActivityAttributes.ContentState

    var body: some View {
        Group {
            if state.isEventCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 12))
            } else {
                Text(attributes.eventTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: 90, alignment: .leading)
            }
        }
        .padding(.trailing, 6)
    }
}

// MARK: - Reusable Sub-Components

private struct PetAvatarView: View {
    let state: PetLiveActivityAttributes.ContentState
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: size, height: size)

            Text(state.petEmoji)
                .font(.system(size: size * 0.55))

            if let accessory = state.accessoryEmoji {
                Text(accessory)
                    .font(.system(size: size * 0.3))
                    .offset(y: -(size * 0.28))
            }
        }
    }
}

private struct EventTimingView: View {
    let state: PetLiveActivityAttributes.ContentState
    let compact: Bool

    private var timeFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt
    }

    var body: some View {
        Group {
            if state.isEventCompleted {
                Text("✅ Selesai")
                    .font(.system(size: compact ? 11 : 10, weight: .semibold))
                    .foregroundColor(.green)
            } else if state.isEventOngoing {
                HStack(spacing: 3) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 5, height: 5)
                    Text("Berlangsung")
                        .font(.system(size: compact ? 11 : 10, weight: .medium))
                        .foregroundColor(.orange)
                }
            } else {
                Text(timerInterval: Date()...state.eventStartDate, countsDown: true)
                    .font(.system(size: compact ? 11 : 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: compact ? 80 : 60)
            }
        }
    }
}

private struct CountdownRingView: View {
    let startDate: Date
    let endDate: Date

    private var progress: Double {
        let now = Date()
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = now.timeIntervalSince(startDate)
        guard total > 0 else { return 0 }
        return max(0, min(1, elapsed / total))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(hue: 0.50, saturation: 0.65, brightness: 0.85),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 22, height: 22)
    }
}
