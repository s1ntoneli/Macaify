//
//  PurpleButtonStyle.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/9.
//

import SwiftUI

struct PurpleButtonStyle: ButtonStyle {
    var background: Color = Color.hex(0x8654E2)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(background)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring())
    }
}
struct PurpleButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("hi")
        }.buttonStyle(PurpleButtonStyle())
    }
}
