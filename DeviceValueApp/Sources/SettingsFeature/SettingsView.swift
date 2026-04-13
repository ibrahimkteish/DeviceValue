import ComposableArchitecture
import Generated
import Models
import SwiftUI
import Utils

public struct SettingsView: View {
  @Bindable var store: StoreOf<SettingsFeature>

  public init(store: StoreOf<SettingsFeature>) {
    self.store = store
  }

  private var backgroundColor: Color {
    Color(.systemGroupedBackground)
  }

  private var cardBackground: Color {
    Color(.secondarySystemGroupedBackground)
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        preferenceSection
        legalSection
        aboutSection
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 32)
    }
    .background(backgroundColor)
    .task {
      await store.send(.onAppear).finish()
    }
    .tint(Color.brandBlue)
    .navigationTitle(Strings.settings)
    .sheet(isPresented: $store.isShowingCurrencyPicker) {
      NavigationStack {
        CurrencyPickerView(
          currencies: store.availableCurrencies,
          selectedCurrencyId: store.presentation.defaultCurrencyId,
          onSelect: { currencyId in
            store.send(.setDefaultCurrency(currencyId))
          },
          onCancel: {
            store.send(.hideCurrencyPicker)
          }
        )
      }
    }
  }

  // MARK: - Sections

  private var preferenceSection: some View {
    settingsSection(title: Strings.preference.uppercased()) {
          VStack(spacing: 2) {
            // Appearance
            settingsRow(
              icon: "circle.lefthalf.filled",
              title: Strings.appTheme
            ) {
              Picker("", selection: $store.presentation.appTheme) {
                ForEach(SettingsFeature.AppTheme.allCases, id: \.self) { theme in
                  Text(theme.displayName).tag(theme)
                }
              }
              .pickerStyle(.menu)
              .fixedSize()
              .tint(.secondary)

              chevron
            }

            // Currency - tap row to change, tap "Rates" to manage
            Button {
              store.send(.showCurrencyPicker)
            } label: {
              settingsRowContent(
                icon: "dollarsign.square",
                title: Strings.currency
              ) {
                if let currency = store.presentation.defaultCurrency {
                  Text(currency.code)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                }
                chevron
              }
            }

            Button {
              store.send(.openCurrencyRates)
            } label: {
              settingsRowContent(
                icon: "chart.line.uptrend.xyaxis",
                title: Strings.viewCurrencyRates
              ) {
                chevron
              }
            }

            // Language
            settingsRow(
              icon: "globe",
              title: Strings.language
            ) {
              Text(verbatim: "English")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

              Button {
                store.send(.openLanguageSettings)
              } label: {
                Image(systemName: "arrow.up.right")
                  .font(.system(size: 12))
                  .foregroundStyle(.secondary)
              }
            }
          }
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color(.secondarySystemGroupedBackground))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.primary.opacity(0.08), lineWidth: 1)
              )
              .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
          )
          .clipShape(RoundedRectangle(cornerRadius: 12))
        }

  }

  private var legalSection: some View {
    settingsSection(title: Strings.legalDocumentation.uppercased()) {
      VStack(spacing: 2) {
        ForEach(self.store.acknowledgements) { acknowledgement in
          Link(destination: acknowledgement.url) {
            settingsRowContent(
              icon: "heart.text.square",
              title: acknowledgement.name
            ) {
              chevron
            }
          }
        }
        ForEach(["https://www.termsfeed.com/live/3d38411a-f533-4e2d-999d-e83d8eb2fe1b"], id: \.self) { url in
          Link(destination: URL(string: url)!) {
            settingsRowContent(
              icon: "doc.text",
              title: Strings.termsAndConditions
            ) {
              chevron
            }
          }
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.secondarySystemGroupedBackground))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.primary.opacity(0.08), lineWidth: 1)
          )
          .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
      )
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  private var aboutSection: some View {
    VStack(spacing: 16) {
      VStack(spacing: 4) {
        Image(systemName: "info.circle")
          .font(.system(size: 30))
          .foregroundStyle(.secondary)

        Text(Strings.about + " DeviceValue")
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.primary)
          .padding(.top, 4)

        Text("\(Strings.version) \(store.appVersion) (Build \(store.buildNumber))")
          .font(.system(size: 14))
          .foregroundStyle(.secondary)
          .padding(.bottom, 20)

        Divider()
          .opacity(0.1)
      }
      .frame(maxWidth: .infinity)
      .padding(24)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.systemGray5))
      )
    }
    .padding(.top, 16)
    .padding(.horizontal, 8)
  }

  // MARK: - Components

  private var chevron: some View {
    Image(systemName: "chevron.right")
      .font(.system(size: 12, weight: .semibold))
      .foregroundStyle(.secondary.opacity(0.5))
  }

  @ViewBuilder
  private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.system(size: 12, weight: .semibold))
        .tracking(1.2)
        .foregroundStyle(.secondary)
        .padding(.leading, 8)
      content()
    }
  }

  @ViewBuilder
  private func settingsRow<Trailing: View>(
    icon: String,
    title: String,
    @ViewBuilder trailing: () -> Trailing
  ) -> some View {
    settingsRowContent(icon: icon, title: title, trailing: trailing)
  }

  @ViewBuilder
  private func settingsRowContent<Trailing: View>(
    icon: String,
    title: String,
    @ViewBuilder trailing: () -> Trailing
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 18))
        .foregroundStyle(.secondary)
        .frame(width: 22)

      Text(title)
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(.primary)

      Spacer()

      trailing()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 16)
    .background(cardBackground)
  }
}

// Currency picker view for selecting default currency
struct CurrencyPickerView: View {
  let currencies: [Currency]
  let selectedCurrencyId: Int64?
  let onSelect: (Int64?) -> Void
  let onCancel: () -> Void

  var body: some View {
    List {
      ForEach(currencies, id: \.id) { currency in
        Button {
          onSelect(currency.id)
        } label: {
          HStack {
            Text("\(currency.code) (\(currency.symbol)) - \(currency.name)")
            Spacer()
            if selectedCurrencyId == currency.id {
              Image(systemName: "checkmark")
                .foregroundColor(.blue)
            }
          }
        }
      }
    }
    .navigationTitle(Strings.selectCurrency)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(Strings.cancel) {
          onCancel()
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    SettingsView(
      store: Store(
        initialState: SettingsFeature.State()
      ) {
        SettingsFeature()
      }
    )
  }
}
