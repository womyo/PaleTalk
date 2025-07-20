//
//  DrawingImageView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI
import Kingfisher

struct DrawingImageView: View {
    @EnvironmentObject var drawingViewModel: DrawingViewModel
    
    var body: some View {
        VStack {
            KFImage(URL(string: "\(drawingViewModel.selectedDrawing.imageUrl)"))
                .loadDiskFileSynchronously(true)
                .cacheMemoryOnly()
                .resizable()
                .scaledToFit()
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(
            Image("Sketchbook")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    DrawingImageView()
}

