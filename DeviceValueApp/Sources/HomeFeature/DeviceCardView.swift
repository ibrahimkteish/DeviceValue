//
//  DeviceCardView.swift
//  DeviceValueApp
//
//  Created by Ibrahim Koteish on 16/2/25.
//

import Generated
import GRDB
import Models
import SwiftUI
import Utils

public struct DeviceCardView: View {

  public let data: HomeFeature.Items.State
  @State private var isPressed: Bool = false

  init(data: HomeFeature.Items.State) {
    self.data = data
  }

  // Convert elapsed days into the number of usage periods.
  var elapsedPeriodCount: Double {
    let days = Double(data.device.elapsedDays)
    return days / Double(self.data.usageRatePeriod.daysMultiplier)
  }

  // Calculate the accumulated cost using the usage rate per period.
  var accumulatedCost: Double {
    self.data.device.usageRate * self.elapsedPeriodCount
  }

  // Calculate remaining cost.
  var remainingCost: Double {
    max(self.data.device.purchasePrice - self.accumulatedCost, 0)
  }

  // Calculate progress as a value between 0 and 1.
  var progress: Double {
    min(self.accumulatedCost / self.data.device.purchasePrice, 1.0)
  }

  var progressColor: Color {
    self.progress >= 1.0 ? Color(hex: 0x006E28) : Color(hex: 0x0058BC)
  }

  // Formatted usage rate string
  var usageRateString: String {
    let formatted = data.device.usageRate.formatted(.currency(code: data.currency.code))
    return "\(formatted)/\(data.usageRatePeriod.name)"
  }

  // Remaining days
  var remainingDaysCount: Int {
    let perDay = data.device.usageRate / Double(data.usageRatePeriod.daysMultiplier)
    guard perDay > 0 else { return 0 }
    return max(Int((data.device.purchasePrice / perDay) - Double(data.device.elapsedDays)), 0)
  }

  // MARK: - View Components

  @ViewBuilder
  private var deviceNameRow: some View {
    HStack(spacing: 8) {
      Image(systemName: deviceIconName)
        .font(.system(size: 14))
        .foregroundStyle(Color(hex: 0x0058BC))
      Text(data.device.name)
        .font(.system(size: 18, weight: .heavy))
        .foregroundStyle(.primary)
    }
  }

  private var deviceIconName: String {
    let name = data.device.name.lowercased()
    if name.contains("iphone") || name.contains("phone") {
      return "iphone"
    } else if name.contains("macbook") || name.contains("laptop") {
      return "laptopcomputer"
    } else if name.contains("ipad") || name.contains("tablet") {
      return "ipad"
    } else if name.contains("watch") {
      return "applewatch"
    } else if name.contains("airpod") || name.contains("headphone") {
      return "headphones"
    } else {
      return "desktopcomputer"
    }
  }

  @ViewBuilder
  private var metricsGrid: some View {
    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
      GridRow {
        metricCell(
          label: Strings.purchasePrice.uppercased(),
          value: data.device.purchasePrice.formatted(.currency(code: data.currency.code)),
          valueColor: .primary
        )
        metricCell(
          label: Strings.usageRate.uppercased(),
          value: usageRateString,
          valueColor: Color(hex: 0x006E28)
        )
      }
      GridRow {
        metricCell(
          label: "DAYS USED",
          value: "\(data.device.elapsedDays) \(Strings.days)",
          valueColor: .primary
        )
        metricCell(
          label: "REMAINING",
          value: remainingCost.formatted(.currency(code: data.currency.code)),
          valueColor: Color(hex: 0x894D00)
        )
      }
    }
  }

  @ViewBuilder
  private func metricCell(label: String, value: String, valueColor: Color) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(label)
        .font(.system(size: 10, weight: .semibold))
        .tracking(0.5)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.system(size: 16, weight: .bold, design: .default))
        .foregroundStyle(valueColor)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var progressCircle: some View {
    ZStack {
      Circle()
        .stroke(progressColor.opacity(0.2), style: StrokeStyle(lineWidth: 3.5))

      Circle()
        .trim(from: 0, to: progress)
        .stroke(progressColor, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
        .rotationEffect(.degrees(-90))

      Text("\(Int(progress * 100))%")
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)
    }
    .frame(width: 70, height: 70)
  }

  public var body: some View {
    HStack(alignment: .center, spacing: 0) {
      VStack(alignment: .leading, spacing: 16) {
        deviceNameRow
        metricsGrid
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Spacer(minLength: 16)

      progressCircle
    }
    .padding(24)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(.secondarySystemGroupedBackground))
        .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
    )
    .scaleEffect(isPressed ? 0.98 : 1.0)
    .animation(.spring(response: 0.3), value: isPressed)
    .onTapGesture {
      withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            isPressed = false
          }
        }
      }
    }
  }
}

#if DEBUG
#Preview {
  VStack(spacing: 16) {
    DeviceCardView(
      data: .init(
        device: .init(
          name: "iPhone 15 Pro",
          currencyId: 1,
          purchasePrice: 999,
          purchaseDate: Date(year: 2024, month: 1, day: 1),
          usageRate: 1.25,
          usageRatePeriodId: 1
        ),
        currency: .usd,
        usageRatePeriod: .day
      )
    )

    DeviceCardView(
      data: .init(
        device: .init(
          name: "MacBook Air M2",
          currencyId: 1,
          purchasePrice: 1199,
          purchaseDate: Date(year: 2023, month: 6, day: 15),
          usageRate: 1.10,
          usageRatePeriodId: 1
        ),
        currency: .usd,
        usageRatePeriod: .day
      )
    )
  }
  .padding(24)
  .background(Color(.systemBackground))
}
#endif

extension UsageRatePeriod {
  var localizedName: String {
    switch self.name {
      case "day":
        return Strings.day
      case "week":
        return Strings.week
      case "month":
        return Strings.month
      case "year":
        return Strings.year
      default:
        return "day"
    }
  }
}
