//
//  PercentageView.swift
//  SPMDemo
//
//  Created by IFTS06 on 04/09/2020.
//

import Foundation
import UIKit

@available(iOS 9.1, *)
@IBDesignable
public class PercentageView: UIView {
    
    private struct Constants {
        static let max : CGFloat = 1.0
        static let lineWidth: CGFloat = 5.0
        static let arcWidth: CGFloat = 30
    
        static var halfOfLineWidth: CGFloat {
            return lineWidth / 2
        }
    }
    
    @IBInspectable public var progress: CGFloat = 0.65 {
      didSet {
        if !(0...1).contains(progress) {
            // clamp: if progress is over or less than 0 and 1
            progress = max(0, min(1, progress))
        }
        setNeedsDisplay()
      }
    }
    @IBInspectable public var outlineColor: UIColor = UIColor.yellow { didSet { setNeedsDisplay() } }
    @IBInspectable public var counterColor: UIColor = UIColor.orange { didSet { setNeedsDisplay() } }
    @IBInspectable public var fillColor: UIColor = .gray  { didSet { setNeedsDisplay() } }
   
    // position
    public fileprivate(set) var pointerPosition: CGPoint = CGPoint()
    
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.hitTest(firstTouch.location(in: self), with: event)
            
            if hitView === self {
                
                var xDist = CGFloat(firstTouch.preciseLocation(in: hitView).x - pointerPosition.x)
                var yDist = CGFloat(firstTouch.preciseLocation(in: hitView).y - pointerPosition.y)
                var distance = CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
                
                if distance > 30 {
                    let percentage = Double(firstTouch.preciseLocation(in: hitView).x) / 228
                    progress = CGFloat(percentage)
                }
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.hitTest(firstTouch.location(in: self), with: event)
            
            if hitView === self {
                let percentage = Double(firstTouch.preciseLocation(in: hitView).x) / 228
                progress = CGFloat(percentage)
            }
        }
    }
    
    
    
    public override func draw(_ rect: CGRect) {
        
        // 1 Define the center point you’ll rotate the arc around.
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        // 2 Calculate the radius based on the maximum dimension of the view.
        let radius = max(bounds.width, bounds.height)

        // 3 Define the start and end angles for the arc.
        let startAngle: CGFloat = 3 * .pi / 4
        let endAngle: CGFloat = .pi / 4

        // 4 Create a path based on the center point, radius and angles you defined
        let path = UIBezierPath(
          arcCenter: center,
          radius: radius/2 - Constants.arcWidth/2,
          startAngle: startAngle,
          endAngle: endAngle,
          clockwise: true)

        // 5 Set the line width and color before finally stroking the path.
        path.lineCapStyle = .round
        path.lineWidth = Constants.arcWidth
        counterColor.setStroke()
        path.stroke()
        
        //DRAW THE INLINE

        //1 - first calculate the difference between the two angles
        //ensuring it is positive
        let angleDifference: CGFloat = 2 * .pi - startAngle + endAngle
        //then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(Constants.max)
        //then multiply out by the actual glasses drunk
        let outlineEndAngle = arcLengthPerGlass * CGFloat(progress) + startAngle
        
        // try to create an inside arc
        // radius is the same as main path
        let insidePath = UIBezierPath(
        arcCenter: center,
        radius: radius/2 - Constants.arcWidth/2,
        startAngle: startAngle,
        endAngle: outlineEndAngle,
        clockwise: true)
        
        outlineColor.setStroke()
        insidePath.lineCapStyle = .round
        insidePath.lineWidth = CGFloat(30.0)
        insidePath.stroke()
        
        
        // DRAW THE POINTER
        let pointerRect = CGRect(x: insidePath.currentPoint.x - Constants.arcWidth / 2, y: insidePath.currentPoint.y - Constants.arcWidth / 2, width: Constants.arcWidth, height: Constants.arcWidth)
        let pointer = UIBezierPath(ovalIn: pointerRect)
        
        fillColor.setFill()
        pointer.fill()
        insidePath.append(pointer)
        
        // SET THE POSITION
        pointerPosition = CGPoint(x: insidePath.currentPoint.x - Constants.arcWidth / 2, y: insidePath.currentPoint.y - Constants.arcWidth / 2)
    }
    
}
