//
//  AppFont.swift
//  PizzaMobileApp
//

import SwiftUI
import CoreText

enum AppFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("Figtree-Regular", size: size)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("Figtree-SemiBold", size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("Figtree-Bold", size: size)
    }

    static func extrabold(_ size: CGFloat) -> Font {
        .custom("Figtree-ExtraBold", size: size)
    }
}
