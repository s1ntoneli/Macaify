//
//  Color.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/9.
//

import Foundation
import SwiftUI

extension Color {
    static func hex(_ hex: UInt32, alpha: Double = 1.0) -> Color {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
