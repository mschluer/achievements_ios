//
//  ProgressWheel.swift
//  achievements
//
//  Created by Maximilian Schluer on 04.10.21.
//

import Foundation
import UIKit

@IBDesignable
class ProgressWheel : UIView {
    // MARK: Properties
    @IBInspectable var activeColor: UIColor = UIColor.systemGray {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    @IBInspectable var percentage: Float = 0.0{
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    @IBInspectable var text: String = "+ / - 0" {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    @IBInspectable var textColor: UIColor = UIColor.systemGray {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    @IBInspectable var inactiveColor: UIColor = UIColor.systemGray {
        didSet {
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    // MARK: Variables
    private var labelAdded = false
    private var centerLabel : UILabel!
    
    // MARK: Initializers
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: View Methods
    override func draw(_ rect: CGRect) {
        drawLines()
        drawLabel()
    }
    
    private func drawLabel() {
        let label : UILabel
        if(!labelAdded) {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        } else {
            label = self.centerLabel
        }
        
        label.center = self.center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addConstraints([
            NSLayoutConstraint(item: label,
                               attribute: NSLayoutConstraint.Attribute.width,
                               relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual,
                               toItem: nil,
                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                               multiplier: 1,
                               constant: 95)])
        
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(21)
        
        label.text = self.text
        label.textColor = self.textColor
        
        if(!labelAdded) {
            self.addSubview(label)
            self.centerLabel = label
            labelAdded = true
        } else {
            label.setNeedsLayout()
            label.setNeedsDisplay()
        }
    }
    
    private func drawLines() {
        for i in 0...49 {
            // Determine Angle
            let angle = Float(i) * -0.126
            
            // Instanciate and configure path
            let uIBezierPath = UIBezierPath()
            UIColor.black.setStroke()
            uIBezierPath.lineWidth = 2.0
            
            // Set Color
            if(percentage <= Float(i) * 2.0) {
                inactiveColor.setStroke()
            } else {
                activeColor.setStroke()
            }
            
            // Fix for the 50 % - Case
            if(percentage == 50 && i == 25) {
                activeColor.setStroke()
            }
            
            // Move away from center
            let firstPoint = CGPoint(x: bounds.size.width / CGFloat(2.0) + CGFloat(50.0 * sin(angle)), y: bounds.size.height / CGFloat(2.0) + CGFloat(50.0 * cos(angle)))
            let secondPoint = CGPoint(x: bounds.size.width / CGFloat(2.0) + CGFloat(80.0 * sin(angle)), y: bounds.size.height / CGFloat(2.0) + CGFloat(80.0 * cos(angle)))
            uIBezierPath.move(to: firstPoint)
            
            // Paint
            uIBezierPath.addLine(to: secondPoint)
            uIBezierPath.stroke()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
}
