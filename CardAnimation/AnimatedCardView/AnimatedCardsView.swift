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

    // MARK: Public properties
    public weak var dataSourceDelegate : AnimatedCardsViewDataSource? {
        didSet {
            if dataSourceDelegate != nil {
                configure()
            }
        }
    }
    
    public var animationsSpeed = 0.2
    
    public struct Constants {
        struct DefaultSize {
            static let width : CGFloat = 400.0
            static let ratio : CGFloat = 3.0 / 4.0
        }
    }
    
    // MARK: Private properties
    private var cardArray : [UIView]! = []
    private lazy var gestureRecognizer : UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: "scrollOnView:")
    }()
    
    private struct PrivateConstants {
        static let maxVisibleCardCount = 8
        static let cardCount = 8
    }
    

    private var cardCount = PrivateConstants.cardCount
    private var maxVisibleCardCount = PrivateConstants.maxVisibleCardCount
    private var gestureDirection:panScrollDirection = .Up
    
    private var currentIndex = 0

    private lazy var flipUpTransform3D : CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 1000.0
        transform = CATransform3DRotate(transform, 0, 1, 0, 0)
        return transform
    }()
    
    private lazy var flipDownTransform3D : CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 1000.0
        //此处有个很大的问题，折磨了我几个小时。原来官方的实现有个临界问题，旋转180度不会执行，其他的角度则没有问题
        transform = CATransform3DRotate(transform, CGFloat(-M_PI)*0.99, 1, 0, 0)
        return transform
    }()

    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.yellowColor()
        configure()
    }
    
    // MARK: Config
    private func configure() {
        configureConstants()
        generateCards()
        addGestureRecognizer(gestureRecognizer)
        self.relayoutSubViewsAnimated(false)
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
        guard currentIndex > 0 else {
            return
        }
        
        currentIndex--
        
        let newView = addNewCardViewWithIndex(currentIndex)
        newView.layer.transform = flipDownTransform3D

        let shouldRemoveLast = cardArray.count > maxVisibleCardCount
        
        
        UIView.animateWithDuration(animationsSpeed, animations: {
            newView.layer.transform = self.flipUpTransform3D
            }, completion: { _ in
                self.relayoutSubViewsAnimated(true, removeLast: shouldRemoveLast)
        })
    }
    
    public func flipDown() {
        guard currentIndex < cardCount && cardArray.count > 0 else {
            return
        }
        
        currentIndex++
        
        let frontView = cardArray.removeFirst()
        
        if currentIndex + cardArray.count < cardCount {
            addNewCardViewWithIndex(currentIndex, insertOnRear: true)
        }
        
        UIView.animateWithDuration(animationsSpeed*1.5, animations: {
            frontView.layer.transform = self.flipDownTransform3D
            }, completion: { _ in
                frontView.removeFromSuperview()
                self.relayoutSubViewsAnimated(true)
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
            for view in cardArray {
                view.removeFromSuperview()
            }
        }
        
        cardArray = (0..<maxVisibleCardCount).map { (tagId) in
            let view = generateNewCardViewWithTagId(tagId)
            addSubview(view)
            applyConstraintsToView(view)
            return view
        }
    }
    
    private func addNewCardViewWithIndex(index:Int, insertOnRear rear:Bool = false) -> UIView {
        let newIndex = rear ? subviews.count : 0
        let newView = generateNewCardViewWithTagId(index)
        rear ? insertSubview(newView, atIndex: newIndex) : addSubview(newView)
        rear ? cardArray.append(newView) : cardArray.insert(newView, atIndex: newIndex)
        applyConstraintsToView(newView)
        relayoutSubView(newView, relativeIndex: newIndex, animated: false)
        newView.alpha = rear ? 0.0 : 1.0
        return newView
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

    private func relayoutSubView(subView:UIView, relativeIndex:Int, animated:Bool = true, delay: NSTimeInterval = 0, haveBorderWidth: Bool = true, fadeAndDelete delete: Bool = false) {
        let width = Constants.DefaultSize.width
        subView.layer.anchorPoint = CGPointMake(0.5, 1)
        
        //            if let nestedImageView = subView.viewWithTag(10) as? UIImageView{
        //                nestedImageView.image = cardImageAtIndex(viewTag - 1)
        //            }
        
        subView.layer.zPosition = CGFloat(1000 - relativeIndex)

        
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
        
        subView.layer.borderWidth = haveBorderWidth ? borderWidth : 0
        
        UIView.animateWithDuration(animated ? animationsSpeed : 0, delay: delay, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            if delete {
                subView.alpha = 0
            } else {
                subView.alpha = self.calculateAlphaForIndex(relativeIndex)
            }
            self.layoutIfNeeded()
            }, completion: { _ in
                if delete {
                    subView.removeFromSuperview()
                }
        })
    }
    
    private func relayoutSubViewsAnimated(animated:Bool, removeLast remove:Bool = false){
        for (index, view) in cardArray.enumerate() {
            let shouldDelete = remove && index == cardArray.count-1
            let delay = animated ? 0.1 * Double(index) : 0
            relayoutSubView(view, relativeIndex: index, delay: delay, fadeAndDelete: shouldDelete)
        }
        if remove {
            cardArray.removeLast()
        }
    }
    
    //MARK: Helper Methods
    //f(x) = k * x + m
    private func calculateFactorOfFunction(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) -> (CGFloat, CGFloat){
        
        let k = (y1-y2)/(x1-x2)
        let m = (x1*y2 - x2*y1)/(x1-x2)
        
        return (k, m)
    }
    
    private func calculateResult(argument x: Int, k: CGFloat, m: CGFloat) -> CGFloat{
        return k * CGFloat(x) + m
    }
    
    private func calcuteResultWith(x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat, argument: Int) -> CGFloat{
        let (k, m) = calculateFactorOfFunction(x1, x2: x2, y1: y1, y2: y2)
        return calculateResult(argument: argument, k: k, m: m)
    }
    
    //I set the gap between 0Card and 1st Card is 35, gap between the last two card is 15. These value on iPhone is a little big, you could make it less.
    //设定头两个卡片的距离为35，最后两张卡片之间的举例为15。不设定成等距才符合视觉效果。
    private func calculusYOffsetForIndex(indexInQueue: Int) -> CGFloat{
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
    
    private func calculateWidthScaleForIndex(indexInQueue: Int) -> CGFloat{
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
    private func calculateScaleFactorForIndex(indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(1)
        }
        
        var scale = calcuteResultWith(1, x2: 8, y1: 0.95, y2: 0.5, argument: indexInQueue)
        if scale < 0.1{
            scale = 0.1
        }
        
        return scale
    }
    
    private func calculateAlphaForIndex(indexInQueue: Int) -> CGFloat{
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
    
    private func calculateBorderWidthForIndex(indexInQueue: Int, initialBorderWidth: CGFloat) -> CGFloat{
        let scaleFactor = calculateScaleFactorForIndex(indexInQueue)
        return scaleFactor * initialBorderWidth
    }
    
}

