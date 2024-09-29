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
}
