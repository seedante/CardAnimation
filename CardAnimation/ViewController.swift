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
    case AllMembers = "JLAFRICA.jpeg"
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
    @IBAction func addCard(sender: AnyObject) {
        let newCardView = createNewCardViewWith(UIImage(named: JusticeLeagueHeroLogo.Batman.rawValue))
        view.addSubview(newCardView)

        logoArray.append(.Batman)
        let YOffset = 0 - calculusYOffsetForIndex(logoArray.count)
        let widthConstraint = calculateWidthScaleForIndex(logoArray.count) * view.bounds.size.width
        let borderWidth = widthConstraint/100
        newCardView.layer.borderColor = UIColor.whiteColor().CGColor
        newCardView.layer.borderWidth = borderWidth
        //添加layout constraint 必须在 addSubView() 后执行
        NSLayoutConstraint(item: newCardView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: newCardView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: YOffset).active = true
        NSLayoutConstraint(item: newCardView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: widthConstraint).active = true
        NSLayoutConstraint(item: newCardView, attribute: .Width, relatedBy: .Equal, toItem: newCardView, attribute: .Height, multiplier: 4.0/3.0, constant: 0).active = true

    }

    func createNewCardViewWith(image: UIImage?) -> UIView{
        let newCardView = UIView()
        newCardView.translatesAutoresizingMaskIntoConstraints = false
        newCardView.backgroundColor = UIColor.brownColor()
        newCardView.tag = logoArray.count + 1
        newCardView.clipsToBounds = true
        newCardView.alpha = calculateAlphaForIndex(logoArray.count + 1 - frontCardTag)
        newCardView.layer.zPosition = CGFloat(1000 - logoArray.count - 1 + frontCardTag)


        let subImageView = UIImageView(image: image)
        subImageView.translatesAutoresizingMaskIntoConstraints = false
        subImageView.contentMode = .ScaleAspectFill
        subImageView.clipsToBounds = true
        subImageView.tag = 10

        newCardView.addSubview(subImageView)
        NSLayoutConstraint(item: subImageView, attribute: .CenterX, relatedBy: .Equal, toItem: newCardView, attribute: .CenterX, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: subImageView, attribute: .CenterY, relatedBy: .Equal, toItem: newCardView, attribute: .CenterY, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: subImageView, attribute: .Width, relatedBy: .Equal, toItem: newCardView, attribute: .Width, multiplier: 1, constant: 0).active = true
        NSLayoutConstraint(item: subImageView, attribute: .Height, relatedBy: .Equal, toItem: newCardView, attribute: .Height, multiplier: 1, constant: 0).active = true

        return newCardView
    }


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

        previousFrontView.hidden = false
        if let subView = previousFrontView.viewWithTag(10){
            subView.hidden = false
        }

        UIView.animateWithDuration(0.2, animations: {
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

        if let subView = frontView.viewWithTag(10){
            subView.hidden = true
        }

        var flipDownTransform3D = CATransform3DIdentity
        flipDownTransform3D.m34 = -1.0 / 1000.0
        //此处有个很大的问题，折磨了我几个小时。原来官方的实现有个临界问题，旋转180度不会执行，其他的角度则没有问题
        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI)*0.99, 1, 0, 0)
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
    func relayoutSubViewWith(viewTag: Int, relativeIndex:Int, delay: NSTimeInterval, haveBorderWidth: Bool){
        let width = view.bounds.size.width
        if let subView = view.viewWithTag(viewTag){

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
                    subView.layer.anchorPoint = CGPointMake(0.5, 1)
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


    //MARK: Handle Screen Rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({
            _ in
            self.gradientBackgroundLayer.frame = self.view.bounds
            self.relayoutSubViews()
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

