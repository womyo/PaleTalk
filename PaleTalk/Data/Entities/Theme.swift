//
//  Theme.swift
//  PaleTalk
//
//  Created by 이인호 on 10/27/25.
//

import Foundation
import SwiftUI

enum Theme: String, CaseIterable {
    case spring = "봄"
    case summer = "여름"
    case autumn = "가을"
    case winter = "겨울"
}

extension Theme {
    var backgroundImageName: String {
        switch self {
        case .spring: "Home_Spring"
        case .summer: "Home_Summer"
        case .autumn: "Home_Autumn"
        case .winter: "Home_Winter"
        }
    }
    
    var mainColor: Color {
        switch self {
        case .spring:
            Color.mainSpring
        case .summer:
            Color.mainSummer
        case .autumn:
            Color.mainAutumn
        case .winter:
            Color.mainWinter
        }
    }
    
    var subColor: Color {
        switch self {
        case .spring:
            Color.subSpring
        case .summer:
            Color.subSummer
        case .autumn:
            Color.subAutumn
        case .winter:
            Color.subWinter
        }
    }
}
