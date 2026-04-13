import ComposableArchitecture
import Generated
import Models
import SwiftUI

public struct AddDeviceView: View {
  @Bindable var store: StoreOf<AddDeviceFeature>
  @Environment(\.colorScheme) private var colorScheme

  public init(store: StoreOf<AddDeviceFeature>) {
    self.store = store
  }

  private var backgroundColor: Color {
    colorScheme == .dark ? Color(.systemBackground) : Color(hex: 0xFAF9FE)
  }

  private var inputBackgroundColor: Color {
    Color(hex: 0xE3E2E7).opacity(0.5)
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        // Header
        VStack(alignment: .leading, spacing: 4) {
          Text(Strings.addNewDevice)
            .font(.system(size: 30, weight: .heavy))
            .tracking(-0.75)
            .foregroundStyle(Color(hex: 0x1A1B1F))
          Text(DesignLabels.trackDepreciation)
            .font(.system(size: 16))
            .foregroundStyle(Color(hex: 0x414755))
        }

        // Form fields
        VStack(spacing: 24) {
          // Currency
          fieldGroup(label: Strings.currency.uppercased()) {
            VStack(spacing: 8) {
              if store.currencies.isEmpty {
                HStack {
                  Text(Strings.loadingCurrencies)
                    .foregroundStyle(Color(hex: 0x414755))
                  Spacer()
                  Button {
                    store.send(.addCurrencyTapped)
                  } label: {
                    Text(Strings.addCurrency)
                      .foregroundStyle(Color(hex: 0x0058BC))
                  }
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(
                  RoundedRectangle(cornerRadius: 24)
                    .fill(inputBackgroundColor)
                )
              } else {
                Picker(selection: $store.selectedCurrencyId) {
                  ForEach(store.currencies, id: \.id) { currency in
                    Text("\(currency.code) - \(currency.symbol) - \(currency.name)")
                      .tag(currency.id!)
                  }
                } label: {
                  EmptyView()
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 56)
                .padding(.horizontal, 16)
                .background(
                  RoundedRectangle(cornerRadius: 24)
                    .fill(inputBackgroundColor)
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
                )

                Button {
                  store.send(.addCurrencyTapped)
                } label: {
                  HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text(Strings.addCurrency)
                  }
                  .font(.system(size: 13, weight: .semibold))
                  .foregroundStyle(Color(hex: 0x0058BC))
                }
              }
            }
          }

          // Device Name
          fieldGroup(label: Strings.deviceName.uppercased()) {
            TextField(Strings.deviceName, text: $store.deviceName)
              .font(.system(size: 16, weight: .medium))
              .padding(.horizontal, 16)
              .frame(height: 56)
              .background(
                RoundedRectangle(cornerRadius: 24)
                  .fill(inputBackgroundColor)
                  .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
              )
          }

          // Price + Date row
          HStack(spacing: 16) {
            fieldGroup(label: Strings.purchasePrice.uppercased()) {
              HStack(spacing: 0) {
                Text(store.currencies.first(where: { $0.id == store.selectedCurrencyId })?.symbol ?? "$")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundStyle(Color(hex: 0x414755))
                  .padding(.leading, 16)
                TextField("0.00", text: $store.purchasePrice)
                  .keyboardType(.decimalPad)
                  .font(.system(size: 16, weight: .medium))
                  .padding(.trailing, 16)
              }
              .frame(height: 56)
              .background(
                RoundedRectangle(cornerRadius: 24)
                  .fill(inputBackgroundColor)
                  .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
              )
            }

            fieldGroup(label: Strings.purchaseDate.uppercased()) {
              DatePicker(
                "",
                selection: $store.purchaseDate,
                displayedComponents: .date
              )
              .datePickerStyle(.compact)
              .labelsHidden()
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
              .frame(height: 56)
            }
          }

          // Usage Rate
          fieldGroup(label: Strings.usageRate.uppercased()) {
            VStack(spacing: 12) {
              TextField("0.00", text: $store.usageRate)
                .keyboardType(.decimalPad)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(
                  RoundedRectangle(cornerRadius: 24)
                    .fill(inputBackgroundColor)
                    .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
                )

              // Period segmented control - full width
              HStack(spacing: 0) {
                ForEach(store.usageRatePeriods, id: \.id) { period in
                  let isSelected = period.id == store.selectedUsageRatePeriodId
                  Button {
                    store.selectedUsageRatePeriodId = period.id!
                  } label: {
                    Text(period.localizedName.capitalized)
                      .font(.system(size: 13, weight: .semibold))
                      .foregroundStyle(
                        isSelected ? Color(hex: 0x0058BC) : Color(hex: 0x414755).opacity(0.6)
                      )
                      .frame(maxWidth: .infinity)
                      .padding(.vertical, 10)
                      .background(
                        Group {
                          if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                              .fill(colorScheme == .dark ? Color(white: 0.25) : .white)
                              .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                          }
                        }
                      )
                  }
                }
              }
              .padding(4)
              .frame(height: 48)
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .fill(inputBackgroundColor)
                  .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 2)
              )
            }
          }
        }

        // Action buttons
        HStack(spacing: 16) {
          Button {
            store.send(.cancelButtonTapped)
          } label: {
            Text(Strings.cancel)
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(Color(hex: 0x0058BC))
              .frame(width: 124, height: 56)
          }

          Button {
            store.send(.submitButtonTapped)
          } label: {
            Text(store.mode.deviceId != nil ? Strings.update : Strings.submit)
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(
                RoundedRectangle(cornerRadius: 24)
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
          }
          .disabled(!store.isValid)
          .opacity(store.isValid ? 1.0 : 0.5)
        }
        .padding(.top, 16)
      }
      .padding(.horizontal, 32)
      .padding(.top, 8)
      .padding(.bottom, 56)
    }
    .background(backgroundColor.opacity(0.85))
    .navigationBarHidden(true)
  }

  @ViewBuilder
  private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .font(.system(size: 12, weight: .semibold))
        .tracking(1.2)
        .foregroundStyle(Color(hex: 0x414755))
        .padding(.leading, 4)
      content()
    }
  }
}

// Design label constants
private enum DesignLabels {
  static let trackDepreciation = "Track the depreciation of your hardware."
  static let addDeviceButton = Strings.submit
  static let editDeviceTitle = Strings.addNewDevice
}

#Preview {
  NavigationStack {
    AddDeviceView(
      store: Store(
        initialState: AddDeviceFeature.State()
      ) {
        AddDeviceFeature()
      }
    )
  }
}
