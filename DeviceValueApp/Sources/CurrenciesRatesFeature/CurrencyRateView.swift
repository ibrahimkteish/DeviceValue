import ComposableArchitecture
import Generated
import SwiftUI
import Utils

public struct CurrencyRateView: View {
  @Bindable var store: StoreOf<CurrencyRateFeature>
  @Environment(\.colorScheme) private var colorScheme

  public init(store: StoreOf<CurrencyRateFeature>) {
    self.store = store
  }

  public var body: some View {
    HStack(spacing: 16) {
      // Currency symbol circle
      ZStack {
        Text(store.currency.symbol)
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(Color(hex: 0x1A1B1F))
      }
      .frame(width: 48, height: 48)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .fill(colorScheme == .dark ? Color(white: 0.2) : Color(hex: 0xEEEDF3))
      )

      // Currency info
      VStack(alignment: .leading, spacing: 0) {
        Text(store.currency.code)
          .font(.system(size: 10, weight: .semibold))
          .foregroundStyle(Color(hex: 0x414755).opacity(0.7))
          .textCase(.uppercase)
        Text(store.currency.name)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(Color(hex: 0x1A1B1F))
      }

      Spacer()

      if store.currency.code == "USD" {
        Text(Strings.base.uppercased())
          .font(.system(size: 10, weight: .semibold))
          .tracking(-0.5)
          .foregroundStyle(Color(hex: 0x0058BC))
          .padding(.horizontal, 12)
          .padding(.vertical, 2.5)
          .background(
            Capsule()
              .fill(Color(hex: 0x0058BC).opacity(0.1))
          )
      } else {
        // Rate input
        ZStack(alignment: .leading) {
          TextField("", text: $store.usdRate)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color(hex: 0x0058BC))
            .padding(.leading, 32)
            .padding(.trailing, 12)
            .padding(.vertical, 8)
            .frame(width: 96)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(white: 0.2) : Color(hex: 0xE9E7ED))
            )

          Text("Rate")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color(hex: 0x414755).opacity(0.4))
            .padding(.leading, 12)
        }
      }
    }
    .padding(20)
    .background(colorScheme == .dark ? Color(white: 0.12) : .white)
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
