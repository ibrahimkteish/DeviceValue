import ComposableArchitecture
import Generated
import Models
import SwiftUI
import Utils

public struct AddCurrencyView: View {
  let store: StoreOf<CurrenciesRatesFeature>
  @Environment(\.dismiss) private var dismiss

  @State private var code = ""
  @State private var symbol = ""
  @State private var name = ""
  @State private var usdRate = ""

  public init(store: StoreOf<CurrenciesRatesFeature>) {
    self.store = store
  }

  private var inputBackgroundColor: Color {
    Color(.secondarySystemBackground)
  }

  public var body: some View {
    VStack(spacing: 32) {
      // Header
      HStack {
        Text(Strings.addCurrency)
          .font(.system(size: 24, weight: .heavy))
          .tracking(-0.6)
          .foregroundStyle(.primary)

        Spacer()

        Button {
          store.send(.addCurrencyCancelled)
          dismiss()
        } label: {
          Circle()
            .fill(Color(.secondarySystemBackground))
            .frame(width: 40, height: 40)
            .overlay(
              Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            )
        }
      }

      // Form fields
      VStack(spacing: 24) {
        // Code + Symbol row
        HStack(spacing: 16) {
          fieldGroup(label: "CURRENCY CODE") {
            TextField(Strings.codeExample, text: $code)
              .autocapitalization(.allCharacters)
              .disableAutocorrection(true)
              .font(.system(size: 18, weight: .bold))
              .padding(.horizontal, 16)
              .padding(.vertical, 14)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(inputBackgroundColor)
                  .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
              )
          }

          fieldGroup(label: "SYMBOL") {
            TextField(Strings.currencySymbol, text: $symbol)
              .font(.system(size: 18, weight: .bold))
              .padding(.horizontal, 16)
              .padding(.vertical, 14)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(inputBackgroundColor)
                  .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
              )
          }
        }

        // Name
        fieldGroup(label: "NAME") {
          TextField(Strings.nameOfCurrency, text: $name)
            .font(.system(size: 16, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(inputBackgroundColor)
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
            )
        }

        // Exchange Rate
        fieldGroup(label: "EXCHANGE RATE (TO 1 USD)") {
          VStack(alignment: .leading, spacing: 7.5) {
            TextField(Strings.exchangeRateToUSD, text: $usdRate)
              .keyboardType(.decimalPad)
              .font(.system(size: 24, weight: .heavy))
              .foregroundStyle(Color.brandBlue)
              .padding(16)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color(.secondarySystemBackground))
                  .shadow(color: .brandBlue.opacity(0.05), radius: 4, x: 0, y: 2)
              )

            if !code.isEmpty, let rate = Double(usdRate) {
              HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                  .font(.system(size: 11.667))
                  .foregroundStyle(Color.brandGreen)
                Text("1 USD = \(rate.formatted()) \(code.uppercased())")
                  .font(.system(size: 12, weight: .medium))
                  .foregroundStyle(Color.brandGreen)
              }
            }
          }
        }
      }

      // Actions
      VStack(spacing: 16) {
        Button {
          saveCurrency()
        } label: {
          Text(Strings.save + " " + Strings.currency)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(
                  LinearGradient(
                    colors: [.brandBlue, .brandBlueLight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
                .shadow(
                  color: .brandBlue.opacity(0.25),
                  radius: 12, x: 0, y: 8
                )
            )
        }
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)

        Button {
          store.send(.addCurrencyCancelled)
          dismiss()
        } label: {
          Text(Strings.cancel)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
        }
      }
      .padding(.top, 8)
    }
    .padding(.horizontal, 32)
    .padding(.top, 24)
    .padding(.bottom, 40)
    .background(Color(.systemBackground))
  }

  @ViewBuilder
  private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .font(.system(size: 11, weight: .semibold))
        .tracking(0.55)
        .foregroundStyle(.secondary)
      content()
    }
  }

  private var isFormValid: Bool {
    !self.code.isEmpty && !self.symbol.isEmpty && !self.name.isEmpty && !self.usdRate
      .isEmpty && Double(self.usdRate) != nil
  }

  private func saveCurrency() {
    guard self.isFormValid, let rate = Double(usdRate) else { return }

    let newCurrency = Currency(
      code: code.uppercased(),
      symbol: self.symbol,
      name: self.name,
      usdRate: rate
    )

    self.store.send(.addCurrencySaved(newCurrency))
  }
}

#Preview {
  AddCurrencyView(
    store: Store(
      initialState: CurrenciesRatesFeature.State()
    ) {
      CurrenciesRatesFeature()
    }
  )
}
