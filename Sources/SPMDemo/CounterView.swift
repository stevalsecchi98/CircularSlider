//
//  CounterView.swift
//  CoreGraphics_Test
//
//  Created by IFTS06 on 02/09/2020.
//  Copyright © 2020 CoreGraphics_Test. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class CounterView: UIView {
    
    private struct Constants {
        static let numberOfGlasses = 8
        static let lineWidth: CGFloat = 20.0 // 5.0
        static let arcWidth: CGFloat = 76
    
        static var halfOfLineWidth: CGFloat {
            return lineWidth / 2
        }
    }
  
    @IBInspectable public var counter: Int = 5 {
      didSet {
        if counter <=  Constants.numberOfGlasses {
          //the view needs to be refreshed
          setNeedsDisplay()
        }
      }
    }
    @IBInspectable public var outlineColor: UIColor = UIColor.blue
    @IBInspectable public var counterColor: UIColor = UIColor.orange
  
    public override func draw(_ rect: CGRect) {
        // 1 Define the center point you’ll rotate the arc around.
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        // 2 Calculate the radius based on the maximum dimension of the view.
        let radius = max(bounds.width, bounds.height)

        // 3 Define the start and end angles for the arc.
        let startAngle: CGFloat = 3 * .pi / 4
        let endAngle: CGFloat = .pi / 4

        // 4 Create a path based on the center point, radius and angles you defined.
        let path = UIBezierPath(
          arcCenter: center,
          radius: radius/2 - Constants.arcWidth/2,
          startAngle: startAngle,
          endAngle: endAngle,
          clockwise: true)

        // 5 Set the line width and color before finally stroking the path.
        path.lineWidth = Constants.arcWidth
        counterColor.setStroke()
        path.stroke()
        
        //DRAW THE OUTLINE

        //1 - first calculate the difference between the two angles
        //ensuring it is positive
        let angleDifference: CGFloat = 2 * .pi - startAngle + endAngle
        //then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(Constants.numberOfGlasses)
        //then multiply out by the actual glasses drunk
        let outlineEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle

        //2 - draw the outer arc
        let outerArcRadius = bounds.width/2 - Constants.halfOfLineWidth
        let outlinePath = UIBezierPath(
          arcCenter: center,
          radius: outerArcRadius,
          startAngle: startAngle,
          endAngle: outlineEndAngle,
          clockwise: true)

        //3 - draw the inner arc
        let innerArcRadius = bounds.width/2 - Constants.arcWidth + Constants.halfOfLineWidth
        outlinePath.addArc(
          withCenter: center,
          radius: innerArcRadius,
          startAngle: outlineEndAngle,
          endAngle: startAngle,
          clockwise: false)
            
        //4 - close the path
        outlinePath.close()
            
        outlineColor.setStroke()
        outlinePath.lineWidth = Constants.lineWidth
        outlinePath.stroke()
        
        // COUNTER VIEW MARKERS
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
          
        // 1 - Save original state
        context.saveGState()
        outlineColor.setFill()
            
        let markerWidth: CGFloat = 5.0
        let markerSize: CGFloat = 10.0

        // 2 - The marker rectangle positioned at the top left
        let markerPath = UIBezierPath(rect: CGRect(
          x: -markerWidth / 2,
          y: 0,
          width: markerWidth,
          height: markerSize))

        // 3 - Move top left of context to the previous center position
        context.translateBy(x: rect.width / 2, y: rect.height / 2)
            
        for i in 1...Constants.numberOfGlasses {
          // 4 - Save the centered context
          context.saveGState()
          // 5 - Calculate the rotation angle
          let angle = arcLengthPerGlass * CGFloat(i) + startAngle - .pi / 2
          // Rotate and translate
          context.rotate(by: angle)
          context.translateBy(x: 0, y: rect.height / 2 - markerSize)
           
          // 6 - Fill the marker rectangle
          markerPath.fill()
          // 7 - Restore the centered context for the next rotate
          context.restoreGState()
        }

        // 8 - Restore the original state in case of more painting
        context.restoreGState()
    }
}

