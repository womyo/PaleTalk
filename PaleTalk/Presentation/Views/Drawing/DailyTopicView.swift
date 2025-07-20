//
//  DailyTopicView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import SwiftUI

struct DailyTopicView: View {
    @State private var animate = false
    @Binding var visible: Bool
    let topic: String
    
    var body: some View {
        ZStack {
            if visible {
                Text("오늘의 주제: \(topic)")
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(14)
                    .shadow(radius: 6)
                    .opacity(animate ? 1 : 0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            animate = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeInOut(duration: 2.0)) {
                                visible = false
                            }
                        }
                    }
            }
        }
    }
}
