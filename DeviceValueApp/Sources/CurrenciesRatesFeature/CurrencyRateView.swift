import ComposableArchitecture
import Generated
import SwiftUI
import Utils

public struct CurrencyRateView: View {
  @Bindable var store: StoreOf<CurrencyRateFeature>

  public init(store: StoreOf<CurrencyRateFeature>) {
    self.store = store
  }

  public var body: some View {
    HStack(spacing: 16) {
      // Currency symbol circle
      ZStack {
        Text(store.currency.symbol)
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(.primary)
      }
      .frame(width: 48, height: 48)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .fill(Color(.systemGray5))
      )

      // Currency info
      VStack(alignment: .leading, spacing: 0) {
        Text(store.currency.code)
          .font(.system(size: 10, weight: .semibold))
          .foregroundStyle(.secondary)
          .textCase(.uppercase)
        Text(store.currency.name)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.primary)
      }

      Spacer()

      if store.currency.code == "USD" {
        Text(Strings.base.uppercased())
          .font(.system(size: 10, weight: .semibold))
          .tracking(-0.5)
          .foregroundStyle(Color.brandBlue)
          .padding(.horizontal, 12)
          .padding(.vertical, 2.5)
          .background(
            Capsule()
              .fill(Color.brandBlue.opacity(0.1))
          )
      } else {
        // Rate input
        VStack(alignment: .trailing, spacing: 2) {
          Text(verbatim: "Rate")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
          TextField("0.00", text: $store.usdRate)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color.brandBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(width: 110)
            .background(
              RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
            )
        }
      }
    }
    .padding(20)
    .background(Color(.secondarySystemGroupedBackground))
    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
      if store.currency.code != "USD" {
        Button(role: .destructive) {
          store.send(.delete)
        } label: {
          Label(Strings.delete, systemImage: "trash")
        }
      }
    }
  }
}
