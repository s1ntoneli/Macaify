//
//  RoundedButtonStyle.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/13.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
    }
}

struct RoundedButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {
                    print("Button pressed")
                }) {
                    Text("Press me")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .buttonStyle(RoundedButtonStyle(cornerRadius: 8))
    }
}
