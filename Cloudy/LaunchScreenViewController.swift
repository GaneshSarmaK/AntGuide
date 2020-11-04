//
//  LaunchScreenViewController.swift
//  Cloudy
//
//  Created by NVR4GET on 9/5/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController, CAAnimationDelegate {

    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
        self.window!.makeKeyAndVisible()
        
        // logo mask
        self.view.layer.mask = CALayer()
        self.view.layer.mask!.contents = UIImage(named: "antPng")!.cgImage
        self.view.layer.mask!.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        self.view.layer.mask!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view.layer.mask!.position = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        
        // logo mask background view
        var maskBgView = UIView(frame: self.view.frame)
        maskBgView.backgroundColor = UIColor(hex: "E09F3E")
        self.view.addSubview(maskBgView)
        self.view.bringSubviewToFront(maskBgView)
        
        // logo mask animation
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.delegate = self
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(cgRect: self.view.layer.mask!.bounds)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 2000, height: 2000))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut), CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.fillMode = CAMediaTimingFillMode.forwards
        self.view.layer.mask!.add(transformAnimation, forKey: "maskAnimation")
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.1,
            delay: 1.35,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: {
                maskBgView.alpha = 0.0
            },
            completion: { finished in
                maskBgView.removeFromSuperview()
        })
        
        // root view animation
        UIView.animate(withDuration: 0.25,
            delay: 1.3,
            options: UIView.AnimationOptions.init(),
            animations: {
                self.window!.rootViewController!.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            },
            completion: { finished in
                UIView.animate(withDuration: 0.3,
                    delay: 0.0,
                    options: UIView.AnimationOptions.curveEaseInOut,
                    animations: {
                        self.view.transform = CGAffineTransform()
                    },
                    completion: nil
                )
        })

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
