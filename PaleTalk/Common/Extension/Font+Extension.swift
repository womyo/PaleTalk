//
//  Font+Extension.swift
//  PaleTalk
//
//  Created by wayblemac02 on 8/7/25.
//

import SwiftUI

extension Font {
    static func pretendardLight(size: CGFloat) -> Font {
        .custom("Pretendard-Light", size: size)
    }
    
    static func pretendardRegular(size: CGFloat) -> Font {
        .custom("Pretendard-Regular", size: size)
    }
    
    static func pretendardBold(size: CGFloat) -> Font {
        .custom("Pretendard-Bold", size: size)
    }
    
    static func pretendardMedium(size: CGFloat) -> Font {
        .custom("Pretendard-Medium", size: size)
    }
    
    static func nanumPenScriptRegular(size: CGFloat) -> Font {
        .custom("Nanum Pen", size: size)
    }
    
    static func suiteBold(size: CGFloat) -> Font {
        .custom("SUITE-Bold", size: size)
    }
    
    static func suiteSemiBold(size: CGFloat) -> Font {
        .custom("SUITE-SemiBold", size: size)
    }
}

