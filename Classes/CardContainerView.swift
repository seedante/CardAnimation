//
//  CardContainerView.swift
//  CardAnimation
//
//  Created by seedante on 16/1/19.
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

/// The object adopt this protocol will provide a CardContainerView with card number and relative image.
public protocol CardContainerDataSource: class{
    /// Return the number of cards in CardContainerView
    ///
    /// - parameter cardContainerView: A CardContainerView object which ask for card number.
    ///
    /// - returns: Card number. Usually, if returned value is negative, it means no card.
    func numberOfCards(for cardContainerView: CardContainerView) -> Int
    /// Return relative image at the specified location.
    ///
    /// - parameter cardContainerView: A CardContainerView object which ask for image to display.
    /// - parameter index: Card index in data source.
    ///
    /// - returns: Image at the specified location.
    func cardContainerView(_ cardContainerView: CardContainerView, imageForCardAt index: Int) -> UIImage?
}


private class _CardView: UIView {
    private let backView = UIView()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.alpha = 0
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
        insertSubview(backView, belowSubview: imageView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: backView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: backView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: backView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: backView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
    }
    
    convenience init(frame: CGRect, backColor: UIColor) {
        self.init(frame: frame)
        backView.backgroundColor = backColor
    }
    
    convenience init(){
        self.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
    }
    
    func restoreTransform3D(){
        layer.transform = CATransform3DIdentity
    }
    
    func setImage(_ image: UIImage?){
        imageView.image = image
    }
    
    func hiddenCard(){
        imageView.alpha = 0
    }
    
    func hiddenBack(){
        backView.alpha = 0
    }
    
    func restoreBack(){
        backView.alpha = 1
    }
    
    func restoreCard(){
        imageView.alpha = 1
    }
    
    func setBrightness(_ value: CGFloat){
        imageView.alpha = value
    }
    
    func setBorderColor(_ color: UIColor){
        imageView.layer.borderColor = color.cgColor
    }
    
    func setBorderWidth(_ value: CGFloat){
        imageView.layer.borderWidth = value
    }
}

/// A view to display images like cards, support pan gesture to slide up and down.
/// Its prototype: https://cdn.dribbble.com/users/32399/screenshots/1265487/like-dribbble-video_2x.gif
open class CardContainerView: UIView {
    // MARK: Properties to Configure
    /// A Boolean value deciding whether control brightness on different cards. The default value is true.
    public var enableBrightnessControl: Bool = true
    /// The max number of visible cards in the view. The default value is 10.
    public var maxVisibleCardCount: Int = 10
    /// A Boolean value deciding whether provide a border on every card view. The default value is true.
    public var needsBorder: Bool = true
    /// The size of the first card you see. If you change this value, call `layoutCardsIfNeeded()` to resize cards.
    /// The default value is (400, 300).
    public var cardSize = CGSize(width: 400, height: 300)
    /// Color of card's back. If it's nil, card back is black. The default value is nil.
    public var cardBackColor: UIColor?
    /// The border width of the first card you see. The default value is 5.
    public var cardBorderWidth: CGFloat = 5
    /// Specify max distance(points) between cards in vertical direction. The default value is 35.
    public var maxYOffsetBetweenCards: CGFloat = 35
    /// Specify min distance(points) between cards in vertical direction. The default value is 15.
    public var minYOffsetBetweenCards: CGFloat = 15
    /// The data source must adopt the CardContainerDataSource protocol. The data source is not retained.
    public weak var dataSource: CardContainerDataSource?{
        didSet{
            if dataSource != nil{
                configure()
            }
        }
    }
    
    // MARK: Query Card location
    /// Head card's location in data source. If data source is nil or empty, returns nil.
    /// Specially, if cards slide to end, it returns card count.
    public var headCardIndexAtDataSource: Int?{
        guard let cardCount = dataSource?.numberOfCards(for: self) else {
            return nil
        }
        
        if cardCount <= 0{
            return nil
        }
        
        return currentHeadCardIndex
    }
    
    var flipAnimationTime: TimeInterval = 0.4
    
    // MARK: Init
    /// Init a CardContainerView with specified frame and default card size.
    ///
    /// - parameter frame: The frame rectangle for the view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        panGesture.addTarget(self, action: #selector(CardContainerView.panGestureAction(_:)))
        addGestureRecognizer(panGesture)
    }
    
    /// Init a CardContainerView with specified frame and card size.
    ///
    /// - parameter frame: The frame rectangle for the view.
    /// - parameter cardSize: The card size. The default value is (400, 300)
    public init(frame: CGRect, cardSize: CGSize = CGSize(width: 400, height: 300)) {
        self.cardSize = cardSize
        super.init(frame: frame)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        panGesture.addTarget(self, action: #selector(CardContainerView.panGestureAction(_:)))
        addGestureRecognizer(panGesture)
    }
    
    /// Init from storyboard/xib file. Card size is default value: (400, 300).
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        panGesture.addTarget(self, action: #selector(CardContainerView.panGestureAction(_:)))
        addGestureRecognizer(panGesture)
    }
    
    deinit{
        self.removeGestureRecognizer(panGesture)
    }
    
    // MARK: Slide
    private var fliping: Bool = false
    private lazy var flipDownTransform3D: CATransform3D = {
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -1.0 / 2000.0
        transform3D = CATransform3DRotate(transform3D, CGFloat(-Double.pi), 1, 0, 0)
        return transform3D
    }()
    
    /// Slide down the head card. This method is safe.
    public func slideDown(){
        guard let headCard = visibleCardQueue.first else{return}
        guard !fliping else {return}
        
        fliping = true
        headCard.restoreBack()
        UIView.animateKeyframes(withDuration: flipAnimationTime, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                // Turn 180 degrees
                headCard.layer.transform = self.flipDownTransform3D
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.01, animations: {
                headCard.hiddenCard()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                headCard.alpha = 0
            })
        }, completion: {_ in
            self.finishLastworkAfterSlideDown(headCard)
        })
    }
    
    private func finishLastworkAfterSlideDown(_ headCard: _CardView){
        headCard.layer.zPosition = CGFloat(101)
        currentHeadCardIndex += 1
        visibleCardQueue.removeFirst()
        backupCardQueue.append(headCard)
        
        if needsFillVisibleQueue == true{
            fillVisibleQueue()
        }
        layoutVisibleCardViews()
    }
    
    /// Slide up a card to be the head card. The method is safe.
    public func slideUp(){
        guard let image = self.dataSource!.cardContainerView(self, imageForCardAt: self.currentHeadCardIndex - 1)else{
            return
        }
        guard !fliping else {return}
        
        previousHeadCard = candidateCardView
        previousHeadCard?.setImage(image)
        if isNewCard{
            previousHeadCard?.layer.transform = flipDownTransform3D
            previousHeadCard?.hiddenCard()
            previousHeadCard?.alpha = 0
        }
        fliping = true
        UIView.animateKeyframes(withDuration: flipAnimationTime, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.previousHeadCard?.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.previousHeadCard?.restoreTransform3D()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.01, animations: {
                self.previousHeadCard?.restoreCard()
            })
        }, completion: {_ in
            self.previousHeadCard?.hiddenBack()
            //There were some problems if the follow code in completion block ever
            self.currentHeadCardIndex -= 1
            self.visibleCardQueue.insert(self.previousHeadCard!, at: 0)
            self.layoutVisibleCardViews()
        })
    }
    // MARK: Update Cards
    private func reloadCards(){
        for (index, cardView) in visibleCardQueue.enumerated(){
            let image = self.dataSource?.cardContainerView(self, imageForCardAt: index + currentHeadCardIndex)
            cardView.setImage(image)
        }
    }
        
    /// Insert a cark at specified location. You must update data source before calling this method.
    /// And you must call this method after updating data source.
    ///
    /// If location is not visible, no animation.
    ///
    /// - parameter index: Card index in the data source.
    public func insertCard(at index: Int){
        if index < 0 || index > dataSource!.numberOfCards(for: self) - 1{
            fatalError("Index \(index) is out of range.")
        }
        
        if index < currentHeadCardIndex{
            currentHeadCardIndex += 1
            return
        }
        
        let visibleIndex = index - currentHeadCardIndex
        if visibleCardQueue.count > 0{
            guard visibleCardQueue.count > visibleIndex else {return}
        }else{
            guard visibleIndex == 0 else{return}
        }
        
        let newCard = candidateCardView
        if isNewCard{
            newCard.alpha = 0
        }else{
            newCard.restoreTransform3D()
        }
        
        adjustConfigurationOfCardView(newCard, withTargetIndex: visibleIndex, yOffset: -cardSize.height/2)
        visibleCardQueue.insert(newCard, at: visibleIndex)
        reloadCards()
        
        UIView.animate(withDuration: 0.25, animations: {
            newCard.restoreCard()
            newCard.alpha = 1
        }, completion: {_ in
            self.layoutVisibleCardViews(from: visibleIndex)
        })
    }
    
    /// Remove card at specified location. You muust update data source before calling this method.
    /// And you must call this method after updating data source.
    ///
    /// If location is not visible, no animation.
    ///
    /// - parameter index: Card index in the data source.
    public func removeCard(at index: Int){
        if index < 0 || index > dataSource!.numberOfCards(for: self){
            fatalError("Index \(index) is out of range")
        }
        
        if index < currentHeadCardIndex{
            currentHeadCardIndex -= 1
            return
        }
        
        let visibleIndex = index - currentHeadCardIndex
        guard visibleCardQueue.count > visibleIndex else {
            return
        }
        
        let targetCard = visibleCardQueue[visibleIndex]
        let offset = -cardSize.height
        visibleCardQueue.remove(at: visibleIndex)
        backupCardQueue.append(targetCard)
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .beginFromCurrentState, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.adjustConfigurationOfCardView(targetCard, withTargetIndex: visibleIndex, yOffset: offset)
                self.layoutIfNeeded()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3, animations: {targetCard.alpha = 0})
        }, completion: { _ in
            self.resetToReuse(targetCard)
            if self.needsFillVisibleQueue == true{
                self.fillVisibleQueue()
                self.reloadCards()
            }
            self.layoutVisibleCardViews()
        })
    }
    
    /// Lay out all cards immediately. If you change `cardSize`, call this method to resize cards.
    public func layoutCardsIfNeeded(){
        layoutInvisibleCardViews()
        layoutVisibleCardViews()
    }
    
    //MARK: Reuseable Card Queue
    //An Array sorted from fisrt card to last card.
    private var visibleCardQueue: [_CardView] = []
    private var backupCardQueue: [_CardView] = []
    private var currentHeadCardIndex: Int = 0
    
    //MARK: Configure Method
    private func configure(){
        guard let cardCount = dataSource?.numberOfCards(for: self), cardCount > 0 else{return}
        let vacancyCount = cardCount >= maxVisibleCardCount ? maxVisibleCardCount : cardCount
        for _ in 0..<vacancyCount{
            let newCard = candidateCardView
            newCard.alpha = 1
            visibleCardQueue.append(newCard)
        }
        reloadCards()
        layoutVisibleCardViews()
    }
    
    private var isNewCard: Bool = true
    private var candidateCardView: _CardView{
        if let cardView = backupCardQueue.popLast(){
            isNewCard = false
            cardView.setImage(nil)
            return cardView
        }
        
        let newCardView = generateNewCardView()
        isNewCard = true
        return newCardView
    }
    
    private func generateNewCardView() -> _CardView{
        let newCardView: _CardView
        if cardBackColor != nil{
            newCardView = _CardView(frame: CGRect(origin: CGPoint.zero, size: cardSize), backColor: cardBackColor!)
        }else{
            newCardView = _CardView(frame: CGRect(origin: CGPoint.zero, size: cardSize))
        }
        newCardView.setBorderColor(UIColor.white)
        // if not use AutoLayout, set frame directly, view will move after anchorPoint change.
        // solution for using frame:
        //
        // let oldFrame = view.frame
        // view.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        // view.frame = oldFrame
        //
        // No this problem with AutoLayout.
        newCardView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        addSubview(newCardView)
        NSLayoutConstraint(item: newCardView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        let offsetYConstraint = NSLayoutConstraint(item: newCardView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0 - cardSize.height/2)
        let widthConstraint = NSLayoutConstraint(item: newCardView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: cardSize.width)
        let heightConstraint = NSLayoutConstraint(item: newCardView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: cardSize.height)
        
        offsetYConstraint.identifier = "offsetYConstraint"
        widthConstraint.identifier = "WidthConstraint"
        heightConstraint.identifier = "HeightConstraint"
        offsetYConstraint.isActive = true
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        
        return newCardView
    }
    
    private func adjustConfigurationOfCardView(_ cardView: _CardView, withTargetIndex index: Int, yOffset: CGFloat = 0){
        cardView.layer.zPosition = CGFloat(100 - index)
        if needsBorder{
            cardView.setBorderWidth(calculateScaleFactorForIndex(index) * cardBorderWidth)
        }else{
            cardView.setBorderWidth(0)
        }
        
        if enableBrightnessControl{
            cardView.setBrightness(calculateAlphaForIndex(index))
        }
        
        let offsetYConstraint = self.constraints.filter({$0.identifier == "offsetYConstraint" && $0.firstItem as? _CardView === cardView}).first
        offsetYConstraint?.constant = (0 - cardSize.height/2 - calculateYOffsetForIndex(index)) + yOffset
        
        let scaleFactor: CGFloat = calculateScaleFactorForIndex(index)
        let widthConstraint = cardView.constraints.filter({$0.identifier == "WidthConstraint"}).first
        widthConstraint?.constant = cardSize.width * scaleFactor
        
        let heightConstraint = cardView.constraints.filter({$0.identifier == "HeightConstraint"}).first
        heightConstraint?.constant = cardSize.height * scaleFactor
    }
    
    private func layoutInvisibleCardViews(){
        for cardView in backupCardQueue{
            resetToReuse(cardView)
        }
    }
    
    private func layoutVisibleCardViews(from startIndex: Int = 0){
        UIView.animate(withDuration: 0.25, animations: {
            for (index, cardView) in self.visibleCardQueue.enumerated(){
                guard index >= startIndex else{continue}
                if index >= self.maxVisibleCardCount{
                    cardView.alpha = 0
                }else{
                    self.adjustConfigurationOfCardView(cardView, withTargetIndex: index)
                }
            }
            
            self.layoutIfNeeded()
        }, completion: {_ in
            self.hiddenRedundantVisibleCardsIfNeeded()
            self.fliping = false
        })
    }
    
    private func hiddenRedundantVisibleCardsIfNeeded(){
        if visibleCardQueue.count > maxVisibleCardCount{
            let slice = visibleCardQueue[(maxVisibleCardCount ..< visibleCardQueue.count)]
            for cardView in slice{
                resetToReuse(cardView)
            }
            layoutIfNeeded()
            backupCardQueue.append(contentsOf: slice)
            visibleCardQueue.removeSubrange(maxVisibleCardCount..<visibleCardQueue.count)
        }
    }
    
    private func resetToReuse(_ cardView: _CardView){
        adjustConfigurationOfCardView(cardView, withTargetIndex: 0)
        cardView.layer.zPosition = CGFloat(101)
        if needsBorder{
            cardView.setBorderWidth(cardBorderWidth)
        }else{
            cardView.setBorderWidth(0)
        }
        cardView.hiddenCard()
        
        cardView.layer.transform = flipDownTransform3D
    }

    private var needsFillVisibleQueue: Bool{
        if dataSource == nil{
            return false
        }else{
            let cardCount = dataSource!.numberOfCards(for: self)
            if visibleCardQueue.count < maxVisibleCardCount && currentHeadCardIndex + visibleCardQueue.count < cardCount{
                return true
            }
            return false
        }
    }
    
    private func fillVisibleQueue(){
        if dataSource == nil{return}
        
        let cardCount = dataSource!.numberOfCards(for: self)
        let vacancyCount = currentHeadCardIndex + maxVisibleCardCount < cardCount ? maxVisibleCardCount - visibleCardQueue.count : cardCount - currentHeadCardIndex - visibleCardQueue.count
        let startIndex = currentHeadCardIndex + visibleCardQueue.count
        for index in 0..<vacancyCount{
            let trailCard = self.candidateCardView
            let image = self.dataSource?.cardContainerView(self, imageForCardAt: startIndex + index)
            trailCard.setImage(image)
            trailCard.alpha = 1
            trailCard.restoreCard()
            trailCard.restoreTransform3D()
            
            self.adjustConfigurationOfCardView(trailCard, withTargetIndex: visibleCardQueue.count)
            self.layoutIfNeeded()
            
            self.visibleCardQueue.append(trailCard)
        }
    }
    
    //MARK: Gesture Method
    private let panGesture = UIPanGestureRecognizer()
    private var isInitiallyDown: Bool = true
    private var previousHeadCard: _CardView?
    
    @objc private func panGestureAction(_ gesture: UIPanGestureRecognizer){
        if dataSource == nil{return}
        guard !fliping else {return}
        
        let velocity = gesture.velocity(in: self)
        let percent = gesture.translation(in: self).y/150
        var flipTransform3D = CATransform3DIdentity
        flipTransform3D.m34 = -1.0 / 2000.0
        
        switch gesture.state{
        case .began:
            if velocity.y > 0{
                isInitiallyDown = true
            }else{
                isInitiallyDown = false
                if currentHeadCardIndex == 0{
                    return
                }
                previousHeadCard = candidateCardView
                let image = self.dataSource?.cardContainerView(self, imageForCardAt: self.currentHeadCardIndex - 1)
                previousHeadCard?.setImage(image)
                previousHeadCard?.alpha = 1
            }
        case .changed:
            if visibleCardQueue.count == 0 && isInitiallyDown == true{
                return
            }
            
            if currentHeadCardIndex == 0 && isInitiallyDown == false{
                return
            }
            
            if isInitiallyDown{
                let headCard = visibleCardQueue.first
                switch percent{
                case 0.0..<1.0:
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi) * percent, 1, 0, 0)
                    headCard?.layer.transform = flipTransform3D
                    if percent >= 0.5{
                        headCard?.hiddenCard()
                    }else{
                        headCard?.restoreCard()
                    }
                case 1.0...CGFloat(MAXFLOAT):
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi), 1, 0, 0)
                    headCard?.layer.transform = flipTransform3D
                default: break
                }
            }else{
                switch percent{
                case -1.0...0:
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi) * (percent + 1.0), 1, 0, 0)
                    previousHeadCard?.layer.transform = flipTransform3D
                    if percent <= -0.5{
                        previousHeadCard?.restoreCard()
                    }else{
                        previousHeadCard?.hiddenCard()
                    }
                default: break
                }
            }
        case .ended, .cancelled:
            if visibleCardQueue.count == 0 && isInitiallyDown == true{
                return
            }
            
            if currentHeadCardIndex == 0 && isInitiallyDown == false{
                return
            }
            
            fliping = true
            if isInitiallyDown{
                let headCard = visibleCardQueue.first
                if percent >= 0.5{
                    UIView.animate(withDuration: 0.2, animations: {
                        headCard?.layer.transform = self.flipDownTransform3D
                        headCard?.alpha = 0
                    }, completion: {_ in
                        self.finishLastworkAfterSlideDown(headCard!)
                    })
                }else{
                    headCard?.hiddenBack()
                    UIView.animate(withDuration: 0.2, animations: {
                        headCard?.restoreTransform3D()
                    }, completion: {_ in
                        self.fliping = false
                    })
                }
            }else{
                if percent <= -0.5{
                    UIView.animate(withDuration: 0.2, animations: {
                        self.previousHeadCard?.restoreTransform3D()
                    }, completion: { _ in
                        self.currentHeadCardIndex -= 1
                        self.visibleCardQueue.insert(self.previousHeadCard!, at: 0)
                        self.layoutVisibleCardViews()
                    })
                }else{
                    backupCardQueue.append(previousHeadCard!)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.previousHeadCard?.layer.transform = self.flipDownTransform3D
                        self.previousHeadCard?.alpha = 0
                    }, completion: {_ in
                        self.fliping = false
                    })
                }
            }
        default: break
        }
    }
    
    
    //MARK: Calculation Helper Method
    // y = k * x + m
    private func calcuteResultWith(x1: Int, x2: Int, y1: CGFloat, y2: CGFloat, argument: Int) -> CGFloat{
        if argument == x1{
            return y1
        }
        if argument == x2{
            return y2
        }
        let k = (y1-y2)/CGFloat(x1-x2)
        let m = (CGFloat(x1) * y2 - CGFloat(x2) * y1)/CGFloat(x1-x2)
        return k * CGFloat(argument) + m
    }
    
    // Scale for width, border width.
    private func calculateScaleFactorForIndex(_ indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(1)
        }
        
        var scale = calcuteResultWith(x1: 1, x2: 8, y1: 0.95, y2: 0.5, argument: indexInQueue)
        if scale < 0.1{
            scale = 0.1
        }
        
        return scale
    }
    
    var yOffsets: [CGFloat] = []
    private func calculateYOffsetForIndex(_ indexInQueue: Int) -> CGFloat{
        if indexInQueue < 1{
            return CGFloat(0)
        }
        
        if yOffsets.count >= indexInQueue{
            return yOffsets[..<indexInQueue].reduce(0, +)
        }
        
        let offset = calcuteResultWith(x1: 1, x2: maxVisibleCardCount, y1: maxYOffsetBetweenCards, y2: minYOffsetBetweenCards, argument: indexInQueue)
        yOffsets.append(offset)
        
        return yOffsets[..<indexInQueue].reduce(0, +)
    }

    private func calculateAlphaForIndex(_ indexInQueue: Int) -> CGFloat{
        let alpha1Count: Int = 3
        if indexInQueue < alpha1Count{
            return CGFloat(1)
        }
        
        var alpha = calcuteResultWith(x1: alpha1Count, x2: 9, y1: 1, y2: 0.2, argument: indexInQueue)
        if alpha < 0.1{
            alpha = 0.1
        }else if alpha > 1{
            alpha = 1
        }
        
        return alpha
    }
}

