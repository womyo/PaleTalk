//
//  ThemeSettingView.swift
//  PaleTalk
//
//  Created by 이인호 on 10/27/25.
//

import SwiftUI

struct ThemeSettingView: View {
    @Binding var theme: Theme
    
    var body: some View {
        List(Theme.allCases, id: \.self) { theme in
            HStack {
                Text("\(theme.rawValue)")
                    .foregroundStyle(Color.text)
                
                Spacer()
                
                if theme == self.theme {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.text)
                }
            }
            .contentShape(Rectangle())
            .listRowBackground(Color.border.opacity(0.4))
            .onTapGesture {
                self.theme = theme
            }
        }
        .navigationTitle("화면 테마")
        .background(theme.mainColor)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
    }
}
