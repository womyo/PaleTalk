//
//  HomeView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI

struct HomeView: View {
    @State var whichView: Bool = true
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            if whichView {
                NightskyView(whichView: $whichView)
            } else {
                PaletteView(whichView: $whichView)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: whichView)
    }
}

#Preview {
    HomeView()
}
