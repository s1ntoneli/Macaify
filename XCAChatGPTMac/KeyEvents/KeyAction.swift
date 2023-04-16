//
//  KeyAction.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/16.
//

import Foundation
import AppKit

enum KeyAction: UInt16 {
    case a = 0
    case s = 1
    case d = 2
    case f = 3
    case h = 4
    case g = 5
    case z = 6
    case x = 7
    case c = 8
    case v = 9
    case b = 11
    case q = 12
    case w = 13
    case e = 14
    case r = 15
    case y = 16
    case t = 17
    case one = 18
    case two = 19
    case three = 20
    case four = 21
    case six = 22
    case five = 23
    case equal = 24
    case nine = 25
    case seven = 26
    case minus = 27
    case eight = 28
    case zero = 29
    case rightBracket = 30
    case o = 31
    case u = 32
    case leftBracket = 33
    case i = 34
    case p = 35
    case enter = 36
    case l = 37
    case j = 38
    case quote = 39
    case k = 40
    case semicolon = 41
    case backslash = 42
    case comma = 43
    case slash = 44
    case n = 45
    case m = 46
    case period = 47
    case tab = 48
    case grave = 50
    case keypadDecimal = 65
    case keypadMultiply = 67
    case keypadPlus = 69
    case keypadClear = 71
    case keypadDivide = 75
    case keypadEnter = 76
    case keypadMinus = 78
    case keypadEquals = 81
    case keypad0 = 82
    case keypad1 = 83
    case keypad2 = 84
    case keypad3 = 85
    case keypad4 = 86
    case keypad5 = 87
    case keypad6 = 88
    case keypad7 = 89
    case keypad8 = 91
    case keypad9 = 92
    case f5 = 96
    case f6 = 97
    case f7 = 98
    case f3 = 99
    case f8 = 100
    case f9 = 101
    case f11 = 103
    case f13 = 105
    case f14 = 107
    case f10 = 109
    case f12 = 111
    case f15 = 113
    case help = 114
    case home = 115
    case pageUp = 116
    case forwardDelete = 117
    case f4 = 118
    case end = 119
    case f2 = 120
    case pageDown = 121
    case f1 = 122
    case leftArrow = 123
    case rightArrow = 124
    case downArrow = 125
    case upArrow = 126
}

extension KeyAction {
    
    init?(event: NSEvent) {
        self.init(rawValue: event.keyCode)
    }
}

extension NSEvent {
    var action: KeyAction? {
        get {
            KeyAction(event: self)
        }
    }
}
