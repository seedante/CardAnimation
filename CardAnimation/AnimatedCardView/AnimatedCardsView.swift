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
    /**
    Ask the delegate for a new card to display in the container.
    - parameter number: number that is needed to be displayed.
    - parameter reusedView: the component may provide you with an unused view.
    - returns: correctly configured card view.
    */
    func cardNumber(number:Int, reusedView:BaseCardView?) -> BaseCardView
}

/// View to display a list of cards featuring a flipping up and down animation effect.
public class AnimatedCardsView: UIView {

    // MARK: Public properties
    /// Data source delegate, class won't work until it's set.
    public weak var dataSourceDelegate : AnimatedCardsViewDataSource? {
        didSet { // Only start to work if delegate is set
            if dataSourceDelegate != nil {
                configure()
            }
        }
    }
    
    /// Animation speed for the cards animations.
    public var animationsSpeed = 0.2
    
    /// Defines the card size that will be used. (width, height)
    public var cardSize : (width:CGFloat, height:CGFloat) {
        didSet { // Only reset when delegate is set
            if dataSourceDelegate != nil {
                configure()
            }
        }
    }
    
    // MARK: Private properties
    private struct Constants {
        struct CardDefaultSize {
            static let width : CGFloat = 400.0
            static let height : CGFloat = 300.0
        }
    }
    
    private var cardArray : [BaseCardView]! = []
    private var poolCardArray : [BaseCardView]! = []
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
    private var gestureTempCard: BaseCardView?
    
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
    /**
        Initializes a view object with the specified frame rectangle.
        - parameter frame: adssad
    */
    override init(frame: CGRect) {
        cardSize = (Constants.CardDefaultSize.width, Constants.CardDefaultSize.height)
        super.init(frame: frame)
    }
    
    /**
        Initializes a view object from data in a given unarchiver.
        - parameter coder: An unarchiver object.
    */
    required public init?(coder aDecoder: NSCoder) {
        cardSize = (Constants.CardDefaultSize.width, Constants.CardDefaultSize.height)
        super.init(coder: aDecoder)
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
    
    /// Reloads the cards of the animated cards view.
    public func reloadData() {
        configure()
    }

    /**
    Flips up one card with animation
    
    - returns: if the action was performed or not (out of bounds)
    */
    public func flipUp() -> Bool {
        guard currentIndex > 0 else {
            return false
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
        
        return true
    }
    
    /**
    Flips down one card with animation
    
    - returns: if the action was performed or not (out of bounds)
    */
    public func flipDown() -> Bool {
        guard currentIndex < cardCount else {
            return false
        }
        
        currentIndex++
        
        let frontView = cardArray.removeFirst()
        let lastIndex = currentIndex + cardArray.count
        if lastIndex < cardCount {
            addNewCardViewWithIndex(lastIndex, insertOnRear: true)
        }
        
        UIView.animateWithDuration(animationsSpeed*1.5, animations: {
            frontView.layer.transform = self.flipDownTransform3D
            }, completion: { _ in
                self.poolCardArray.append(frontView)
                frontView.removeFromSuperview()
                self.relayoutSubViewsAnimated(true)
        })
        
        return true
    }
}

// MARK: Pan gesture
extension AnimatedCardsView {
    @objc private func scrollOnView(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocityInView(self)
        let percent = gesture.translationInView(self).y/150
        var flipTransform3D = CATransform3DIdentity
        flipTransform3D.m34 = -1.0 / 1000.0
        
        switch gesture.state{
        case .Began:
            
            gestureDirection = velocity.y > 0 ? .Down : .Up
            
        case .Changed:
            let frontView : BaseCardView? = cardArray.count > 0 ? cardArray[0] : nil
            
            if gestureDirection == .Down{ // Flip down
                guard currentIndex < cardCount else {
                    gesture.enabled = false // Cancel gesture
                    return
                }
                
                switch percent{
                case 0.0..<1.0:
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI) * percent, 1, 0, 0)
                    frontView?.layer.transform = flipTransform3D
                    if percent >= 0.5{
                        frontView?.contentVisible(false)
                    }else{
                        frontView?.contentVisible(true)
                    }
                case 1.0...CGFloat(MAXFLOAT):
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI), 1, 0, 0)
                    frontView?.layer.transform = flipTransform3D
                default:
                    print(percent)
                }
                
            } else { // Flip up
                guard currentIndex > 0 else {
                    gesture.enabled = false // Cancel gesture
                    return
                }
                
                if gestureTempCard == nil {
                    let newView = addNewCardViewWithIndex(currentIndex-1)
                    newView.layer.transform = flipDownTransform3D
                    gestureTempCard = newView
                }
                
                switch percent{
                case CGFloat(-MAXFLOAT)...(-1.0):
                    gestureTempCard!.layer.transform = CATransform3DIdentity
                case -1.0...0:
                    if percent <= -0.5{
                        gestureTempCard!.contentVisible(true)
                        gestureTempCard!.layer.borderWidth = gestureTempCard!.frame.width / 100
                    }else{
                        gestureTempCard!.contentVisible(false)
                        gestureTempCard!.layer.borderWidth = 0
                    }
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI) * (percent+1.0), 1, 0, 0)
                    gestureTempCard!.layer.transform = flipTransform3D
                default:
                    print(percent)
                }
            }
            
        case .Ended:
            
            switch gestureDirection{
            case .Down:
                if percent >= 0.5{
                    currentIndex++
                    
                    let frontView = cardArray.removeFirst()
                    let lastIndex = currentIndex + cardArray.count
                    if lastIndex < cardCount {
                        addNewCardViewWithIndex(lastIndex, insertOnRear: true)
                    }
                    
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(M_PI), 1, 0, 0)
                    UIView.animateWithDuration(0.3, animations: {
                        frontView.layer.transform = flipTransform3D
                        }, completion: {
                            _ in
                            self.poolCardArray.append(frontView)
                            frontView.removeFromSuperview()
                            self.relayoutSubViewsAnimated(true)
                            
                    })
                }else{
                    let frontView : BaseCardView? = cardArray.count > 0 ? cardArray[0] : nil
                    UIView.animateWithDuration(0.2, animations: {
                        frontView?.layer.transform = CATransform3DIdentity
                    })
                    
                }
                
            case .Up:
                guard currentIndex > 0 else {
                    return
                }
                
                if percent <= -0.5{
                    currentIndex--
                    let shouldRemoveLast = cardArray.count > maxVisibleCardCount
                    UIView.animateWithDuration(0.2, animations: {
                        self.gestureTempCard!.layer.transform = CATransform3DIdentity
                        }, completion: {
                            _ in
                            self.relayoutSubViewsAnimated(true, removeLast: shouldRemoveLast)
                            self.gestureTempCard = nil
                    })
                }else{
                    UIView.animateWithDuration(0.2, animations: {
                        self.gestureTempCard!.layer.transform = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI), 1, 0, 0)
                        }, completion: {
                            _ in
                            self.poolCardArray.append(self.gestureTempCard!)
                            self.cardArray.removeFirst()
                            self.gestureTempCard!.removeFromSuperview()
                            self.gestureTempCard = nil
                    })
                }
            }
        case .Cancelled: // When cancel reenable gesture
            gesture.enabled = true
        default:
            print("DEFAULT: DO NOTHING")
        }
    }
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
        
        cardArray = (0..<maxVisibleCardCount).map { (index) in
            let view = generateNewCardViewWithIndex(index)
            addSubview(view)
            applyConstraintsToView(view)
            return view
        }
        poolCardArray = []
    }
    
    private func addNewCardViewWithIndex(index:Int, insertOnRear rear:Bool = false) -> BaseCardView {
        let newIndex = rear ? subviews.count : 0
        var newView : BaseCardView?
        // Reuse cards
        if poolCardArray.count > 0 {
            let reusedView = poolCardArray.removeFirst()
            newView = generateNewCardViewWithIndex(index, reusingCardView: reusedView)
        } else {
            newView = generateNewCardViewWithIndex(index)
        }
        rear ? insertSubview(newView!, atIndex: newIndex) : addSubview(newView!)
        rear ? cardArray.append(newView!) : cardArray.insert(newView!, atIndex: newIndex)
        applyConstraintsToView(newView!)
        relayoutSubView(newView!, relativeIndex: newIndex, animated: false)
        newView!.alpha = rear ? 0.0 : 1.0
        return newView!
    }
    
    private func generateNewCardViewWithIndex(index:Int, reusingCardView cardView:BaseCardView? = nil) -> BaseCardView {
        // Reset card
        if cardView != nil {
            cardView!.layer.transform = flipUpTransform3D
            cardView!.removeConstraints(cardView!.constraints)
            cardView!.prepareForReuse()
        }
        let view = self.dataSourceDelegate!.cardNumber(index, reusedView: cardView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func applyConstraintsToView(view:UIView) {
        view.addConstraints([
            NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: CGFloat(1.0), constant:  cardSize.width),
            NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: CGFloat(1.0), constant: cardSize.height),
            ])
        view.superview!.addConstraints([
            NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: view.superview, attribute: .CenterX, multiplier: CGFloat(1.0), constant: 0),
            NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: view.superview, attribute: .CenterY, multiplier: CGFloat(1.0), constant: 0),
            ])
    }
}


// MARK: Handle Layout
extension AnimatedCardsView {

    private func relayoutSubView(subView:BaseCardView, relativeIndex:Int, animated:Bool = true, delay: NSTimeInterval = 0, haveBorderWidth: Bool = true, fadeAndDelete delete: Bool = false) {
        let width = cardSize.width
        let height = cardSize.height
        subView.layer.anchorPoint = CGPointMake(0.5, 1)
        subView.layer.zPosition = CGFloat(1000 - relativeIndex)

        let sizeScale = calculateWidthScaleForIndex(relativeIndex)
        let borderWidth: CGFloat = width * sizeScale / 100
        
        let filterWidthSubViewConstraints = subView.constraints.filter({$0.firstAttribute == .Width && $0.secondItem == nil})
        if filterWidthSubViewConstraints.count > 0{
            let widthConstraint = filterWidthSubViewConstraints[0]
            widthConstraint.constant = sizeScale * width
        }
        let filterHeightSubViewConstraints = subView.constraints.filter({$0.firstAttribute == .Height && $0.secondItem == nil})
        if filterHeightSubViewConstraints.count > 0{
            let heightConstraint = filterHeightSubViewConstraints[0]
            heightConstraint.constant = sizeScale * height
        }
        
        let filteredViewConstraints = self.constraints.filter({$0.firstItem as? UIView == subView && $0.secondItem as? UIView == self && $0.firstAttribute == .CenterY})
        if filteredViewConstraints.count > 0{
            let centerYConstraint = filteredViewConstraints[0]
            let subViewHeight = calculateWidthScaleForIndex(relativeIndex) * height
            let YOffset = calculusYOffsetForIndex(relativeIndex)
            centerYConstraint.constant = subViewHeight/2 - YOffset
        }
        
        subView.layer.borderWidth = haveBorderWidth ? borderWidth : 0
        
        UIView.animateWithDuration(animated ? animationsSpeed : 0, delay: delay, options: .BeginFromCurrentState, animations: {
            subView.alpha = delete ? 0 : self.calculateAlphaForIndex(relativeIndex)
            self.layoutIfNeeded()
            }, completion: { _ in
                if delete {
                    self.poolCardArray.append(subView)
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

