//
//  ViewController.swift
//  CardAnimation
//
//  Created by seedante on 15/9/30.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

protocol SDECardSource{
    var cardCount: Int {get set}
    func cardImageAtIndex(index:Int) -> UIImage?
}

enum panScrollDirection{
    case Up, Down
}

enum JusticeLeagueHeroLogo: String{
    case WonderWoman = "wonder_woman_logo_by_kalangozilla.jpg"
    case Superman = "superman_kingdom_come_logo_by_kalangozilla.jpg"
    case Batman = "batman_begins_poster_style_logo_by_kalangozilla.jpg"
    case GreenLantern = "green_lantern_corps_logo_by_kalangozilla.jpg"
    case Flash = "flash_logo_by_kalangozilla.jpg"
    case Aquaman = "aquaman_young_justice_logo_by_kalangozilla.jpg"
    case CaptainMarvel = "classic_captain_marvel_jr_logo_by_kalangozilla.jpg"
    //can't find Cybord's Logo.
    case AllMembers = "JLA.jpeg"
}


class ViewController: UIViewController {

    var frontCardTag = 1
    var cardCount = 0
    let maxVisibleCardCount = 8
    let gradientBackgroundLayer = CAGradientLayer()
    var gestureDirection:panScrollDirection = .Up
    var logoArray: [JusticeLeagueHeroLogo] = [.Superman, .WonderWoman, .Batman, .GreenLantern, .Flash, .Aquaman, .CaptainMarvel, .AllMembers]{
        didSet{
            cardCount = logoArray.count
        }
    }

    @IBOutlet weak var frontCenterYConstraint: NSLayoutConstraint!

    //MARK: View Life Management
    override func viewDidLoad() {
        super.viewDidLoad()

        gradientBackgroundLayer.frame = view.bounds
        gradientBackgroundLayer.colors = [UIColor.blackColor().CGColor, UIColor.darkGrayColor().CGColor, UIColor.lightGrayColor().CGColor]
        view.layer.insertSublayer(gradientBackgroundLayer, atIndex: 0)

        let scrollGesture = UIPanGestureRecognizer(target: self, action: "scrollOnView:")
        view.addGestureRecognizer(scrollGesture)

        cardCount = logoArray.count
        relayoutSubViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Data Source
    func cardImageAtIndex(index: Int) -> UIImage?{
        return UIImage(named: logoArray[index].rawValue)!
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

        previousFrontView.hidden = false

        let duration: NSTimeInterval = 0.5
        //adjust borderWidth. Because the animation of  borderWidth change in keyFrame animation can't work, so place it in dispatch_after
        //本来 layer 的 borderWidth 是个可以动画的属性，但是在 UIView Animation 却不工作，没办法，只能用这种方式了
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC) / 2.0))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            previousFrontView.layer.borderWidth = previousFrontView.frame.width / 100.0
        })

        //See annotation blew in flipDown: function.
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {

            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: {
                previousFrontView.layer.transform = CATransform3DIdentity
            })

            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.01, animations: {
                if let subView = previousFrontView.viewWithTag(10){
                    subView.alpha = 1
                }
            })


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


        let duration: NSTimeInterval = 0.5
        //adjust borderWidth. Because the animation of  borderWidth change in keyFrame animation can't work, so place it in dispatch_after
        //本来 layer 的 borderWidth 是个可以动画的属性，但是在 UIView Animation 却不工作，没办法，只能用这种方式了
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC) / 2.0))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            frontView.layer.borderWidth = 0
        })

        var flipDownTransform3D = CATransform3DIdentity
        flipDownTransform3D.m34 = -1.0 / 1000.0

        //There is a bug when you want to rotate 180, if you use UIView blcok animation, it doesn't work as expected: 1.no animation, just jump to final value; 2.rotate wrong direction.
        //You could use a closed value or animate it in UIView key frame animation.
        //此处有个很大的问题，折磨了我几个小时。官方的实现有Bug，在 UIView block animation 里旋转180度时会出现两种情况，一是不会执行动画而是直接跳到终点值，二是反方向旋转。
        //其他的角度没有问题，这里使用近似值替代不会产生这个个问题。不过, 在 key frame animation 里执行这个动画是正常的。
//        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI)*0.99, 1, 0, 0)
//        UIView.animateWithDuration(duration, animations: {
//            frontView.layer.transform = flipDownTransform3D
//        })

        //And in key frame animtion, we can fix another bug: a view is transparent in transform rotate. 
        //I put the view which show the content in a container view, when the container view is vertical to screen, hide the nested content view, then we can see only the content of background color, just like the back of a card.
        //用 key frame animation 可以方便地解决卡片在旋转过程中背面透明的问题，解决办法是将内容视图放入一个容器视图，当容器视图旋转90时，此时将内容视图隐藏，从这时候开始我们就只能看到容器视图的背景色了，这样一来就和现实接近了。
        //而在普通的 UIView animation 里，在旋转一半的时候将内容视图隐藏比较麻烦，比如先旋转90度，在 completion block 里将内容视图隐藏，然后再添加一个动画继续旋转。用 key frame 里就比较方便，而且没有UIView animation 里旋转180有问题的 bug。
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {

            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: {
                let flipDownHalfTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI), 1, 0, 0)
                frontView.layer.transform = flipDownHalfTransform3D
            })

            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.01, animations: {
                if let subView = frontView.viewWithTag(10){
                    subView.alpha = 0
                }
            })

            }, completion: {
                _ in
                frontView.hidden = true
                self.adjustDownViewLayout()
                
        })
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
                    //Here, like flipDown/Up function, is to fix transparent back bug in rotate. When rotate 90, hidden the content view, then we can see the back only.
                    //And take care of borderWidth.
                    if percent >= 0.5{
                        if let subView = frontView?.viewWithTag(10){
                            subView.hidden = true
                            frontView?.layer.borderWidth = 0
                        }
                    }else{
                        if let subView = frontView?.viewWithTag(10){
                            subView.hidden = false
                            frontView?.layer.borderWidth = subView.frame.width / 100
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
                            previousFrontView?.layer.borderWidth = subView.frame.width / 100
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
    func relayoutSubViewWith(viewTag: Int, relativeIndex:Int, delay: NSTimeInterval, haveBorderWidth: Bool){
        let width = view.bounds.size.width
        if let subView = view.viewWithTag(viewTag){

            subView.layer.anchorPoint = CGPointMake(0.5, 1)

            if let nestedImageView = subView.viewWithTag(10) as? UIImageView{
                nestedImageView.image = cardImageAtIndex(viewTag - 1)
            }

            subView.layer.zPosition = CGFloat(1000 - relativeIndex)
            subView.alpha = calculateAlphaForIndex(relativeIndex)

            var borderWidth: CGFloat = 0
            let filterSubViewConstraints = subView.constraints.filter({$0.firstAttribute == .Width && $0.secondItem == nil})
            if filterSubViewConstraints.count > 0{
                let widthConstraint = filterSubViewConstraints[0]
                let widthScale = calculateWidthScaleForIndex(relativeIndex)
                widthConstraint.constant = widthScale * width
                borderWidth = width * widthScale / 100
            }

            let filteredViewConstraints = view.constraints.filter({$0.firstItem as? UIView == subView && $0.secondItem as? UIView == view && $0.firstAttribute == .CenterY})
            if filteredViewConstraints.count > 0{
                let centerYConstraint = filteredViewConstraints[0]
                let subViewHeight = calculateWidthScaleForIndex(relativeIndex) * width * 3 / 4
                let YOffset = calculusYOffsetForIndex(relativeIndex)
                centerYConstraint.constant = subViewHeight/2 - YOffset
            }

            if haveBorderWidth{
                subView.layer.borderWidth = borderWidth
            }else{
                subView.layer.borderWidth = 0
            }


            UIView.animateWithDuration(0.2, delay: delay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }

    func adjustUpViewLayout(){
        if frontCardTag >= 2{
            let endCardTag = cardCount - frontCardTag > maxVisibleCardCount - 1 ? (frontCardTag + maxVisibleCardCount - 1) : cardCount
            let feed: UInt32 = 2
            let randomRoll = arc4random_uniform(feed)
            switch randomRoll{
            case 0:
                for var viewTag = frontCardTag; viewTag <= endCardTag; ++viewTag{
                    let delay: NSTimeInterval = Double(viewTag - frontCardTag)*0.1
                    let relativeIndex = viewTag - frontCardTag + 1
                    relayoutSubViewWith(viewTag, relativeIndex: relativeIndex, delay: delay, haveBorderWidth: true)
                }
            case 1:
                for var viewTag = endCardTag; viewTag >= frontCardTag; --viewTag{
                    let delay: NSTimeInterval = Double(cardCount - viewTag) * 0.1
                    let relativeIndex = viewTag - frontCardTag + 1
                    relayoutSubViewWith(viewTag, relativeIndex: relativeIndex, delay: delay, haveBorderWidth: true)
                }
            default:
                print("NOT YET")
            }

            frontCardTag -= 1
        }
    }

    func adjustDownViewLayout(){
        frontCardTag += 1
        let endCardTag = cardCount - frontCardTag > maxVisibleCardCount - 1 ? (frontCardTag + maxVisibleCardCount - 1) : cardCount
        if frontCardTag <= endCardTag{
            for viewTag in frontCardTag...endCardTag{
                let delay: NSTimeInterval = 0.1 * Double(viewTag - frontCardTag)
                let relativeIndex = viewTag - frontCardTag
                relayoutSubViewWith(viewTag, relativeIndex: relativeIndex, delay: delay, haveBorderWidth: true)
            }
        }
    }

    func relayoutSubViews(){
        let endCardTag = cardCount - frontCardTag > maxVisibleCardCount - 1 ? (frontCardTag + maxVisibleCardCount - 1) : cardCount
        if frontCardTag <= endCardTag{
            for viewTag in frontCardTag...endCardTag{
                if let subView = view.viewWithTag(viewTag){

                    let relativeIndex = viewTag - frontCardTag
                    let delay: NSTimeInterval = 0

                    subView.layer.borderColor = UIColor.whiteColor().CGColor
                    relayoutSubViewWith(viewTag, relativeIndex: relativeIndex, delay: delay, haveBorderWidth: true)

                }
            }
        }

        //adjust hiddened views
        if frontCardTag > 1{
            for viewTag in 1..<frontCardTag{
                relayoutSubViewWith(viewTag, relativeIndex: 0, delay: 0, haveBorderWidth: false)
            }
        }

        UIView.animateWithDuration(0.1, animations: {
            self.view.layoutIfNeeded()
        })

    }

    //MARK: Handle Screen Rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({
            _ in
            self.gradientBackgroundLayer.frame = self.view.bounds
            self.relayoutSubViews()
            }, completion: nil)
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

    //I set the gap between 0Card and 1st Card is 35, gap between the last two card is 15. These value on iPhone is a little big, you could make it less.
    //设定头两个卡片的距离为35，最后两张卡片之间的举例为15。不设定成等距才符合视觉效果。
    func calculusYOffsetForIndex(indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(0)
        }

        var sum: CGFloat = 0.0
        for i in 1...indexInQueue{
            var result = calcuteResultWith(1, x2: 8, y1: 35, y2: 15, argument: i)
            if result < 5{
                result = 5.0
            }
            sum += result
        }

        return sum
    }

    func calculateWidthScaleForIndex(indexInQueue: Int) -> CGFloat{
        let widthBaseScale:CGFloat = 0.5

        var factor: CGFloat = 1
        if indexInQueue == 0{
            factor = 1
        }else{
            factor = calculateScaleFactorForIndex(indexInQueue)
        }

        return widthBaseScale * factor
    }

    //Zoom out card one by one.
    //为符合视觉以及营造景深效果，卡片依次缩小
    func calculateScaleFactorForIndex(indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(1)
        }

        var scale = calcuteResultWith(1, x2: 8, y1: 0.95, y2: 0.5, argument: indexInQueue)
        if scale < 0.1{
            scale = 0.1
        }

        return scale
    }

    func calculateAlphaForIndex(indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(1)
        }

        var alpha = calcuteResultWith(6, x2: 9, y1: 1, y2: 0.4, argument: indexInQueue)
        if alpha < 0.1{
            alpha = 0.1
        }else if alpha > 1{
            alpha = 1
        }

        return alpha
    }

    func calculateBorderWidthForIndex(indexInQueue: Int, initialBorderWidth: CGFloat) -> CGFloat{
        let scaleFactor = calculateScaleFactorForIndex(indexInQueue)
        return scaleFactor * initialBorderWidth
    }

}

