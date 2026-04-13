import ComposableArchitecture
import Generated
import Models
import SwiftUI
import Utils

public struct AnalyticsView: View {
  @Bindable var store: StoreOf<Analytics>
  @Environment(\.colorScheme) private var colorScheme

  public init(store: StoreOf<Analytics>) {
    self.store = store
  }

  private var backgroundColor: Color {
    colorScheme == .dark ? Color(.systemBackground) : Color(hex: 0xFAF9FE)
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 40) {
        portfolioOverview
        deviceUsageList
      }
      .padding(.bottom, 128)
    }
    .background(backgroundColor)
    .navigationTitle(Strings.usageAnalytics)
  }

  private var portfolioOverview: some View {
    LazyVGrid(columns: [
      GridItem(.flexible(), spacing: 16),
      GridItem(.flexible(), spacing: 16),
    ], spacing: 16) {
      AnalyticsCard(
        title: Strings.totalPurchaseValue,
        value: store.formattedTotalPurchaseValue,
        valueColor: Color(hex: 0x0058BC),
        subtitle: "Global Assets",
        subtitleColor: Color(hex: 0x006E28)
      )

      AnalyticsCard(
        title: Strings.remainingValue,
        value: store.formattedRemainingValue,
        showProgressBar: true,
        progressValue: store.remainingPercentage
      )

      AnalyticsCard(
        title: Strings.consumedValue,
        value: store.formattedConsumedValue,
        valueColor: Color(hex: 0x894D00),
        subtitle: "Lifecycle Total",
        subtitleColor: Color(hex: 0x414755)
      )

      AnalyticsCard(
        title: Strings.dailyUsage,
        value: store.formattedDailyUsage,
        subtitle: "Current Burn",
        subtitleColor: Color(hex: 0xBA1A1A)
      )
    }
    .padding(.horizontal, 24)
  }

  private var deviceUsageList: some View {
    VStack(alignment: .leading, spacing: 24) {
      HStack {
        Text(Strings.deviceUsage)
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(Color(hex: 0x1A1B1F))
        Spacer()
      }
      .padding(.horizontal, 24)

      VStack(spacing: 12) {
        ForEach(store.devices) { metric in
          deviceUsageRow(metric)
        }
      }
      .padding(.horizontal, 24)
    }
  }

  @ViewBuilder
  private func deviceUsageRow(_ metric: DeviceUsageMetrics) -> some View {
    let isHighUsage = metric.isWithinExpectedUsage
    let usageColor: Color = isHighUsage ? Color(hex: 0xBA1A1A) : Color(hex: 0x006E28)
    let badgeBg: Color = isHighUsage ? Color(hex: 0xFFDAD6) : Color(hex: 0x6FFB85)
    let badgeText: Color = isHighUsage ? Color(hex: 0x93000A) : Color(hex: 0x00732A)
    let progressColor: Color = {
      if metric.consumptionPercentage > 75 { return Color(hex: 0xBA1A1A) }
      if metric.consumptionPercentage < 40 { return Color(hex: 0x006E28) }
      return Color(hex: 0x0058BC)
    }()

    VStack(alignment: .leading, spacing: 16) {
      // Top row: device info + usage badge
      HStack(alignment: .top) {
        HStack(spacing: 16) {
          // Device icon
          RoundedRectangle(cornerRadius: 16)
            .fill(colorScheme == .dark ? Color(white: 0.2) : Color(hex: 0xEEEDF3))
            .frame(width: 48, height: 48)
            .overlay(
              Image(systemName: deviceIcon(for: metric.deviceName))
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: 0x414755))
            )

          VStack(alignment: .leading, spacing: 0) {
            Text(metric.deviceName)
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(Color(hex: 0x1A1B1F))
            Text("Asset #DV-\(metric.id)")
              .font(.system(size: 12))
              .foregroundStyle(Color(hex: 0x414755))
          }
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text("\(Int(metric.consumptionPercentage))% \(Strings.used)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(badgeText)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(badgeBg))

          Text(metric.dailyUsageRate.formatted(.currency(code: metric.currencyCode)) + "/\(Strings.day)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(hex: 0x1A1B1F))
        }
      }

      // Stats row
      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 3.5) {
          Text("VALUE REMAINING")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color(hex: 0x414755))
          Text(metric.remainingValue.formatted(.currency(code: metric.currencyCode)))
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(hex: 0x1A1B1F))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(colorScheme == .dark ? Color(white: 0.15) : Color(hex: 0xF4F3F8))
        )

        VStack(alignment: .trailing, spacing: 3.5) {
          Text("EST. DAYS LEFT")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color(hex: 0x414755))
          Text("\(Int(metric.daysRemaining)) Days")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(hex: 0x1A1B1F))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(colorScheme == .dark ? Color(white: 0.15) : Color(hex: 0xF4F3F8))
        )
      }

      // Progress bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: .infinity)
            .fill(Color(hex: 0xE3E2E7).opacity(0.4))
            .frame(height: 8)
          RoundedRectangle(cornerRadius: .infinity)
            .fill(progressColor)
            .frame(width: geometry.size.width * min(metric.consumptionPercentage / 100.0, 1.0), height: 8)
        }
      }
      .frame(height: 8)
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(colorScheme == .dark ? Color(white: 0.12) : .white)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    )
  }

  private func deviceIcon(for name: String) -> String {
    let lower = name.lowercased()
    if lower.contains("macbook") || lower.contains("laptop") { return "laptopcomputer" }
    if lower.contains("ipad") || lower.contains("tablet") { return "ipad" }
    if lower.contains("iphone") || lower.contains("phone") { return "iphone" }
    if lower.contains("watch") { return "applewatch" }
    if lower.contains("airpod") || lower.contains("headphone") { return "headphones" }
    return "desktopcomputer"
  }
}

// Extension for remaining percentage used by progress bar
extension Analytics.State {
  var remainingPercentage: Double {
    guard let portfolio = portfolioMetrics,
          portfolio.totalPurchaseValue > 0 else { return 0 }
    return portfolio.remainingValue / portfolio.totalPurchaseValue
  }
}

#Preview {
  NavigationView {
    AnalyticsView(
      store: Store(
        initialState: Analytics.State()
      ) {
        Analytics()
      }
    )
  }
}
