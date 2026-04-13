//
//  Utils.swift
//  DeviceValueApp
//
//  Created by Ibrahim Koteish on 16/2/25.
//

import Foundation
import SwiftUI
import UIKit

public extension Date {
  init(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = second

    if let date = Calendar.current.date(from: components) {
      self = date
    } else {
      self = Date() // Fallback to current date if initialization fails
    }
  }
}

// MARK: - Color Hex Extension

public extension Color {
  init(hex: UInt, opacity: Double = 1.0) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255.0,
      green: Double((hex >> 8) & 0xFF) / 255.0,
      blue: Double(hex & 0xFF) / 255.0,
      opacity: opacity
    )
  }
}

// MARK: - Adaptive Brand Colors

public extension Color {
  /// Primary blue - dark: pinkish for contrast on black, light: original #0058BC
  static let brandBlue = Color(
    UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.95, green: 0.55, blue: 0.70, alpha: 1.0)  // Soft pink
        : UIColor(red: 0.0, green: 0.345, blue: 0.737, alpha: 1.0) // #0058BC
    }
  )

  /// Secondary accent for gradients
  static let brandBlueLight = Color(
    UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 1.0, green: 0.65, blue: 0.78, alpha: 1.0)   // Lighter pink
        : UIColor(red: 0.0, green: 0.44, blue: 0.922, alpha: 1.0)  // #0070EB
    }
  )

  /// Green accent
  static let brandGreen = Color(
    UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.30, green: 0.85, blue: 0.45, alpha: 1.0)  // #4DD973
        : UIColor(red: 0.0, green: 0.431, blue: 0.157, alpha: 1.0) // #006E28
    }
  )

  /// Amber/orange accent
  static let brandAmber = Color(
    UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 1.0, green: 0.72, blue: 0.30, alpha: 1.0)   // #FFB84D
        : UIColor(red: 0.537, green: 0.302, blue: 0.0, alpha: 1.0) // #894D00
    }
  )

  /// Red/error accent
  static let brandRed = Color(
    UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 1.0, green: 0.50, blue: 0.50, alpha: 1.0)   // #FF8080
        : UIColor(red: 0.729, green: 0.102, blue: 0.102, alpha: 1.0) // #BA1A1A
    }
  )
}
