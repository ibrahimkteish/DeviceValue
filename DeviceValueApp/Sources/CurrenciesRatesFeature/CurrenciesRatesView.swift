import ComposableArchitecture
import Generated
import Models
import SQLiteData
import SwiftUI
import Utils

public struct CurrenciesRatesView: View {
  @Bindable var store: StoreOf<CurrenciesRatesFeature>
  @Environment(\.dismiss) private var dismiss

  public init(store: StoreOf<CurrenciesRatesFeature>) {
    self.store = store
  }

  private var backgroundColor: Color {
    Color(.systemBackground)
  }

  @ViewBuilder
  private var rates: some View {
    ForEach(self.store.scope(state: \.rates, action: \.rates), id: \.state.id) { childStore in
      CurrencyRateView(store: childStore)
    }
  }

  public var body: some View {
    VStack(spacing: 0) {
      List {
        if store.currencies.isEmpty {
          if store.totalCurrenciesCount > 0, store.searchTerm.isEmpty {
            Section {
              HStack {
                Spacer()
                VStack {
                  Text(Strings.loadingCurrencies)
                    .foregroundColor(.secondary)
                  ProgressView()
                    .padding()
                }
                Spacer()
              }
            }
          } else if !store.searchTerm.isEmpty {
            Section {
              Text(Strings.noCurrencyFound)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
          }
        } else {
          // Base currency section
          if let usd = store.currencies.first(where: { $0.code == "USD" }) {
            Section {
              baseCurrencyCard(usd)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } header: {
              Text("BASE REFERENCE")
                .font(.system(size: 14, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(.secondary)
            }
          }

          // Live rates
          Section {
            rates
              .listRowInsets(EdgeInsets())
              .listRowSeparator(.hidden)
          } header: {
            Text("LIVE RATES")
              .font(.system(size: 14, weight: .bold))
              .tracking(1.4)
              .foregroundStyle(.secondary)
          }
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .background(backgroundColor)
      .searchable(text: $store.searchTerm, prompt: Strings.searchCurrencies)
    }
    .background(backgroundColor)
    .sheet(isPresented: $store.showingAddCurrency) {
      AddCurrencyView(store: store)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }
    .task {
      await store.send(.fetchCurrencyRates).finish()
    }
    .navigationTitle(Strings.currencyRates)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button(Strings.save) {
          store.send(.updateRates)
        }
      }

      ToolbarItem(placement: .primaryAction) {
        Button {
          store.send(.addCurrencyButtonTapped)
        } label: {
          Image(systemName: "plus")
        }
      }
    }
  }

  @ViewBuilder
  private func baseCurrencyCard(_ currency: Currency) -> some View {
    HStack(spacing: 20) {
      // Large symbol circle
      ZStack {
        Text(currency.symbol)
          .font(.system(size: 24, weight: .semibold))
          .foregroundStyle(.white)
      }
      .frame(width: 64, height: 64)
      .background(
        Circle()
          .fill(
            LinearGradient(
              colors: [Color(hex: 0x0058BC), Color(hex: 0x0070EB)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .shadow(
            color: Color(hex: 0x0058BC).opacity(0.2),
            radius: 8, x: 0, y: 4
          )
      )

      VStack(alignment: .leading, spacing: 0) {
        Text(currency.code)
          .font(.system(size: 12, weight: .semibold))
          .tracking(0.6)
          .foregroundStyle(.secondary)
          .textCase(.uppercase)
        Text(currency.name)
          .font(.system(size: 24, weight: .heavy))
          .foregroundStyle(.primary)
      }

      Spacer()
    }
    .padding(24)
    .background(
      RoundedRectangle(cornerRadius: 24)
        .fill(Color(.secondarySystemGroupedBackground))
        .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
    )
  }
}

#Preview {
  CurrenciesRatesView(
    store: Store(
      initialState: CurrenciesRatesFeature.State()
    ) {
      CurrenciesRatesFeature()
    }
  )
}
