//
//  AnimatedCardsView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 14/10/15.
//  Copyright © 2016 seedante
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

enum PanScrollDirection{
    case up, down
}

protocol CardView {
    func contentVisible(_ visible:Bool)
    func prepareForReuse()
}

public protocol CardAnimationViewDataSource : class {
    func numberOfVisibleCards() -> Int
    func numberOfCards() -> Int
    /**
     Ask the delegate for a new card to display in the container.
     - parameter number: number that is needed to be displayed.
     - parameter reusedView: the component may provide you with an unused view.
     - returns: correctly configured card view.
     */
    func cardNumber(_ number:Int, reusedView:BaseCardView?) -> BaseCardView
}

open class BaseCardView: UIView, CardView {
    func contentVisible(_ visible:Bool) { }
    func prepareForReuse() { }
}


open class ImageCardView: BaseCardView {
    var imageView:UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    fileprivate func configure() {
        backgroundColor = UIColor.darkGray
        imageView = UIImageView(frame: frame)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.backgroundColor = UIColor.lightGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }
    
    //hidden property can't be animationable, I recommand using alpha.
    override func contentVisible(_ visible:Bool) {
        imageView.alpha = visible ? 1.0 : 0.0
    }
    
    override func prepareForReuse() {
        imageView.isHidden = false
    }
}


/// View to display a list of cards featuring a flipping up and down animation effect.
open class CardAnimationView: UIView {

    // MARK: Public properties
    /// Data source delegate, class won't work until it's set.
    open weak var dataSourceDelegate : CardAnimationViewDataSource? {
        didSet { // Only start to work if delegate is set
            if dataSourceDelegate != nil {
                configure()
            }
        }
    }
    
    /// Animation speed for the cards animations.
    open var animationsSpeed = 0.2
    
    /// Defines the card size that will be used. (width, height)
    open var cardSize : (width:CGFloat, height:CGFloat) {
        didSet { // Only reset when delegate is set
            if dataSourceDelegate != nil {
                configure()
            }
        }
    }
    
    // MARK: Private properties
    fileprivate struct Constants {
        struct CardDefaultSize {
            static let width : CGFloat = 400.0
            static let height : CGFloat = 300.0
        }
    }
    
    fileprivate var cardArray : [BaseCardView]! = []
    fileprivate var poolCardArray : [BaseCardView]! = []
    fileprivate lazy var gestureRecognizer : UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(CardAnimationView.scrollOnView(_:)))
    }()
    
    fileprivate struct PrivateConstants {
        static let maxVisibleCardCount = 8
        static let cardCount = 8
    }
    

    fileprivate var cardCount = PrivateConstants.cardCount
    fileprivate var maxVisibleCardCount = PrivateConstants.maxVisibleCardCount
    fileprivate var gestureDirection:PanScrollDirection = .up
    fileprivate var gestureTempCard: BaseCardView?
    
    fileprivate var currentIndex = 0

    fileprivate lazy var flipUpTransform3D : CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 1000.0
        transform = CATransform3DRotate(transform, 0, 1, 0, 0)
        return transform
    }()
    
    fileprivate lazy var flipDownTransform3D : CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 1000.0
        transform = CATransform3DRotate(transform, CGFloat(-Double.pi), 1, 0, 0)
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
    fileprivate func configure() {
        configureConstants()
        generateCards()
        addGestureRecognizer(gestureRecognizer)
        self.relayoutSubViewsAnimated(false)
    }
    
    fileprivate func configureConstants() {
        maxVisibleCardCount = self.dataSourceDelegate?.numberOfVisibleCards() ?? PrivateConstants.maxVisibleCardCount
        cardCount = self.dataSourceDelegate?.numberOfCards() ?? PrivateConstants.cardCount
    }
    
    // MARK: Public
    
    /// Reloads the cards of the animated cards view.
    open func reloadData() {
        configure()
    }

    /**
    Flips up one card with animation
    
    - returns: if the action was performed or not (out of bounds)
    */
    open func flipUp() -> Bool {
        guard currentIndex > 0 else {
            return false
        }

        currentIndex -= 1

        let newView = addNewCardViewWithIndex(currentIndex)
        newView.layer.transform = flipDownTransform3D

        let shouldRemoveLast = cardArray.count > maxVisibleCardCount

        UIView.animateKeyframes(withDuration: animationsSpeed, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                newView.layer.transform = self.flipUpTransform3D
            })

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.01, animations: {
                newView.contentVisible(true)
            })

            }, completion: { _ in
                self.relayoutSubViewsAnimated(true, removeLast: shouldRemoveLast)
        })
        return true
    }
    
    /**
    Flips down one card with animation
    
    - returns: if the action was performed or not (out of bounds)
    */
    open func flipDown() -> Bool {
        guard currentIndex < cardCount else {
            return false
        }

        currentIndex += 1

        let frontView = cardArray.removeFirst()
        let lastIndex = currentIndex + cardArray.count
        if lastIndex < cardCount {
            let _ = addNewCardViewWithIndex(lastIndex, insertOnRear: true)
        }

        UIView.animateKeyframes(withDuration: animationsSpeed*1.5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                frontView.layer.transform = self.flipDownTransform3D
            })

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.01, animations: {
                frontView.contentVisible(false)
            })

            }, completion: { _ in
                self.poolCardArray.append(frontView)
                frontView.removeFromSuperview()
                self.relayoutSubViewsAnimated(true)
        })
        
        return true
    }
}

// MARK: Pan gesture
extension CardAnimationView {
    @objc fileprivate func scrollOnView(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self)
        let percent = gesture.translation(in: self).y/150
        var flipTransform3D = CATransform3DIdentity
        flipTransform3D.m34 = -1.0 / 1000.0
        
        switch gesture.state{
        case .began:
            
            gestureDirection = velocity.y > 0 ? .down : .up
            
        case .changed:
            if gestureDirection == .down{ // Flip down
                guard currentIndex < cardCount else {
                    gesture.isEnabled = false // Cancel gesture
                    return
                }
                
                let frontView = cardArray[0]
                switch percent{
                case 0.0..<1.0:
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi) * percent, 1, 0, 0)
                    frontView.layer.transform = flipTransform3D
                    if percent >= 0.5{
                        frontView.contentVisible(false)
                    }else{
                        frontView.contentVisible(true)
                    }
                case 1.0...CGFloat(MAXFLOAT):
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi), 1, 0, 0)
                    frontView.layer.transform = flipTransform3D
                default:
                    print(percent)
                }
                
            } else { // Flip up
                guard currentIndex > 0 else {
                    gesture.isEnabled = false // Cancel gesture
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
                    }else{
                        gestureTempCard!.contentVisible(false)
                    }
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi) * (percent+1.0), 1, 0, 0)
                    gestureTempCard!.layer.transform = flipTransform3D
                default:
                    print(percent)
                }
            }
            
        case .ended:
            
            switch gestureDirection{
            case .down:
                if percent >= 0.5{
                    currentIndex += 1
                    
                    let frontView = cardArray.removeFirst()
                    let lastIndex = currentIndex + cardArray.count
                    if lastIndex < cardCount {
                        let _ = addNewCardViewWithIndex(lastIndex, insertOnRear: true)
                    }
                    
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(Double.pi), 1, 0, 0)
                    UIView.animate(withDuration: 0.3, animations: {
                        frontView.layer.transform = flipTransform3D
                        }, completion: {
                            _ in
                            self.poolCardArray.append(frontView)
                            frontView.removeFromSuperview()
                            self.relayoutSubViewsAnimated(true)
                            
                    })
                }else{
                    let frontView = cardArray[0]
                    UIView.animate(withDuration: 0.2, animations: {
                        frontView.layer.transform = CATransform3DIdentity
                    })
                    
                }
                
            case .up:
                guard currentIndex > 0 else {
                    return
                }
                
                if percent <= -0.5{
                    currentIndex -= 1
                    let shouldRemoveLast = cardArray.count > maxVisibleCardCount
                    UIView.animate(withDuration: 0.2, animations: {
                        self.gestureTempCard!.layer.transform = CATransform3DIdentity
                        }, completion: {
                            _ in
                            self.relayoutSubViewsAnimated(true, removeLast: shouldRemoveLast)
                            self.gestureTempCard = nil
                    })
                }else{
                    UIView.animate(withDuration: 0.2, animations: {
                        self.gestureTempCard!.layer.transform = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi), 1, 0, 0)
                        }, completion: {
                            _ in
                            self.poolCardArray.append(self.gestureTempCard!)
                            self.cardArray.removeFirst()
                            self.gestureTempCard!.removeFromSuperview()
                            self.gestureTempCard = nil
                    })
                }
            }
        case .cancelled: // When cancel reenable gesture
            gesture.isEnabled = true
        default:
            print("DEFAULT: DO NOTHING")
        }
    }
}

// MARK: Card Generation
extension CardAnimationView {
    fileprivate func generateCards() {
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
    
    fileprivate func addNewCardViewWithIndex(_ index:Int, insertOnRear rear:Bool = false) -> BaseCardView {
        let newIndex = rear ? subviews.count : 0
        var newView : BaseCardView?
        // Reuse cards
        if poolCardArray.count > 0 {
            let reusedView = poolCardArray.removeFirst()
            newView = generateNewCardViewWithIndex(index, reusingCardView: reusedView)
        } else {
            newView = generateNewCardViewWithIndex(index)
        }
        rear ? insertSubview(newView!, at: newIndex) : addSubview(newView!)
        rear ? cardArray.append(newView!) : cardArray.insert(newView!, at: newIndex)
        applyConstraintsToView(newView!)
        relayoutSubView(newView!, relativeIndex: newIndex, animated: false)
        newView!.alpha = rear ? 0.0 : 1.0
        return newView!
    }
    
    fileprivate func generateNewCardViewWithIndex(_ index:Int, reusingCardView cardView:BaseCardView? = nil) -> BaseCardView {
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
    
    fileprivate func applyConstraintsToView(_ view:UIView) {
        view.addConstraints([
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: CGFloat(1.0), constant:  cardSize.width),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: CGFloat(1.0), constant: cardSize.height),
            ])
        view.superview!.addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: view.superview, attribute: .centerX, multiplier: CGFloat(1.0), constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: view.superview, attribute: .centerY, multiplier: CGFloat(1.0), constant: 0),
            ])
    }
}


// MARK: Handle Layout
extension CardAnimationView {

    fileprivate func relayoutSubView(_ subView:BaseCardView, relativeIndex:Int, animated:Bool = true, delay: TimeInterval = 0, fadeAndDelete delete: Bool = false) {
        let width = cardSize.width
        let height = cardSize.height
        subView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        subView.layer.zPosition = CGFloat(1000 - relativeIndex)

        let sizeScale = calculateWidthScaleForIndex(relativeIndex)
        
        let filterWidthSubViewConstraints = subView.constraints.filter({$0.firstAttribute == .width && $0.secondItem == nil})
        if filterWidthSubViewConstraints.count > 0{
            let widthConstraint = filterWidthSubViewConstraints[0]
            widthConstraint.constant = sizeScale * width
        }
        let filterHeightSubViewConstraints = subView.constraints.filter({$0.firstAttribute == .height && $0.secondItem == nil})
        if filterHeightSubViewConstraints.count > 0{
            let heightConstraint = filterHeightSubViewConstraints[0]
            heightConstraint.constant = sizeScale * height
        }
        
        let filteredViewConstraints = self.constraints.filter({$0.firstItem as? UIView == subView && $0.secondItem as? UIView == self && $0.firstAttribute == .centerY})
        if filteredViewConstraints.count > 0{
            let centerYConstraint = filteredViewConstraints[0]
            let subViewHeight = calculateWidthScaleForIndex(relativeIndex) * height
            let YOffset = calculusYOffsetForIndex(relativeIndex)
            centerYConstraint.constant = subViewHeight/2 - YOffset
        }
        
        UIView.animate(withDuration: animated ? animationsSpeed : 0, delay: delay, options: .beginFromCurrentState, animations: {
            subView.alpha = delete ? 0 : self.calculateAlphaForIndex(relativeIndex)
            self.layoutIfNeeded()
            }, completion: { _ in
                if delete {
                    self.poolCardArray.append(subView)
                    subView.removeFromSuperview()
                }
        })
    }
    
    fileprivate func relayoutSubViewsAnimated(_ animated:Bool, removeLast remove:Bool = false){
        for (index, view) in cardArray.enumerated() {
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
    fileprivate func calculateFactorOfFunction(_ x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat) -> (CGFloat, CGFloat){
        
        let k = (y1-y2)/(x1-x2)
        let m = (x1*y2 - x2*y1)/(x1-x2)
        
        return (k, m)
    }
    
    fileprivate func calculateResult(argument x: Int, k: CGFloat, m: CGFloat) -> CGFloat{
        return k * CGFloat(x) + m
    }
    
    fileprivate func calcuteResultWith(_ x1: CGFloat, x2: CGFloat, y1: CGFloat, y2: CGFloat, argument: Int) -> CGFloat{
        let (k, m) = calculateFactorOfFunction(x1, x2: x2, y1: y1, y2: y2)
        return calculateResult(argument: argument, k: k, m: m)
    }
    
    //I set the gap between 0Card and 1st Card is 35, gap between the last two card is 15. These value on iPhone is a little big, you could make it less.
    //设定头两个卡片的距离为35，最后两张卡片之间的举例为15。不设定成等距才符合视觉效果。
    fileprivate func calculusYOffsetForIndex(_ indexInQueue: Int) -> CGFloat{
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
    
    fileprivate func calculateWidthScaleForIndex(_ indexInQueue: Int) -> CGFloat{
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
    fileprivate func calculateScaleFactorForIndex(_ indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(1)
        }
        
        var scale = calcuteResultWith(1, x2: 8, y1: 0.95, y2: 0.5, argument: indexInQueue)
        if scale < 0.1{
            scale = 0.1
        }
        
        return scale
    }
    
    fileprivate func calculateAlphaForIndex(_ indexInQueue: Int) -> CGFloat{
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
}

