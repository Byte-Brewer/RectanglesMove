//
//  ViewController.swift
//  AnimateRectanglesPartOne
//
//  Created by Nazar on 19.04.18.
//  Copyright © 2018 Nazar. All rights reserved.
//

import UIKit

enum TypeOfShape {
    case Circle
    case Rectangle
}

enum TypeOfRectangle: String {
    case Rectangle
    case Square
}

class ViewController: UIViewController {
    
    private var draginView: UIView?
    private var firstPoint: CGPoint = .zero
    private var typeOfShape: TypeOfShape = .Circle
    private var typeOfRectangle: TypeOfRectangle? {
        didSet {
            print("Type of rectangle: ", typeOfRectangle?.rawValue ?? "without of shape")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGesture(view: self.view)
    }
    
    private func addGesture(view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.doSomeThing(gesture:)))
        view.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.moveSomeThing(gesture:)))
        view.addGestureRecognizer(pan)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.changeColor(gesture:)))
        longPress.minimumPressDuration = 1.3
        view.addGestureRecognizer(longPress)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.removeObject(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotations(gesture:)))
        view.addGestureRecognizer(rotation)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.scale(gesture:)))
        view.addGestureRecognizer(pinch)
    }
    
    @objc private func doSomeThing(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self.view)
        let pointOnMainView = gesture.location(in: self.view)
        let topView = self.view.hitTest(pointOnMainView, with: nil)
        
        if self.view.isEqual(topView) {
            switch typeOfShape {
            case .Circle:
                drawCircle(point: point)
                typeOfShape = .Rectangle
            case .Rectangle:
                drawRectangle(point: point)
                typeOfShape = .Circle
            }
        }
    }
    
    private func drawCircle(point: CGPoint) {
        self.firstPoint = point
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: point.x, y: point.y), radius: CGFloat(6), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        self.view.layer.addSublayer(shapeLayer)
    }
    
    private func drawRectangle(point: CGPoint) {
        let secondPoint = getSizeOfRectangle(secondPoint: point)
        defineTypeOfRectangle(secondPoint.0, secondPoint.1)
        let rectangle = UIView(frame: CGRect(x: point.x, y: point.y, width: secondPoint.0, height: secondPoint.1))
        rectangle.backgroundColor = UIColor.green
        
        self.view.layer.sublayers?.last?.removeFromSuperlayer()     // not the best way
        self.view.addSubview(rectangle)
        self.draginView = rectangle
        
        UIView.animate(withDuration: 0.4) {
            rectangle.transform = CGAffineTransform.init(scaleX: 1.7, y: 1.7)
            rectangle.backgroundColor = UIColor.yellow
        }
        
        UIView.animate(withDuration: 0.3) {
            rectangle.transform = .identity
            rectangle.backgroundColor = self.randomColor()
        }
        typeOfShape = .Circle
    }
    
    @objc private func moveSomeThing(gesture: UIGestureRecognizer) {
        let pointOnMainView = gesture.location(in: self.view)
        let topView = self.view.hitTest(pointOnMainView, with: nil)
        
        if typeOfShape == .Rectangle {
            drawRectangle(point: pointOnMainView)
        }
        
        if !self.view.isEqual(topView) {
            self.view.bringSubview(toFront: topView!)
            topView?.center = gesture.location(in: self.view)
        }
    }
    
    @objc private func changeColor(gesture: UIGestureRecognizer) {
        if chooseLayer(gesture: gesture) {
            self.draginView?.backgroundColor = randomColor()
            print("changeColor: ")
        }
    }
    
    @objc private func removeObject(gesture: UIGestureRecognizer) {
        if chooseLayer(gesture: gesture) {
            
            UIView.animate(withDuration: 0.3) {
                self.draginView?.transform = CGAffineTransform.init(translationX: -400, y: -400)
                print("animate: ")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.draginView?.removeFromSuperview()
                print("removeFromSuperview")
            }
        }
    }
    
    @objc private func rotations(gesture: UIRotationGestureRecognizer) {
        if chooseLayer(gesture: gesture) {
            switch gesture.state {
            case .changed , .began :
                print("rotated: ", gesture.rotation)
                self.draginView?.transform = CGAffineTransform.init(rotationAngle: gesture.rotation)
            default: break
            }
        }
    }
    
    @objc private func scale(gesture: UIPinchGestureRecognizer) {
        if chooseLayer(gesture: gesture) {
            switch gesture.state {
            case .changed , .began :
                self.draginView?.transform = CGAffineTransform.init(scaleX: gesture.scale, y: gesture.scale)
            default: break
            }
        }
    }
    
    @objc private func changeSize(gesture: UIPinchGestureRecognizer) {
        if chooseLayer(gesture: gesture) {
            print("changeSize: ")
        }
    }
    
    private func chooseLayer(gesture: UIGestureRecognizer) -> Bool {
        self.draginView = nil
        var rectangleIsChoose = false
        let pointOnMainView = gesture.location(in: self.view)
        let topView = self.view.hitTest(pointOnMainView, with: nil)
        if !self.view.isEqual(topView) {
            self.view.bringSubview(toFront: topView!)
            self.draginView = topView
            rectangleIsChoose = true
        }
        return rectangleIsChoose
    }
    
    private func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(256))/255
        let g = CGFloat(arc4random_uniform(256))/255
        let b = CGFloat(arc4random_uniform(256))/255
        print(r,g,b)
        return UIColor(red: r, green: g, blue: b, alpha: 0.8)
    }
    
    private func getSizeOfRectangle(secondPoint: CGPoint) -> (CGFloat, CGFloat) {
        var x = firstPoint.x - secondPoint.x
        var y = firstPoint.y - secondPoint.y
        if x >= 0 && x < 100 {
            x = 100
        } else if x <= 0 && x > -100 {
            x = -100
        }
        
        if y >= 0 && y < 100 {
            y = 100
        } else if y <= 0 && y > -100 {
            y = -100
        }
        return (x, y)
    }
    
    private func defineTypeOfRectangle(_ x: CGFloat, _ y: CGFloat) {
        if abs(Int32(x)) == abs(Int32(y)) {
            self.typeOfRectangle = TypeOfRectangle.Square
        } else {
            self.typeOfRectangle = TypeOfRectangle.Rectangle
        }
    }
}
