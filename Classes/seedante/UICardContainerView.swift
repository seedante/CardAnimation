//
//  UICardView.swift
//  CardAnimation
//
//  Created by seedante on 16/1/19.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit

public protocol CardContainerDataSource{
    func numberOfCardsForCardContainerView(_ cardContainerView: UICardContainerView) -> Int
    func cardContainerView(_ cardContainerView: UICardContainerView, imageForCardAtIndex: Int) -> UIImage?
}

private class UICardView: UIView {
    fileprivate let foregroundView = UIView()
    fileprivate let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        let radio = frame.height / frame.width
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: radio, constant: 0))
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: frame.width)
        widthConstraint.identifier = "WidthContraint"
        addConstraint(widthConstraint)
        
        foregroundView.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.backgroundColor = UIColor.black
        foregroundView.alpha = 0
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
        addSubview(foregroundView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
    }
    
    convenience init(){
        self.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
    }
    
    func setImage(_ image: UIImage?){
        imageView.image = image
    }
    
    func adjustAlpha(_ toAlpha: CGFloat){
        if toAlpha <= 0{
            foregroundView.alpha = 0
        }else if toAlpha >= 1{
            foregroundView.alpha = 0.5
        }else{
            foregroundView.alpha = toAlpha * 0.5
        }
    }
    
    func hiddenContent(){
        foregroundView.alpha = 0
        imageView.alpha = 0
    }
    
    func restoreContent(){
        imageView.alpha = 1
    }
}


open class UICardContainerView: UIView {
    
    //MARK: Property to Configure
    //All properties must be configured before 'dataSource' is asigned, and don't change after asigned.
    var needsCardCenterVertically: Bool = true //The property decide card is center vertically in container, or distance of bottom between card and contaienr is the height of card.
    var enableBrightnessControl: Bool = true
    var maxVisibleCardCount: Int = 10
    var defaultCardSize = CGSize(width: 400, height: 300)
    var needsBorder: Bool = true
    var headCardBorderWidth: CGFloat = 5
    
    var dataSource: CardContainerDataSource?{
        didSet{
            if dataSource != nil{
                configure()
            }
        }
    }
    
    //MARK: Init Method
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        panGesture.addTarget(self, action: #selector(UICardContainerView.panGestureAction(_:)))
        addGestureRecognizer(panGesture)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        panGesture.addTarget(self, action: #selector(UICardContainerView.panGestureAction(_:)))
        addGestureRecognizer(panGesture)
    }
    
    deinit{
        self.removeGestureRecognizer(panGesture)
    }
    
    //MARK: Reuseable Card Queue
    /*
    An Array sorted from fisrt card to last card.
    */
    fileprivate var visibleCardQueue: [UICardView] = []
    fileprivate var backupCardQueue: [UICardView] = []
    fileprivate var currentHeadCardIndex: Int = 0
    
    //MARK:Public Method
    func slideDown(){
        guard let headCard = visibleCardQueue.first else{
            return
        }
        
        var flipDownTransform3D = CATransform3DIdentity
        flipDownTransform3D.m34 = -1.0 / 2000.0
        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-Double.pi), 1, 0, 0)
        
        let duration: TimeInterval = 0.5
        //The animation of  borderWidth change in keyFrame animation can't work, so place it in dispatch_after
        //本来 layer 的 borderWidth 是个可以动画的属性，但是在 UIView Animation 却不工作，没办法，只能用这种方式了
        let delayTime = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC) / 2.0)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            headCard.layer.borderWidth = 0
        })
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                headCard.layer.transform = flipDownTransform3D
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.01, animations: {
                headCard.hiddenContent()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
               headCard.alpha = 0
            })
        }, completion: {_ in
            self.finishLastworkAfterSlideDown(headCard)
        })
    }
    
    func slideUp(){
        if dataSource == nil{
            return
        }
        if currentHeadCardIndex == 0{
            return
        }
        
        previousHeadCard = candidateCardView
        if isNewCard{
            var flipDownTransform3D = CATransform3DIdentity
            flipDownTransform3D.m34 = -1.0 / 2000.0
            flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-Double.pi), 1, 0, 0)
            previousHeadCard?.layer.transform = flipDownTransform3D
            previousHeadCard?.hiddenContent()
        }
        
        let image = self.dataSource!.cardContainerView(self, imageForCardAtIndex: self.currentHeadCardIndex - 1)
        previousHeadCard?.setImage(image)
        
        //The animation of borderWidth change in keyFrame animation can't work, so place it in dispatch_after
        let duration: TimeInterval = 0.5
        previousHeadCard?.layer.borderWidth = 0
        let delayTime1 = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC) / 2.0)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime1, execute: {
            self.previousHeadCard?.layer.borderWidth = self.headCardBorderWidth
        })
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.previousHeadCard?.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                self.previousHeadCard?.layer.transform = CATransform3DIdentity
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.01, animations: {
                self.previousHeadCard?.restoreContent()
            })
            }, completion: nil)
        
        //There are some problems if the follow code in completion blovk, so...
        let delayTime2 = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime2, execute: {
            self.currentHeadCardIndex -= 1
            self.visibleCardQueue.insert(self.previousHeadCard!, at: 0)
            self.layoutVisibleCardViews()
        })

    }
    
    func reloadData(){
        for (index, cardView) in visibleCardQueue.enumerated(){
            let image = self.dataSource?.cardContainerView(self, imageForCardAtIndex: index + currentHeadCardIndex)
            cardView.setImage(image)
        }
    }
    
    //You must take care of data source before these action.
    func insertCardAtIndex(_ toIndex: Int){
        if isVisibleOfIndex(toIndex) == false{
            return
        }
        
        let newCard = candidateCardView
        if isNewCard{
            newCard.alpha = 0
        }else{
            newCard.layer.transform = CATransform3DIdentity
        }
        
        let newIndex = toIndex - currentHeadCardIndex
        adjustConstraintOfCardView(newCard, withTargetIndex: newIndex)
        visibleCardQueue.insert(newCard, at: newIndex)
        reloadData()
        
        UIView.animate(withDuration: 0.2, animations: {
            newCard.restoreContent()
            newCard.alpha = 1
            }, completion: {_ in
                self.layoutVisibleCardViews()
        })
    }
    
    func deleteCardAtIndex(_ toIndex: Int){
        if isVisibleOfIndex(toIndex) == false{
            return
        }
        
        let targetCard = visibleCardQueue[toIndex - currentHeadCardIndex]
        visibleCardQueue.remove(at: toIndex - currentHeadCardIndex)
        backupCardQueue.append(targetCard)

        UIView.animate(withDuration: 0.3, animations: {
            targetCard.alpha = 0
            }, completion: {_ in
                self.reloadData()
                self.resetCardViewtoReuse(targetCard)
                if self.needsFillVisibleQueue == true{
                    self.fillVisibleQueue()
                }
                self.layoutVisibleCardViews()
        })
    }
    
    //You must call this method manually when size change.i.e call it in viewDidLayoutSubviews() of ViewController.
    func respondsToSizeChange(){
        layoutVisibleCardViews()
        layoutInvisibleCardViews()
    }
    
    //MARK: Configure Method
    fileprivate func configure(){
        let cardCount = dataSource!.numberOfCardsForCardContainerView(self)
        let vacancyCount = cardCount >= maxVisibleCardCount ? maxVisibleCardCount : cardCount
        for _ in 0..<vacancyCount{
            let newCard = candidateCardView
            newCard.alpha = 1
            visibleCardQueue.append(newCard)
        }
        reloadData()
        layoutVisibleCardViews()
    }
    
    fileprivate var isNewCard: Bool = true
    fileprivate var candidateCardView: UICardView{
        if let cardView = backupCardQueue.popLast(){
            isNewCard = false
            return cardView
        }
        
        let newCardView = generateNewCardView()
        isNewCard = true
        return newCardView
    }
    
    fileprivate func generateNewCardView() -> UICardView{
        let newCardView = UICardView(frame: CGRect(origin: CGPoint.zero, size: defaultCardSize))
        newCardView.layer.borderColor = UIColor.white.cgColor
        addSubview(newCardView)
        addConstraint(NSLayoutConstraint(item: newCardView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        let cardTop = defaultCardSize.height * 2
        let containerCenterY = frame.height / 2
        let additionalConstraint: CGFloat = needsCardCenterVertically ? 0 - defaultCardSize.height/2 : containerCenterY - cardTop
        let offsetYConstraint = NSLayoutConstraint(item: newCardView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0 + additionalConstraint)
        offsetYConstraint.identifier = "offsetYConstraint"
        addConstraint(offsetYConstraint)
        
        newCardView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        offsetYConstraint.constant += defaultCardSize.height / 2
        layoutIfNeeded()
        return newCardView
    }
    
    fileprivate func layoutInvisibleCardViews(){
        for cardView in backupCardQueue{
            adjustConstraintOfCardView(cardView, withTargetIndex: -1)
        }
    }
    
    fileprivate func layoutVisibleCardViews(){
        UIView.animate(withDuration: 0.5, animations: {
            for (index, cardView) in self.visibleCardQueue.enumerated(){
                self.adjustConstraintOfCardView(cardView, withTargetIndex: index)
                if index >= self.maxVisibleCardCount{
                    cardView.alpha = 0
                }
            }
            
            self.layoutIfNeeded()
            }, completion: {_ in
                self.adjustVisibleCardQueue()
        })
    }
    
    fileprivate func adjustVisibleCardQueue(){
        if visibleCardQueue.count > maxVisibleCardCount{
            let slice = visibleCardQueue[(maxVisibleCardCount ..< visibleCardQueue.count)]
            for cardView in slice{
                resetCardViewtoReuse(cardView)
            }
            layoutIfNeeded()
            backupCardQueue.append(contentsOf: slice)
            visibleCardQueue[(maxVisibleCardCount ..< visibleCardQueue.count)] = []
        }
    }
    
    fileprivate func resetCardViewtoReuse(_ cardView: UICardView){
        adjustConstraintOfCardView(cardView, withTargetIndex: 0)
        cardView.layer.borderWidth = 0
        cardView.layer.zPosition = CGFloat(101)
        cardView.hiddenContent()
        
        var flipDownTransform3D = CATransform3DIdentity
        flipDownTransform3D.m34 = -1.0 / 2000.0
        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-Double.pi), 1, 0, 0)
        cardView.layer.transform = flipDownTransform3D
    }
    
    /*Adjust CardView's constraint to right location*/
    fileprivate func adjustConstraintOfCardView(_ cardView: UICardView, withTargetIndex index: Int){
        cardView.layer.zPosition = CGFloat(100 - index)
        if needsBorder{
            cardView.layer.borderWidth = calculateBorderWidthForIndex(index, initialBorderWidth: headCardBorderWidth)
        }else{
            cardView.layer.borderWidth = 0
        }

        if enableBrightnessControl{
            cardView.adjustAlpha(CGFloat(index) / CGFloat(5))
        }

        let offsetYConstraint = self.constraints.filter({$0.identifier == "offsetYConstraint" && $0.firstItem as? UICardView == cardView}).first
        let cardTop = defaultCardSize.height * 2
        let containerCenterY = frame.height / 2
        let additionalConstant: CGFloat = needsCardCenterVertically ? 0 : containerCenterY - cardTop + defaultCardSize.height/2
        offsetYConstraint?.constant = additionalConstant  - calculateYOffsetForIndex(index)
        
        let widthScale = calculateWidthScaleForIndex(index)
        let widthConstraint = cardView.constraints.filter({$0.identifier == "WidthContraint"}).first
        widthConstraint?.constant = defaultCardSize.width * widthScale
    }
    
    fileprivate func isVisibleOfIndex(_ index: Int) -> Bool{
        if dataSource == nil{
            return false
        }
        
        if index < currentHeadCardIndex || index >= currentHeadCardIndex + visibleCardQueue.count{
            return false
        }
        
        return true
    }
    
    fileprivate func finishLastworkAfterSlideDown(_ headCard: UICardView){
        headCard.layer.zPosition = CGFloat(101)
        currentHeadCardIndex += 1
        visibleCardQueue.removeFirst()
        backupCardQueue.append(headCard)
        
        if needsFillVisibleQueue == true{
            fillVisibleQueue()
        }
        layoutVisibleCardViews()
    }

    fileprivate var needsFillVisibleQueue: Bool{
        if dataSource == nil{
            return false
        }else{
            let cardCount = dataSource!.numberOfCardsForCardContainerView(self)
            if visibleCardQueue.count < maxVisibleCardCount && currentHeadCardIndex + visibleCardQueue.count < cardCount{
                return true
            }
            return false
        }
    }
    
    fileprivate func fillVisibleQueue(){
        if dataSource == nil{
            return
        }
        let cardCount = dataSource!.numberOfCardsForCardContainerView(self)
        let vacancyCount = currentHeadCardIndex + maxVisibleCardCount < cardCount ? maxVisibleCardCount - visibleCardQueue.count : cardCount - currentHeadCardIndex - visibleCardQueue.count
        let startIndex = currentHeadCardIndex + visibleCardQueue.count
        for index in 0..<vacancyCount{
            let trailCard = self.candidateCardView
            let image = self.dataSource?.cardContainerView(self, imageForCardAtIndex: startIndex + index)
            trailCard.setImage(image)
            trailCard.alpha = 1
            trailCard.restoreContent()
            trailCard.layer.transform = CATransform3DIdentity
            
            self.adjustConstraintOfCardView(trailCard, withTargetIndex: visibleCardQueue.count)
            self.layoutIfNeeded()
            
            self.visibleCardQueue.append(trailCard)
        }
    }
    
    //MARK: Gesture Method
    fileprivate let panGesture = UIPanGestureRecognizer()
    fileprivate var isInitiallyDown: Bool = true
    fileprivate var previousHeadCard: UICardView?
    
    @objc fileprivate func panGestureAction(_ gesture: UIPanGestureRecognizer){
        if dataSource == nil{
            return
        }
        
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
                let image = self.dataSource!.cardContainerView(self, imageForCardAtIndex: self.currentHeadCardIndex - 1)
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
                        headCard?.hiddenContent()
                        headCard?.layer.borderWidth = 0
                    }else{
                        headCard?.restoreContent()
                        if needsBorder{
                            headCard?.layer.borderWidth = headCardBorderWidth
                        }
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
                        previousHeadCard?.restoreContent()
                        if needsBorder{
                            previousHeadCard?.layer.borderWidth = headCardBorderWidth
                        }
                    }else{
                        previousHeadCard?.hiddenContent()
                        previousHeadCard?.layer.borderWidth = 0
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
            
            if isInitiallyDown{
                let headCard = visibleCardQueue.first
                if percent >= 0.5{
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(Double.pi), 1, 0, 0)
                    UIView.animate(withDuration: 0.2, animations: {
                        headCard?.layer.transform = flipTransform3D
                        headCard?.alpha = 0
                        }, completion: {_ in
                            self.finishLastworkAfterSlideDown(headCard!)
                    })
                }else{
                    headCard?.restoreContent()
                    if needsBorder{
                        headCard?.layer.borderWidth = headCardBorderWidth
                    }
                    UIView.animate(withDuration: 0.2, animations: {
                        headCard?.layer.transform = CATransform3DIdentity
                    })
                }
            }else{
                if percent <= -0.5{
                    if needsBorder{
                        previousHeadCard?.layer.borderWidth = headCardBorderWidth
                    }

                    UIView.animate(withDuration: 0.2, animations: {
                        self.previousHeadCard?.layer.transform = CATransform3DIdentity
                        }, completion: {_ in
                    })
                    self.currentHeadCardIndex -= 1
                    self.visibleCardQueue.insert(self.previousHeadCard!, at: 0)
                    self.layoutVisibleCardViews()
                }else{
                    backupCardQueue.append(previousHeadCard!)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.previousHeadCard?.layer.transform = CATransform3DRotate(flipTransform3D, CGFloat(-Double.pi), 1, 0, 0)
                        self.previousHeadCard?.alpha = 0
                        //self.previousHeadCard?.setImage(nil)
                    })
                }
            }
        default: break
        }
    }

    
    //MARK: Calculation Helper Method
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
    fileprivate func calculateYOffsetForIndex(_ indexInQueue: Int) -> CGFloat{
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
        let widthBaseScale:CGFloat = 1
        
        var factor: CGFloat = 1
        if indexInQueue == 0{
            factor = 1
        }else{
            factor = calculateScaleFactorForIndex(indexInQueue)
        }
        
        return widthBaseScale * factor
    }
    
    //Zoom out card one by one.
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
    
    fileprivate func calculateBorderWidthForIndex(_ indexInQueue: Int, initialBorderWidth: CGFloat) -> CGFloat{
        let scaleFactor = calculateScaleFactorForIndex(indexInQueue)
        return scaleFactor * initialBorderWidth
    }
}
