//
//  ProgressBar.swift
//  Cloudy
//
//  Created by Ganesh on 13/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

//Reference https://www.tutorialspoint.com/create-circular-progress-bar-in-ios

import UIKit

class ProgressBar: UIView {
        
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    var progressColor = UIColor.systemGreen
    var trackColor = UIColor.lightGray

    func makeCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: 37, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        
        //background tracking layer properties
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 2.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        //foreground progress layer properties
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeCircularPath()
    }

    
    func setProgressWithAnimation(duration: TimeInterval, fromValue: Float, toValue: Float) {
        
        //the next 2 lines make sure there is no animation everytime from 0 to fromValue
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = CGFloat(fromValue)
        
        //animation from the fromvalue to toValue percentages
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        //progressLayer.strokeStart = CGFloat(fromValue)
        progressLayer.strokeEnd = CGFloat(toValue)
        progressLayer.add(animation, forKey: "animateProgress")
    }
}
