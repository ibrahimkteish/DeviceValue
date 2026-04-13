import ComposableArchitecture
import Generated
import Models
import SwiftUI
import Utils

public struct AnalyticsView: View {
  @Bindable var store: StoreOf<Analytics>

  public init(store: StoreOf<Analytics>) {
    self.store = store
  }

  private var backgroundColor: Color {
    Color(.systemBackground)
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
        valueColor: .brandBlue,
        subtitle: Strings.globalAssets,
        subtitleColor: .brandGreen
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
        valueColor: .brandAmber,
        subtitle: Strings.lifecycleTotal,
        subtitleColor: .secondary
      )

      AnalyticsCard(
        title: Strings.dailyUsage,
        value: store.formattedDailyUsage,
        subtitle: Strings.currentBurn,
        subtitleColor: .brandRed
      )
    }
    .padding(.horizontal, 24)
  }

  private var deviceUsageList: some View {
    VStack(alignment: .leading, spacing: 24) {
      HStack {
        Text(Strings.deviceUsage)
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(.primary)
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
    let usageColor: Color = isHighUsage ? .brandRed : .brandGreen
    let badgeBg: Color = isHighUsage ? Color(hex: 0xFFDAD6) : Color(hex: 0x6FFB85)
    let badgeText: Color = isHighUsage ? Color(hex: 0x93000A) : Color(hex: 0x00732A)
    let progressColor: Color = {
      if metric.consumptionPercentage > 75 { return .brandRed }
      if metric.consumptionPercentage < 40 { return .brandGreen }
      return .brandBlue
    }()

    VStack(alignment: .leading, spacing: 16) {
      // Top row: device info + usage badge
      HStack(alignment: .top) {
        HStack(spacing: 16) {
          // Device icon
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemGray5))
            .frame(width: 48, height: 48)
            .overlay(
              Image(systemName: deviceIcon(for: metric.deviceName))
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
            )

          VStack(alignment: .leading, spacing: 0) {
            Text(metric.deviceName)
              .font(.system(size: 16, weight: .bold))
              .foregroundStyle(.primary)
            Text("Asset #DV-\(metric.id)")
              .font(.system(size: 12))
              .foregroundStyle(.secondary)
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
            .foregroundStyle(.primary)
        }
      }

      // Stats row
      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 3.5) {
          Text(Strings.valueRemaining.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
          Text(metric.remainingValue.formatted(.currency(code: metric.currencyCode)))
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(.secondarySystemBackground))
        )

        VStack(alignment: .trailing, spacing: 3.5) {
          Text(Strings.estDaysLeft.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
          Text("\(Int(metric.daysRemaining)) \(Strings.days.capitalized)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(12)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(.secondarySystemBackground))
        )
      }

      // Progress bar
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: .infinity)
            .fill(Color(.secondarySystemBackground))
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
        .fill(Color(.secondarySystemGroupedBackground))
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
