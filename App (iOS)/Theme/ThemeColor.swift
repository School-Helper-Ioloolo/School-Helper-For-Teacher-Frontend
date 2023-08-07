import SwiftUI

struct ThemeColor {
    static func background(scheme: ColorScheme) -> Color {
        return scheme == .light ? Color(hex: 0xffffff) : Color(hex: 0x080808)
    }
    
    static func card(scheme: ColorScheme) -> Color {
        return scheme == .light ? Color(hex: 0xffffff) : Color(hex: 0x101010)
    }
    
    static func yellowBackground(scheme: ColorScheme) -> Color {
        return scheme == .light ? Color(hex: 0xffffab) : Color(hex: 0x797900)
    }
    
    static func yellowText(scheme: ColorScheme) -> Color {
        return scheme == .light ? Color(hex: 0x797900) : Color(hex: 0xffffab)
    }
    
    static func cell(scheme: ColorScheme, highlight: Bool) -> Color {
        return highlight ? yellowBackground(scheme: scheme) : (scheme == .light ? Color(hex: 0xf2f2f2) : Color(hex: 0x101010))
    }
}
