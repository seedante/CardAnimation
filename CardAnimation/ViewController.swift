//
//  ViewController.swift
//  CardAnimation
//
//  Created by seedante on 15/9/30.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

enum panScrollDirection{
    case Up, Down
}

class ViewController: UIViewController {

    var frontCardTag = 1
    var cardCount = 8
    let gradientBackgroundLayer = CAGradientLayer()
    var originFrame = CGRectZero
    var gestureDirection:panScrollDirection = .Up

    override func viewDidLoad() {
        super.viewDidLoad()

        gradientBackgroundLayer.frame = view.bounds
        gradientBackgroundLayer.colors = [UIColor.blackColor().CGColor, UIColor.darkGrayColor().CGColor, UIColor.lightGrayColor().CGColor]
        view.layer.insertSublayer(gradientBackgroundLayer, atIndex: 0)

        self.performSelector("resetViewLayout:", withObject: nil, afterDelay: 0.1)

        let scrollGesture = UIPanGestureRecognizer(target: self, action: "scrollOnView:")
        view.addGestureRecognizer(scrollGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Action Method
    @IBAction func flipUp(sender: AnyObject) {
        if frontCardTag == 1{
            return
        }

        guard let previousFrontView = view.viewWithTag(frontCardTag - 1) else{
            return
        }

        var flipUpTransform3D = CATransform3DIdentity
        flipUpTransform3D.m34 = -1.0 / 1000.0
        flipUpTransform3D = CATransform3DRotate(flipUpTransform3D, 0, 1, 0, 0)

        UIView.animateWithDuration(0.3, animations: {
            previousFrontView.hidden = false
            previousFrontView.layer.transform = flipUpTransform3D
            }, completion: {
                _ in
                self.adjustUpViewLayout()
        })
    }

    @IBAction func flipDown(sender: AnyObject) {
        if frontCardTag > cardCount{
            return
        }

        guard let frontView = view.viewWithTag(frontCardTag) else{
            return
        }

        var flipDownTransform3D = CATransform3DIdentity
        flipDownTransform3D.m34 = -1.0 / 1000.0
        //此处有个很大的问题，折磨了我几个小时。原来官方的实现有个临界问题，旋转180度不会执行，其他的角度则没有问题
        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI) * 0.99, 1, 0, 0)
        UIView.animateWithDuration(0.3, animations: {
            frontView.layer.transform = flipDownTransform3D
            }, completion: {
                _ in

                frontView.hidden = true
                self.adjustDownViewLayout()

        })

        //使用 Core Animation 也是问题多多，首先， 将 presentLayer 和 modalLayer 同步后无动画效果。次级方案：不移除动画并在 delegate 进行后续设置，但对后续卡片的动画产生了破坏
//        let flipAnimation = CABasicAnimation(keyPath: "transform")
//        flipAnimation.toValue = NSValue.init(CATransform3D: flipDownTransform3D)
//        flipAnimation.duration = 0.3
//        flipAnimation.removedOnCompletion = false
//        flipAnimation.fillMode = kCAFillModeForwards
//        flipAnimation.delegate = self
//        frontView.layer.addAnimation(flipAnimation, forKey: "flip")
//
//        frontView.layer.transform = flipDownTransform3D
        //下面这句和上面的 layer 动画混合产生了奇妙的缩放效果，类似早期的一些电视特效
        //frontView.transform = CGAffineTransformMakeScale(-1.0, 1.0)

    }

    func scrollOnView(gesture: UIPanGestureRecognizer){
        if frontCardTag > cardCount + 1{
            frontCardTag -= 1
            return
        }

        if frontCardTag < 1{
            frontCardTag += 1
            return
        }

        let frontView = view.viewWithTag(frontCardTag)
        let previousFrontView = view.viewWithTag(frontCardTag - 1)

        let velocity = gesture.velocityInView(view)
        let percent = gesture.translationInView(view).y/150
        var flipTransform3D = CATransform3DIdentity
        flipTransform3D.m34 = -1.0 / 1000.0

        switch gesture.state{
        case .Began:

            if velocity.y > 0{
                gestureDirection = .Down
            }else{
                gestureDirection = .Up
            }

        case .Changed:

            if gestureDirection == .Down{
                switch percent{
                case 0.0..<1.0:
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI) * percent, 1, 0, 0)
                    frontView?.layer.transform = flipTransform3D
                    if percent >= 0.5{
                        if let subView = frontView?.viewWithTag(10){
                            subView.hidden = true
                            frontView?.layer.borderWidth = 0
                        }
                    }else{
                        if let subView = frontView?.viewWithTag(10){
                            subView.hidden = false
                            frontView?.layer.borderWidth = 5
                        }
                    }
                case 1.0...CGFloat(MAXFLOAT):
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI), 1, 0, 0)
                    frontView?.layer.transform = flipTransform3D
                default:
                    print(percent)
                }

            } else {

                if frontCardTag == 1{
                    return
                }

                previousFrontView?.hidden = false
                switch percent{
                case CGFloat(-MAXFLOAT)...(-1.0):
                    previousFrontView?.layer.transform = CATransform3DIdentity
                case -1.0...0:
                    if percent <= -0.5{
                        if let subView = previousFrontView?.viewWithTag(10){
                            subView.hidden = false
                            previousFrontView?.layer.borderWidth = 5
                        }
                    }else{
                        if let subView = previousFrontView?.viewWithTag(10){
                            subView.hidden = true
                            previousFrontView?.layer.borderWidth = 0
                        }
                    }
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI) * (percent+1.0), 1, 0, 0)
                    previousFrontView?.layer.transform = flipTransform3D
                default:
                    print(percent)
                }
            }

        case .Ended:

            switch gestureDirection{
            case .Down:
                if percent >= 0.5{

                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(M_PI), 1, 0, 0)
                    UIView.animateWithDuration(0.3, animations: {
                        frontView?.layer.transform = flipTransform3D
                        }, completion: {
                            _ in
                            frontView?.hidden = true
                            if frontView != nil{
                                self.adjustDownViewLayout()
                            }

                    })
                }else{
                    UIView.animateWithDuration(0.2, animations: {
                        frontView?.layer.transform = CATransform3DIdentity
                    })
                }

            case .Up:
                if frontCardTag == 1{
                    return
                }

                if percent <= -0.5{
                    UIView.animateWithDuration(0.2, animations: {
                        previousFrontView?.layer.transform = CATransform3DIdentity
                        }, completion: {
                            _ in
                            self.adjustUpViewLayout()
                    })
                }else{
                    UIView.animateWithDuration(0.2, animations: {
                        previousFrontView?.layer.transform = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI), 1, 0, 0)
                        }, completion: {
                            _ in
                            previousFrontView?.hidden = true
                    })
                }
            }
        default:
            print("DEFAULT: DO NOTHING")
        }
    }

    //MARK: Handle Layout
    func adjustUpViewLayout(){
        if frontCardTag >= 2{

            let feed: UInt32 = 2
            let randomRoll = arc4random_uniform(feed)
            switch randomRoll{
            case 0:
                for var viewTag = frontCardTag; viewTag <= cardCount; ++viewTag{
                    if let subView = view.viewWithTag(viewTag){
                        let relativeIndex = viewTag - self.frontCardTag + 1
                        let delay: NSTimeInterval = Double(viewTag - frontCardTag) * 0.1
                        UIView.animateWithDuration(0.2, delay: delay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                            let (frame, borderWidth) = self.calculateFrameAndBorderWidth(relativeIndex, initialBorderWidth: 5)
                            subView.frame = frame
                            subView.layer.borderWidth = borderWidth
                            }, completion: nil)
                    }
                }
            case 1:
                for var viewTag = cardCount; viewTag >= frontCardTag; --viewTag{
                    if let subView = view.viewWithTag(viewTag){
                        let relativeIndex = viewTag - self.frontCardTag + 1
                        let delay: NSTimeInterval = Double(cardCount - viewTag) * 0.1
                        UIView.animateWithDuration(0.2, delay: delay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                            let (frame, borderWidth) = self.calculateFrameAndBorderWidth(relativeIndex, initialBorderWidth: 5)
                            subView.frame = frame
                            subView.layer.borderWidth = borderWidth
                            }, completion: nil)
                    }
                    
                }
            default:
                print("NOT YET")
            }

            frontCardTag -= 1
        }
    }

    func adjustDownViewLayout(){
        frontCardTag += 1

        if frontCardTag <= cardCount{
            for viewTag in frontCardTag...cardCount{
                if let subView = view.viewWithTag(viewTag){

                    let delay: NSTimeInterval = 0.1 * Double(viewTag - frontCardTag)
                    UIView.animateWithDuration(0.3, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        let (frame, borderWidth) = self.calculateFrameAndBorderWidth(viewTag - self.frontCardTag, initialBorderWidth: 5)
                        subView.frame = frame
                        subView.layer.borderWidth = borderWidth
                        }, completion: nil)
                }
            }
        }
    }

    func resetViewLayout(originFrameValue: NSValue?){

        var baseFrame = CGRectZero
        if originFrameValue != nil{
            baseFrame = (originFrameValue?.CGRectValue())!
        }else{
            let frontView = view.viewWithTag(frontCardTag)!
            originFrame = frontView.frame
            baseFrame = originFrame
        }

        //adjust visible views
        if frontCardTag <= cardCount{
            for viewTag in frontCardTag...cardCount{
                if let subView = view.viewWithTag(viewTag){

                    let relativeIndex = viewTag - frontCardTag
                    let delay: NSTimeInterval = Double(relativeIndex) * 0.05
                    UIView.animateWithDuration(0.3, delay: delay, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        subView.hidden = false

                        let (frame, borderWidth) = self.calculateFrameAndBorderWidth(relativeIndex, initialBorderWidth: 5)
                        subView.frame = frame
                        subView.layer.anchorPoint = CGPointMake(0.5, 1)
                        subView.frame = frame

                        subView.layer.zPosition = CGFloat(1000-viewTag)

                        subView.layer.borderWidth = borderWidth
                        subView.layer.borderColor = UIColor.whiteColor().CGColor
                        }, completion: nil)

                }
            }
        }

        //adjust hiddened views
        if frontCardTag > 1{
            for viewTag in 1..<frontCardTag{
                if let subView = view.viewWithTag(viewTag){
                    subView.frame = baseFrame
                }
            }
        }
    }

    //MARK: Helper Method
    //f(x) = k * x + m
    func calculateFactorOfFunction(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) -> (CGFloat, CGFloat){

        let k = (y1-y2)/(x1-x2)
        let m = (x1*y2 - x2*y1)/(x1-x2)

        return (k, m)
    }

    func calculateResult(argument x: Int, k: CGFloat, m: CGFloat) -> CGFloat{
        return k * CGFloat(x) + m
    }

    func calcuteResultWith(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat, argument: Int) -> CGFloat{
        let (k, m) = calculateFactorOfFunction(x1, x2: x2, y1: y1, y2: y2)
        return calculateResult(argument: argument, k: k, m: m)
    }

    //I set the gap between 0Card and 1st Card is 30, gap between the last two card is 10.
    //设定头两个卡片的距离为30，最后两张卡片之间的举例为10。不设定成等距才符合视觉效果。
    func calculusYOffset(indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(0)
        }

        if indexInQueue >= cardCount{
            fatalError("CAN'T INPUT MORE THAN CARDCOUNT")
        }

        var sum: CGFloat = 0.0
        for i in 1...indexInQueue{
            sum += calcuteResultWith(1, x2: CGFloat(cardCount-1), y1: 30, y2: 10, argument: i)
        }

        return sum
    }

    //Zoom out card one by one.
    //为符合视觉以及营造景深效果，卡片依次缩小
    func calculateScaleFactor(indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(1)
        }

        if indexInQueue >= cardCount{
            fatalError("CAN'T INPUT MORE THAN CARDCOUNT")
        }

        return calcuteResultWith(1, x2: CGFloat(cardCount-1), y1: 0.95, y2: 0.5, argument: indexInQueue)
    }

    func calculateAlpha(indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(1)
        }

        if indexInQueue >= cardCount{
            fatalError("CAN'T INPUT MORE THAN CARDCOUNT")
        }

        return calcuteResultWith(1, x2: CGFloat(cardCount-1), y1: 1, y2: 0.8, argument: indexInQueue)
    }

    func calculateFrame(indexInQueue: Int) -> CGRect{
        let baseFrame = originFrame

        let YOffset = calculusYOffset(indexInQueue)
        let scaleFactor = calculateScaleFactor(indexInQueue)

        var realFrame = CGRectZero
        realFrame.origin.y = baseFrame.origin.y - YOffset
        realFrame.origin.x = baseFrame.origin.x + baseFrame.size.width * (1 - scaleFactor)/2
        realFrame.size.width = baseFrame.size.width * scaleFactor
        realFrame.size.height = baseFrame.size.height * scaleFactor

        return realFrame
    }

    func calculateFrameAndBorderWidth(indexInQueue: Int, initialBorderWidth: CGFloat) -> (CGRect, CGFloat){
        let baseFrame = originFrame

        let YOffset = calculusYOffset(indexInQueue)
        let scaleFactor = calculateScaleFactor(indexInQueue)

        var realFrame = CGRectZero
        realFrame.origin.y = baseFrame.origin.y - YOffset
        realFrame.origin.x = baseFrame.origin.x + baseFrame.size.width * (1 - scaleFactor)/2
        realFrame.size.width = baseFrame.size.width * scaleFactor
        realFrame.size.height = baseFrame.size.height * scaleFactor

        let realBorderWidth = initialBorderWidth * scaleFactor

        return (realFrame, realBorderWidth)
    }

    //MARK: Handle Screen Rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({
            _ in
            self.gradientBackgroundLayer.frame = self.view.bounds
            let screenRect = UIScreen.mainScreen().bounds
            let originX = (screenRect.size.width - 400)/2
            let originY = (screenRect.size.height - 300)/2
            self.originFrame = CGRectMake(originX, originY, 400, 300)
            self.resetViewLayout(NSValue.init(CGRect: self.originFrame))
            }, completion: nil)
    }
}

//最初的代码：通过 frame + transform 一起调整，总是会有问题。虽然最终解决了，代码太多了，果断放弃这种模式。
//                    subView.alpha = self.calculateAlpha(relativeIndex)
//                    subView.layer.zPosition = CGFloat(100 - viewTag)
//
//                    let YOffset = self.calculusYOffset(relativeIndex)
//                    print("\(viewTag) YOffset: \(YOffset)")
//                    let newFrame = CGRectMake(baseFrame.origin.x, baseFrame.origin.y - YOffset, baseFrame.size.width, baseFrame.size.height)
//                    subView.frame = newFrame
//
//                    let scaleFactor = self.calculateScaleFactor(relativeIndex)
//                    subView.layer.anchorPoint = CGPointMake(0.5, 0)
//                    subView.frame = newFrame
//
//                    var transform3D = CATransform3DIdentity
//                    transform3D = CATransform3DScale(transform3D, scaleFactor, scaleFactor, 0)
//                    subView.layer.transform = transform3D

