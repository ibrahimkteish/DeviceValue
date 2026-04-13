// The Swift Programming Language
// https://docs.swift.org/swift-book

import AddDeviceFeature
import AnalyticsFeature
import ComposableArchitecture
import CurrenciesRatesFeature
import Generated
import SettingsFeature
import SwiftUI

public struct HomeView: View {
  @Bindable var store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  @ViewBuilder
  private var menu: some View {
    Menu {
      ForEach(HomeFeature.Ordering.allCases, id: \.self) { ordering in
        Button {
          store.send(.onSortChanged(ordering))
        } label: {
          Text(ordering.localizedName)
        }
      }
    } label: {
      HStack(spacing: 8) {
        Image(systemName: "line.3.horizontal.decrease")
          .font(.system(size: 10, weight: .semibold))
        Text(Strings.filter)
          .font(.system(size: 14, weight: .medium))
      }
      .foregroundStyle(.secondary)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(Color(.secondarySystemBackground))
      )
    }
  }

  @ViewBuilder
  private var header: some View {
    HStack {
      Button {
        store.send(.settingsButtonTapped)
      } label: {
        Image(systemName: "gearshape.fill")
          .font(.system(size: 18))
          .foregroundStyle(Color.brandBlue)
      }

      Spacer()

      VStack(spacing: 0) {
        Text(Strings.totalDailyCost)
          .font(.system(size: 24, weight: .bold))
          .tracking(-0.6)
          .foregroundStyle(Color.brandBlue)

        if let cost = store.count {
          Text(cost.totalDailyCost.formatted(.currency(code: cost.currencyCode)) + "/\(Strings.day)")
            .font(.system(size: 20, weight: .heavy))
            .foregroundStyle(Color.brandBlue.opacity(0.6))
        }
      }

      Spacer()

      Button {
        store.send(.analyticsButtonTapped)
      } label: {
        Image(systemName: "chart.bar.doc.horizontal.fill")
          .font(.system(size: 18))
          .foregroundStyle(Color.brandBlue)
      }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 16)
  }

  @ViewBuilder
  private var devices: some View {
    ScrollView {
      LazyVStack(spacing: 24) {
        ForEach(self.store.state.devices, id: \.id) { device in
          DeviceCardView(data: device)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button(role: .destructive) {
                if let id = device.id {
                  store.send(.removeDevice(id))
                }
              } label: {
                Label(Strings.delete, systemImage: "trash")
              }
              Button {
                store.send(.editDeviceTapped(device.device))
              } label: {
                Label(Strings.edit, systemImage: "pencil")
              }
              .tint(.accentColor)

              Button {
                store.send(.cloneDeviceTapped(device.device))
              } label: {
                Label(Strings.clone, systemImage: "doc.on.doc")
              }
              .tint(.orange)
            }
            .contextMenu {
              Button {
                store.send(.editDeviceTapped(device.device))
              } label: {
                Label(Strings.edit, systemImage: "pencil")
              }
              Button {
                store.send(.cloneDeviceTapped(device.device))
              } label: {
                Label(Strings.clone, systemImage: "doc.on.doc")
              }
              Button(role: .destructive) {
                if let id = device.id {
                  store.send(.removeDevice(id))
                }
              } label: {
                Label(Strings.delete, systemImage: "trash")
              }
            }
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 128)
      .padding(.top, 16)
    }
  }

  @ViewBuilder
  private var floatingAddButton: some View {
    Button {
      self.store.send(.addDeviceButtonTapped)
    } label: {
      Image(systemName: "plus")
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.white)
        .frame(width: 64, height: 64)
        .background(
          Circle()
            .fill(
              LinearGradient(
                colors: [.brandBlue, .brandBlueLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 12)
        )
    }
    .padding(.trailing, 24)
    .padding(.bottom, 24)
  }

  public var body: some View {
    NavigationStack(path: self.$store.scope(state: \.path, action: \.path)) {
      ZStack(alignment: .bottomTrailing) {
        VStack(spacing: 0) {
          header
          HStack {
            Spacer()
            menu
          }
          .padding(.horizontal, 24)
          devices
        }
        .background(Color(.systemBackground))

        floatingAddButton
      }
      .navigationBarHidden(true)
      .sheet(
        item: self.$store.scope(state: \.destination?.addDevice, action: \.destination.addDevice)
      ) { store in
        NavigationStack {
          AddDeviceView(store: store)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
      }
      .sheet(
        item: self.$store.scope(state: \.destination?.analytics, action: \.destination.analytics)
      ) { store in
        NavigationStack {
          AnalyticsView(store: store)
        }
      }
      .sheet(
        item: self.$store.scope(state: \.destination?.addCurrency, action: \.destination.addCurrency)
      ) { store in
        NavigationStack {
          AddCurrencyView(store: store)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
      }
      .onAppear {
        store.send(.onAppear)
      }
    } destination: { store in
      switch store.case {
        case let .settings(store):
          SettingsView(store: store)
        case let .currencyRates(store):
          CurrenciesRatesView(store: store)
      }
    }
  }
}
