//
//  Compacts.swift
//  Macaify
//
//  Created by lixindong on 2024/8/25.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    func listRowSeparator(visibility: Visibility) -> some View {
        if #available(macOS 13.0, *) {
            listRowSeparator(visibility)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func compactOnChange<T: Equatable>(of value: T, _ perform: @escaping (T, T) -> Void) -> some View {
        if #available(macOS 14.0, *) {
            onChange(of: value) { oldValue, newValue in
                perform(oldValue, newValue)
            }
        } else {
            onChange(of: value) { newValue in
                perform(value, newValue)
            }
        }
    }
}
