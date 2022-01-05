//
//  YPCameraView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

internal class YPCameraView: UIView, UIGestureRecognizerDelegate {
    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    let timeElapsedLabel = UILabel()
    let progressBar = UIProgressView()
    
    convenience init(overlayView: UIView? = nil) {
        self.init(frame: .zero)
        
        if let overlayView = overlayView {
            // View Hierarchy
            sv(
                previewViewContainer,
                overlayView,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                buttonsContainer.sv(
                    shotButton
                )
            )
        } else {
            // View Hierarchy
            sv(
                previewViewContainer,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                buttonsContainer.sv(
                    shotButton
                )
            )
        }
        
        // Layout
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        
        switch YPConfig.proportions {
        case .default:
            layout(
                0,
                |-sideMargin-previewViewContainer-sideMargin-|,
                -2,
                |progressBar|,
                0
            )
            
            previewViewContainer.fillContainer()
            
            buttonsContainer.fillHorizontally()
            buttonsContainer.height(100)
            buttonsContainer.Bottom == previewViewContainer.Bottom - 50
        
        case .square:
            layout(
                0,
                |-sideMargin-previewViewContainer-sideMargin-|,
                -2,
                |progressBar|,
                0,
                |buttonsContainer|,
                0
            )
            
            previewViewContainer.heightEqualsWidth()
        
        case .custom(let heightToWidthRatio):
            layout(
                0,
                |-sideMargin-previewViewContainer-sideMargin-|,
                -2,
                |progressBar|,
                0,
                |buttonsContainer|,
                0
            )
            
            previewViewContainer.Height == previewViewContainer.Width * heightToWidthRatio
        }
        
        overlayView?.followEdges(previewViewContainer)
        
        |-(15+sideMargin)-flashButton.size(42)
        flashButton.Bottom == previewViewContainer.Bottom - 15
        
        flipButton.size(42)-(15+sideMargin)-|
        flipButton.Bottom == previewViewContainer.Bottom - 15
        
        timeElapsedLabel-(15+sideMargin)-|
        timeElapsedLabel.Top == previewViewContainer.Top + 15
        
        shotButton.centerVertically()
        shotButton.size(84).centerHorizontally()
        
        // Style
        backgroundColor = YPConfig.colors.photoVideoScreenBackgroundColor
        previewViewContainer.backgroundColor = UIColor.ypLabel
        timeElapsedLabel.style { l in
            l.textColor = .white
            l.text = "00:00"
            l.isHidden = true
            l.font = YPConfig.fonts.cameraTimeElapsedFont
        }
        progressBar.style { p in
            p.trackTintColor = .clear
            p.tintColor = .ypSystemRed
        }
        flashButton.setImage(YPConfig.icons.flashOffIcon, for: .normal)
        flipButton.setImage(YPConfig.icons.loopIcon, for: .normal)
        shotButton.setImage(YPConfig.icons.capturePhotoImage, for: .normal)
    }
}

public class YPCircleLayerView: UIView {
    private var circleLayer = CAShapeLayer()
    
    public init() {
        super.init(frame: .zero)
        updateCircleLayer()
        layer.addSublayer(circleLayer)
        isUserInteractionEnabled = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateCircleLayer()
    }
    
    private func updateCircleLayer() {
        let shapeLayer = circleLayer
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let minLength = min(bounds.width, bounds.height)
        let radians = Measurement(value: 360, unit: UnitAngle.degrees).converted(to: .radians).value
        
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: minLength / 2,
                                      startAngle: 0,
                                      endAngle: CGFloat(radians),
                                      clockwise: true)

        circlePath.append(UIBezierPath(rect: bounds))
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = YPConfig.colors.cropOverlayColor.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class YPRectangleLayerView: UIView {
    private var rectangleLayer = CAShapeLayer()
    private let heightToWidthRatio: CGFloat
    
    public init(heightToWidthRatio: CGFloat) {
        self.heightToWidthRatio = heightToWidthRatio

        super.init(frame: .zero)
        
        updateRectangleLayer()
        layer.addSublayer(rectangleLayer)
        isUserInteractionEnabled = false
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateRectangleLayer()
    }
    
    private func updateRectangleLayer() {
        let shapeLayer = rectangleLayer
        
        let innerRectWidth = bounds.height / heightToWidthRatio
        let innerPath = UIBezierPath(rect: CGRect(x: (bounds.width - innerRectWidth)/2, y: 0, width: innerRectWidth, height: bounds.height))

        innerPath.append(UIBezierPath(rect: bounds))
        
        shapeLayer.path = innerPath.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.black.withAlphaComponent(0.4).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
