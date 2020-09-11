//
//  PercentageView.swift
//  SPMDemo
//
//  Created by IFTS06 on 04/09/2020.
//

import Foundation
import UIKit

// PRCENTAGE VIEW
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
            // clamp: if progress is over 1 or less than 0 give it a number
            progress = max(0, min(1, progress))
        }
        setNeedsDisplay()
      }
    }
    @IBInspectable public var firstFillColor: UIColor = UIColor.red { didSet { setNeedsDisplay() } }
    @IBInspectable public var secondFillColor: UIColor = UIColor.yellow { didSet { setNeedsDisplay() } }
    @IBInspectable public var counterColor: UIColor = UIColor.orange { didSet { setNeedsDisplay() } }
    @IBInspectable public var knobColor: UIColor = .gray  { didSet { setNeedsDisplay() } }
    let percentageLabel = UILabel(frame: CGRect(x: 150, y: 150, width: 200, height: 40))
   
    // POSITION
    public fileprivate(set) var pointerPosition: CGPoint = CGPoint()
    
    // boolean which chooses if the knob can be dragged or not
    var canDrag = false
    // variable that stores the lenght of the arc based on the last touch
    var oldLength : CGFloat = 300
    
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.hitTest(firstTouch.location(in: self), with: event)
            
            if hitView === self {
                
                let xDist = CGFloat(firstTouch.preciseLocation(in: hitView).x - pointerPosition.x)
                let yDist = CGFloat(firstTouch.preciseLocation(in: hitView).y - pointerPosition.y)
                let distance = CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
                
                if distance > 30 {
                    canDrag = false
                } else {
                    canDrag = true
                }
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.hitTest(firstTouch.location(in: self), with: event)
            
            if hitView === self {
                if canDrag == true {
                    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                    let radiusBounds = max(bounds.width, bounds.height)
                    let radius = radiusBounds/2 - Constants.arcWidth/2
                    
                    let touchX = firstTouch.preciseLocation(in: hitView).x
                    let touchY = firstTouch.preciseLocation(in: hitView).y
                    
                    // FIND THE NEAREST POINT TO THE CIRCLE FROM THE TOUCH POSITION
                    let dividendx = pow(touchX, 2) + pow(center.x, 2) - (2 * touchX * center.x)
                    let dividendy = pow(touchY, 2) + pow(center.y, 2) - (2 * touchY * center.y)
                    let dividend = sqrt(abs(dividendx) + abs(dividendy))
                    print("dividend: \(dividend)")
                    
                    let pointX = center.x + ((radius * (touchX - center.x)) / dividend)
                    let pointY = center.y + ((radius * (touchY - center.y)) / dividend)
                    
                    print("touch x: \(touchX)")
                    print("touch y: \(touchY)")
                    print("point x: \(pointX)")
                    print("point y: \(pointY)")
                    
                    // ARC LENGTH
                    let arcAngle: CGFloat = (2 * .pi) + (.pi / 4) - (3 * .pi / 4)
                    let arcLength =  arcAngle * radius
                    print("ArcLength: \(arcLength)")
                    
                    // NEW ARC LENGTH
                    
                    let xForTheta = Double(pointX) - Double(center.x)
                    let yForTheta = Double(pointY) - Double(center.y)
                    var theta : Double = atan2(yForTheta, xForTheta) - (3 * .pi / 4)
                    
                    if theta < 0 {
                        theta += 2 * .pi
                    }
                    print("theta : \(theta)")
                    
                    var newArcLength =  CGFloat(theta) * radius
                    print("newArcLength: \(newArcLength)")
                    
                    if 480.0 ... 550.0 ~= newArcLength {
                        newArcLength = 480
                    } else if 550.0 ... 630.0 ~= newArcLength {
                        newArcLength = 0
                    }
                    if oldLength == 480 && 0 ... 400 ~= newArcLength  {
                        newArcLength = 480
                    } else if oldLength == 0 && 80 ... 480 ~= newArcLength {
                        newArcLength = 0
                    }
                    oldLength = newArcLength
                    
                    // PERCENTAGE
                    let newPercentage = newArcLength/arcLength
                    progress = CGFloat(newPercentage)
                }
            }
        }
    }
    
    public func label() {
        // DRAW THE PERCENTAGE LABEL
        percentageLabel.translatesAutoresizingMaskIntoConstraints = true
        percentageLabel.font = percentageLabel.font.withSize(28)
        percentageLabel.center = CGPoint(x: 115, y: 115)
        percentageLabel.textAlignment = .center
        self.addSubview(percentageLabel)
        let percentage = Int(Double(progress * 100))
        percentageLabel.text = "\(percentage)%"
    }
    
    public override func draw(_ rect: CGRect) {
        // call label function
        label()
        
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
        
        // GRADIENT
        let c = UIGraphicsGetCurrentContext()!
        let clipPath: CGPath = insidePath.cgPath

        c.saveGState()
        c.setLineWidth(30.0)
        c.addPath(clipPath)
        c.replacePathWithStrokedPath()
        c.clip()

        // Draw gradient
        let colors = [firstFillColor.cgColor, secondFillColor.cgColor]
        let offsets = [ CGFloat(0.0), CGFloat(1.0) ]
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: offsets)
        let start = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: 230, y: 230)
        c.drawLinearGradient(grad!, start: start, end: end, options: [])

        c.restoreGState()

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // DRAW THE POINTER
        let pointerRect = CGRect(x: insidePath.currentPoint.x - Constants.arcWidth / 2, y: insidePath.currentPoint.y - Constants.arcWidth / 2, width: Constants.arcWidth, height: Constants.arcWidth)
        let pointer = UIBezierPath(ovalIn: pointerRect)
        
        knobColor.setFill()
        pointer.fill()
        insidePath.append(pointer)
        
        // SET THE POSITION
        pointerPosition = CGPoint(x: insidePath.currentPoint.x - Constants.arcWidth / 2, y: insidePath.currentPoint.y - Constants.arcWidth / 2)
    }
}
