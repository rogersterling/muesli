import SwiftUI
import MuesliCore

struct StatsHeaderView: View {
    let dictationStats: DictationStats
    let meetingStats: MeetingStats

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: MuesliTheme.spacing16) {
                statCards(minWidth: 140)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 120), spacing: MuesliTheme.spacing12),
                    GridItem(.flexible(minimum: 120), spacing: MuesliTheme.spacing12),
                ],
                spacing: MuesliTheme.spacing12
            ) {
                statCards(minWidth: 0)
            }
        }
        .frame(maxWidth: MuesliTheme.pageMaxWidth)
        .padding(.horizontal, MuesliTheme.pageHorizontalPadding)
        .padding(.vertical, MuesliTheme.spacing20)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func statCards(minWidth: CGFloat) -> some View {
        ForEach(statItems) { item in
            StatCard(
                icon: item.icon,
                iconColor: item.iconColor,
                value: item.value,
                label: item.label,
                minWidth: minWidth
            )
        }
    }

    private var statItems: [StatItem] {
        [
            StatItem(
                icon: "flame.fill",
                iconColor: .orange,
                value: "\(dictationStats.currentStreakDays)",
                label: "day streak"
            ),
            StatItem(
                icon: "character.cursor.ibeam",
                iconColor: MuesliTheme.accent,
                value: formatWordCount(dictationStats.totalWords),
                label: "words dictated"
            ),
            StatItem(
                icon: "gauge.with.dots.needle.33percent",
                iconColor: MuesliTheme.success,
                value: String(format: "%.0f", dictationStats.averageWPM),
                label: "avg WPM"
            ),
            StatItem(
                icon: "person.2.fill",
                iconColor: MuesliTheme.accent,
                value: "\(meetingStats.totalMeetings)",
                label: "meetings"
            ),
        ]
    }

    private func formatWordCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
}

private struct StatItem: Identifiable {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var id: String { label }
}

private struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    let minWidth: CGFloat

    var body: some View {
        VStack(spacing: MuesliTheme.spacing8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
            Text(value)
                .font(MuesliTheme.title2())
                .foregroundStyle(MuesliTheme.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(MuesliTheme.caption())
                .foregroundStyle(MuesliTheme.textTertiary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: minWidth, maxWidth: .infinity)
        .padding(MuesliTheme.cardPadding)
        .background(MuesliTheme.backgroundRaised)
        .clipShape(RoundedRectangle(cornerRadius: MuesliTheme.cornerMedium))
        .overlay(
            RoundedRectangle(cornerRadius: MuesliTheme.cornerMedium)
                .strokeBorder(MuesliTheme.surfaceBorder, lineWidth: 1)
        )
    }
}
