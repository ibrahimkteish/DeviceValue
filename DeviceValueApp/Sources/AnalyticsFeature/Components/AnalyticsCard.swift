import SwiftUI
import Utils

struct AnalyticsCard: View {
  let title: String
  let value: String
  var valueColor: Color = .primary
  var subtitle: String? = nil
  var subtitleColor: Color = .secondary
  var showProgressBar: Bool = false
  var progressValue: Double = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title.uppercased())
        .font(.system(size: 12, weight: .semibold))
        .tracking(0.6)
        .foregroundStyle(.secondary)
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
                .fill(Color(.secondarySystemBackground))
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
        .fill(Color(.secondarySystemGroupedBackground))
        .overlay(
          RoundedRectangle(cornerRadius: 24)
            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, x: 10, y: 10)
    )
  }
}
