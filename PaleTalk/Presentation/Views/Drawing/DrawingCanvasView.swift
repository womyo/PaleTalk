//
//  DrawingCanvasView.swift
//  PaleTalk
//
//  Created by 이인호 on 7/20/25.
//

import Foundation
import SwiftUI
import PencilKit
import UIKit

extension PKDrawing {
    func saveToFirebaseStorage() {
        let uiImage = self.image(from: self.bounds, scale: 1)
    }
}

struct DrawingCanvasView: UIViewRepresentable {
    private let canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()
    
    var viewModel: DrawingViewModel
    @Binding var drawing: PKDrawing
    @Binding var toolPickerShows: Bool
    
    var onDrawingChanged: ((PKCanvasView) -> Void)?
    
    // MARK: - PencilKit
    func makeUIView(context: Context) -> PKCanvasView {
        let backgroundImageView = UIImageView(image: UIImage(named: "Sketchbook"))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.frame = canvasView.bounds
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = UIColor.clear
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        
        let contentView = canvasView.subviews[0]
        contentView.addSubview(backgroundImageView)
        contentView.sendSubviewToBack(backgroundImageView)
        
        toolPicker.setVisible(toolPickerShows, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        if toolPickerShows {
            canvasView.becomeFirstResponder()
        }
        
        viewModel.canvasView = canvasView
        viewModel.toolPicker = toolPicker
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawing: Binding<PKDrawing>
        var parent: DrawingCanvasView
        
        init(drawing: Binding<PKDrawing>, parent: DrawingCanvasView) {
            self.drawing = drawing
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing.wrappedValue = canvasView.drawing
            parent.onDrawingChanged?(canvasView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, parent: self)
    }
}
