import SwiftUI
import Utils

struct AnalyticsCard: View {
  let title: String
  let value: String
  var valueColor: Color = Color(hex: 0x1A1B1F)
  var subtitle: String? = nil
  var subtitleColor: Color = Color(hex: 0x414755)
  var showProgressBar: Bool = false
  var progressValue: Double = 0

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title.uppercased())
        .font(.system(size: 12, weight: .semibold))
        .tracking(0.6)
        .foregroundStyle(Color(hex: 0x414755))
        .padding(.bottom, 0)

      Spacer()

      VStack(alignment: .leading, spacing: 4) {
        Text(value)
          .font(.system(size: 30, weight: .heavy))
          .foregroundStyle(valueColor)
          .minimumScaleFactor(0.6)
          .lineLimit(1)

        if showProgressBar {
          GeometryReader { geometry in
            ZStack(alignment: .leading) {
              RoundedRectangle(cornerRadius: .infinity)
                .fill(Color(hex: 0xE3E2E7).opacity(0.4))
                .frame(height: 6)
              RoundedRectangle(cornerRadius: .infinity)
                .fill(
                  LinearGradient(
                    colors: [Color(hex: 0x0058BC), Color(hex: 0x0070EB)],
                    startPoint: .leading,
                    endPoint: .trailing
                  )
                )
                .frame(width: geometry.size.width * min(progressValue, 1.0), height: 6)
            }
          }
          .frame(height: 6)
        } else if let subtitle = subtitle {
          Text(subtitle)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(subtitleColor)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(height: 160)
    .padding(21)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(colorScheme == .dark ? Color(white: 0.12) : Color(hex: 0xFAF9FE))
        .overlay(
          RoundedRectangle(cornerRadius: 24)
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: colorScheme == .dark ? .clear : Color(hex: 0xEEEDF3), radius: 10, x: 10, y: 10)
        .shadow(color: colorScheme == .dark ? .clear : .white, radius: 10, x: -10, y: -10)
    )
  }
}
