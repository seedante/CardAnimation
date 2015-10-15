//
//  AnimatedCardsView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 14/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit

public protocol AnimatedCardsViewDataSource : class {
    func numberOfVisibleCards() -> Int
    func numberOfCards() -> Int
    func contentForCardNumber(number:Int, size:(width:CGFloat, height:CGFloat)) -> UIView
}

public class AnimatedCardsView: UIView {

    private var cardArray : [UIView]!
    private lazy var gestureRecognizer : UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: "scrollOnView:")
    }()
    
    public weak var dataSourceDelegate : AnimatedCardsViewDataSource? {
        didSet {
            if dataSourceDelegate != nil {
                configure()
            }
        }
    }
    
    public struct Constants {
        struct DefaultSize {
            static let width : CGFloat = 400.0
            static let ratio : CGFloat = 3.0 / 4.0
        }
    }
    
    private struct PrivateConstants {
        static let maxVisibleCardCount = 8
        static let cardCount = 8
    }
    
    var frontCardTag = 1
    var cardCount = PrivateConstants.cardCount
    var maxVisibleCardCount = PrivateConstants.maxVisibleCardCount
    let gradientBackgroundLayer = CAGradientLayer()
    var gestureDirection:panScrollDirection = .Up
    
    
    // MARK: Initializers
    override init(frame: CGRect) {
        cardArray = []
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        cardArray = []
        super.init(coder: aDecoder)
        backgroundColor = UIColor.yellowColor()
        configure()
    }
    
    // MARK: Config
    private func configure() {
        generateCards()
        configureConstants()
        addGestureRecognizer(gestureRecognizer)
        relayoutSubViews()
    }
    
    private func configureConstants() {
        maxVisibleCardCount = self.dataSourceDelegate?.numberOfVisibleCards() ?? PrivateConstants.maxVisibleCardCount
        cardCount = self.dataSourceDelegate?.numberOfCards() ?? PrivateConstants.cardCount
    }
    
    // MARK: Public
    
    public func reloadData() {
        configure()
    }
    
    public func flipUp() {
        if frontCardTag == 1{
            return
        }
        
        guard let previousFrontView = viewWithTag(frontCardTag - 1) else{
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
    
    public func flipDown() {
        if frontCardTag > cardCount{
            return
        }
        
        guard let frontView = viewWithTag(frontCardTag) else{
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

    }
    
//    //MARK: Handle Screen Rotation
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//        coordinator.animateAlongsideTransition({
//            _ in
//            self.gradientBackgroundLayer.frame = self.view.bounds
//            self.relayoutSubViews()
//            }, completion: nil)
//    }

}

// MARK: Card Generation
extension AnimatedCardsView {
    private func generateCards() {
        // Clear previous configuration
        if cardArray.count > 0 {
            _ = cardArray.map({ $0.removeFromSuperview() })
        }
        
        cardArray = (0...cardCount).map { (tagId) in
            let view = generateNewCardViewWithTagId(tagId)
            self.addSubview(view)
            applyConstraintsToView(view)
            return view
        }
    }
    
    private func generateNewCardViewWithTagId(tagId:NSInteger) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = tagId+1
        switch tagId {
        case 0: view.backgroundColor = UIColor.purpleColor()
        case 1: view.backgroundColor = UIColor.redColor()
        case 2: view.backgroundColor = UIColor.blackColor()
        case 3: view.backgroundColor = UIColor.greenColor()
        case 4: view.backgroundColor = UIColor.brownColor()
        case 5: view.backgroundColor = UIColor.darkGrayColor()
        case 6: view.backgroundColor = UIColor.blueColor()
        case 7: view.backgroundColor = UIColor.orangeColor()
        default: view.backgroundColor = UIColor.whiteColor()
        }
        return view
    }
    
    private func applyConstraintsToView(view:UIView) {
        view.addConstraints([
            NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: CGFloat(1.0), constant: Constants.DefaultSize.width),
            NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: Constants.DefaultSize.ratio, constant: 0),
            ])
        view.superview!.addConstraints([
            NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: view.superview, attribute: .CenterX, multiplier: CGFloat(1.0), constant: 0),
            NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: view.superview, attribute: .CenterY, multiplier: CGFloat(1.0), constant: 0),
            ])
    }
}


// MARK: Handle Layout
extension AnimatedCardsView {
    func relayoutSubViewWith(viewTag: Int, relativeIndex:Int, delay: NSTimeInterval, haveBorderWidth: Bool){
        let width = Constants.DefaultSize.width
        if let subView = self.viewWithTag(viewTag){
            
            subView.layer.anchorPoint = CGPointMake(0.5, 1)
            
//            if let nestedImageView = subView.viewWithTag(10) as? UIImageView{
//                nestedImageView.image = cardImageAtIndex(viewTag - 1)
//            }
            
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
            
            let filteredViewConstraints = self.constraints.filter({$0.firstItem as? UIView == subView && $0.secondItem as? UIView == self && $0.firstAttribute == .CenterY})
            if filteredViewConstraints.count > 0{
                let centerYConstraint = filteredViewConstraints[0]
                let subViewHeight = calculateWidthScaleForIndex(relativeIndex) * width * (1/Constants.DefaultSize.ratio)
                let YOffset = calculusYOffsetForIndex(relativeIndex)
                centerYConstraint.constant = subViewHeight/2 - YOffset
            }
            
            if haveBorderWidth{
                subView.layer.borderWidth = borderWidth
            }else{
                subView.layer.borderWidth = 0
            }
            
            
            UIView.animateWithDuration(0.2, delay: delay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                self.layoutIfNeeded()
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
                if let subView = self.viewWithTag(viewTag){
                    
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
            self.layoutIfNeeded()
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

