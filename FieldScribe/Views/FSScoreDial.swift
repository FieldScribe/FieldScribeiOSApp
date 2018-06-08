//
//  FieldScribeDial.swift
//  FieldScribe
//
//  Created by Cody Garvin on 5/9/18.
//  Copyright © 2018 OIT. All rights reserved.
//

import UIKit

protocol FSScoreDialDelegate: AnyObject {
    func dialDidUpdateValue(_ dial: FSScoreDial, value: Int)
    func dialDidTap(_ dial: FSScoreDial)
    func dialShouldRotate(_ dial: FSScoreDial) -> Bool
}

class FSScoreDial: UIView, UIGestureRecognizerDelegate {
    
    // User Facing properties
    weak var delegate: FSScoreDialDelegate?
    var value: Int = 0 {
        didSet {
            if value <= minValue {
                currentValue = minValue
            } else if value >= maxValue {
                currentValue = maxValue
            } else {
                currentValue = value
            }
            
            if let delegate = delegate {
                delegate.dialDidUpdateValue(self, value: currentValue)
            }
            
            updateDialRotation()
        }
    }
    var displayLabel: UILabel? = nil
    var clickLabel: UILabel? = nil
    
    // Internal properties
    var centerPoint: CGPoint = CGPoint(x: 0, y: 0)
    var objectValue: String? = nil
    var availableValues: Array<Int>? = nil
    
    var currentValue: Int = 0
    var maxValue: Int = 0
    var minValue: Int = 0
    var fullRotationValue: Int = 1
    
    var sliderImageView: UIImageView! = nil
    var isOutOfScope: Bool = false
    var _lastPosition: CGPoint = CGPoint(x: 0, y: 0)
    var _lastChangedAngle: CGFloat = 0
    var _distanceForIcons: CGFloat = 0
    var panGestureRecognizer: UIPanGestureRecognizer? = nil
    var tapGestureRecognizer: UITapGestureRecognizer? = nil
    

    init(frame: CGRect, minValue: Int, maxValue: Int, fullRotationValue: Int) {
        super.init(frame: frame)
        
        self.maxValue = maxValue
        self.minValue = minValue
        self.fullRotationValue = fullRotationValue
        centerPoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        // Add the main spinning image
        sliderImageView = UIImageView(image: UIImage(named: "Dial"))
        sliderImageView.bounds = self.bounds
        sliderImageView.center = self.centerPoint
        addSubview(sliderImageView)
        
        // Add the label to display text
        displayLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 30, height: 64))
        displayLabel?.isUserInteractionEnabled = false
        displayLabel?.backgroundColor = UIColor.clear
        displayLabel?.textColor = UIColor.fsMediumGreen()
        displayLabel?.font = UIFont.boldSystemFont(ofSize: 42.0)
        displayLabel?.textAlignment = .center
        displayLabel?.text = "----"
        addSubview(displayLabel!)
        displayLabel?.center = center
        
        clickLabel = UILabel(frame: CGRect.zero)
        clickLabel?.textColor = UIColor.fsMediumGreen()
        clickLabel?.text = "TAP TO RECORD SCORE"
        clickLabel?.font = UIFont.systemFont(ofSize: 12)
        addSubview(clickLabel!)
        clickLabel?.sizeToFit()
        clickLabel?.center = center
        var rect = clickLabel?.frame
        rect!.origin.y = displayLabel!.frame.origin.y + displayLabel!.frame.size.height + 2
        clickLabel?.frame = rect!
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGestureRecognizer?.delegate = self
        addGestureRecognizer(panGestureRecognizer!)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        tapGestureRecognizer?.delegate = self
        addGestureRecognizer(tapGestureRecognizer!)
        
        defer {
            self.value = minValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        removeGestureRecognizer(panGestureRecognizer!)
        removeGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc
    func onPan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        
        let perInterval = -1
        let angleInterval = CGFloat(10 * Double.pi/180)
        
        let distanceToMiddle = distanceBetween(point1: centerPoint, point2: location)
        isOutOfScope = (distanceToMiddle < clearMiddle())
        
        if sender.state == .changed || sender.state == .began {
            
            // Check if we should lock out
            if let delegate = delegate {
                if !delegate.dialShouldRotate(self) {
                    return
                }
            }
            
            if !isOutOfScope {
                var sliderStartPoint = _lastPosition
                if __CGPointEqualToPoint(_lastPosition, CGPoint.zero) {
                    sliderStartPoint = location
                }
                
                let angle = angleBetweenCenterPoint(centerPoint, point1: sliderStartPoint, point2: location)
                
                _lastChangedAngle = _lastChangedAngle + angle
                _lastPosition = location
                let numberOfIntervals = Int(round(_lastChangedAngle / angleInterval))
                
                if numberOfIntervals != 0 {
                    let newValue = currentValue + (perInterval * numberOfIntervals)
                    value = newValue
                    _lastChangedAngle = 0
                }
            } else {
                _lastPosition = CGPoint.zero
                _lastChangedAngle = 0
            }
        }
        
        if sender.state == .ended {
            _lastPosition = CGPoint.zero
            _lastChangedAngle = 0
        }
    }
    
    @objc
    func onTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let delegate = delegate {
                delegate.dialDidTap(self)
            }
        }
    }
}

extension FSScoreDial {

    
    func distanceBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        return sqrt(pow(point2.x - point1.x, 2) +  pow(point2.y - point1.y, 2))
    }
    
    func clearMiddle() -> CGFloat {
        return 45.0
    }
    
    func angleBetweenCenterPoint(_ centerPoint: CGPoint, point1: CGPoint, point2: CGPoint) -> CGFloat {
        
        let v1 = CGPoint(x: point1.x - centerPoint.x, y: point1.y - centerPoint.y)
        let v2 = CGPoint(x: point2.x - centerPoint.x, y: point2.y - centerPoint.y)
        
        let angle = atan2f(Float(v2.x * v1.y - v1.x * v2.y), Float(v1.x * v2.x + v1.y * v2.y))
        
        return CGFloat(angle)
    }
    
    func updateDialRotation() {

        let angleCalculation: CGFloat = CGFloat((Double(currentValue) * Double.pi) / (30.0 / (60.0 / Double(fullRotationValue))))
        sliderImageView.transform = CGAffineTransform(rotationAngle: angleCalculation)
    }
}
