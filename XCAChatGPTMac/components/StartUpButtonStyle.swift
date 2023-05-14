//
//  StartUpButtonStyle.swift
//  Found
//
//  Created by lixindong on 2023/5/14.
//

import SwiftUI

struct StartUpButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    var backgroundColor: Color = .white
    var pressedBackgroundColor: Color = Color.gray.opacity(0.1)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(width: 300, height: 40)
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(pressedBackgroundColor)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
    }
}

struct StartUpButtonStyle_Previews: PreviewProvider {
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
