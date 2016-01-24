//
//  UICardView.swift
//  CardAnimation
//
//  Created by seedante on 16/1/19.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit

public protocol CardContainerDataSource{
    func numberOfCardsForCardContainerView(cardContainerView: UICardContainerView) -> Int
    func cardContainerView(cardContainerView: UICardContainerView, imageForCardAtIndex: Int) -> UIImage?
}

private class UICardView: UIView {
    private let foregroundView = UIView()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        let radio = frame.height / frame.width
        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: radio, constant: 0))
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: frame.width)
        widthConstraint.identifier = "WidthContraint"
        addConstraint(widthConstraint)
        
        foregroundView.translatesAutoresizingMaskIntoConstraints = false
        foregroundView.backgroundColor = UIColor.blackColor()
        foregroundView.alpha = 0
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        
        addSubview(imageView)
        addSubview(foregroundView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: foregroundView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
    }
    
    convenience init(){
        self.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 400, height: 300)))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 400, height: 300)))
    }
    
    func setImage(image: UIImage?){
        imageView.image = image
    }
    
    func adjustAlpha(toAlpha: CGFloat){
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


public class UICardContainerView: UIView {
    
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
        panGesture.addTarget(self, action: "panGestureAction:")
        addGestureRecognizer(panGesture)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        panGesture.addTarget(self, action: "panGestureAction:")
        addGestureRecognizer(panGesture)
    }
    
    deinit{
        self.removeGestureRecognizer(panGesture)
    }
    
    //MARK: Reuseable Card Queue
    /*
    An Array sorted from fisrt card to last card.
    */
    private var visibleCardQueue: [UICardView] = []
    private var backupCardQueue: [UICardView] = []
    private var currentHeadCardIndex: Int = 0
    
    //MARK:Public Method
    func slideDown(){
        guard let headCard = visibleCardQueue.first else{
            return
        }
        
        var flipDownTransform3D = CATransform3DIdentity
        flipDownTransform3D.m34 = -1.0 / 2000.0
        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI), 1, 0, 0)
        
        let duration: NSTimeInterval = 0.5
        //The animation of  borderWidth change in keyFrame animation can't work, so place it in dispatch_after
        //本来 layer 的 borderWidth 是个可以动画的属性，但是在 UIView Animation 却不工作，没办法，只能用这种方式了
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC) / 2.0))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            headCard.layer.borderWidth = 0
        })
        
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: {
                headCard.layer.transform = flipDownTransform3D
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.01, animations: {
                headCard.hiddenContent()
            })
            UIView.addKeyframeWithRelativeStartTime(0.9, relativeDuration: 0.1, animations: {
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
            flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI), 1, 0, 0)
            previousHeadCard?.layer.transform = flipDownTransform3D
            previousHeadCard?.hiddenContent()
        }
        
        let image = self.dataSource!.cardContainerView(self, imageForCardAtIndex: self.currentHeadCardIndex - 1)
        previousHeadCard?.setImage(image)
        
        //The animation of borderWidth change in keyFrame animation can't work, so place it in dispatch_after
        let duration: NSTimeInterval = 0.5
        previousHeadCard?.layer.borderWidth = 0
        let delayTime1 = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC) / 2.0))
        dispatch_after(delayTime1, dispatch_get_main_queue(), {
            self.previousHeadCard?.layer.borderWidth = self.headCardBorderWidth
        })
        
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5, animations: {
                self.previousHeadCard?.alpha = 1
            })
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: {
                self.previousHeadCard?.layer.transform = CATransform3DIdentity
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.01, animations: {
                self.previousHeadCard?.restoreContent()
            })
            }, completion: nil)
        
        //There are some problems if the follow code in completion blovk, so...
        let delayTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime2, dispatch_get_main_queue(), {
            self.currentHeadCardIndex -= 1
            self.visibleCardQueue.insert(self.previousHeadCard!, atIndex: 0)
            self.layoutVisibleCardViews()
        })

    }
    
    func reloadData(){
        for (index, cardView) in visibleCardQueue.enumerate(){
            let image = self.dataSource?.cardContainerView(self, imageForCardAtIndex: index + currentHeadCardIndex)
            cardView.setImage(image)
        }
    }
    
    //You must take care of data source before these action.
    func insertCardAtIndex(toIndex: Int){
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
        visibleCardQueue.insert(newCard, atIndex: newIndex)
        reloadData()
        
        UIView.animateWithDuration(0.2, animations: {
            newCard.restoreContent()
            newCard.alpha = 1
            }, completion: {_ in
                self.layoutVisibleCardViews()
        })
    }
    
    func deleteCardAtIndex(toIndex: Int){
        if isVisibleOfIndex(toIndex) == false{
            return
        }
        
        let targetCard = visibleCardQueue[toIndex - currentHeadCardIndex]
        visibleCardQueue.removeAtIndex(toIndex - currentHeadCardIndex)
        backupCardQueue.append(targetCard)

        UIView.animateWithDuration(0.3, animations: {
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
    private func configure(){
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
    
    private var isNewCard: Bool = true
    private var candidateCardView: UICardView{
        if let cardView = backupCardQueue.popLast(){
            isNewCard = false
            return cardView
        }
        
        let newCardView = generateNewCardView()
        isNewCard = true
        return newCardView
    }
    
    private func generateNewCardView() -> UICardView{
        let newCardView = UICardView(frame: CGRect(origin: CGPointZero, size: defaultCardSize))
        newCardView.layer.borderColor = UIColor.whiteColor().CGColor
        addSubview(newCardView)
        addConstraint(NSLayoutConstraint(item: newCardView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        
        let cardTop = defaultCardSize.height * 2
        let containerCenterY = frame.height / 2
        let additionalConstraint: CGFloat = needsCardCenterVertically ? 0 - defaultCardSize.height/2 : containerCenterY - cardTop
        let offsetYConstraint = NSLayoutConstraint(item: newCardView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0 + additionalConstraint)
        offsetYConstraint.identifier = "offsetYConstraint"
        addConstraint(offsetYConstraint)
        
        newCardView.layer.anchorPoint = CGPointMake(0.5, 1)
        offsetYConstraint.constant += defaultCardSize.height / 2
        layoutIfNeeded()
        return newCardView
    }
    
    private func layoutInvisibleCardViews(){
        for cardView in backupCardQueue{
            adjustConstraintOfCardView(cardView, withTargetIndex: -1)
        }
    }
    
    private func layoutVisibleCardViews(){
        UIView.animateWithDuration(0.5, animations: {
            for (index, cardView) in self.visibleCardQueue.enumerate(){
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
    
    private func adjustVisibleCardQueue(){
        if visibleCardQueue.count > maxVisibleCardCount{
            let slice = visibleCardQueue[Range(start: maxVisibleCardCount, end: visibleCardQueue.count)]
            for cardView in slice{
                resetCardViewtoReuse(cardView)
            }
            layoutIfNeeded()
            backupCardQueue.appendContentsOf(slice)
            visibleCardQueue[Range(start: maxVisibleCardCount, end: visibleCardQueue.count)] = []
        }
    }
    
    private func resetCardViewtoReuse(cardView: UICardView){
        adjustConstraintOfCardView(cardView, withTargetIndex: 0)
        cardView.layer.borderWidth = 0
        cardView.layer.zPosition = CGFloat(101)
        cardView.hiddenContent()
        
        var flipDownTransform3D = CATransform3DIdentity
        flipDownTransform3D.m34 = -1.0 / 2000.0
        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI), 1, 0, 0)
        cardView.layer.transform = flipDownTransform3D
    }
    
    /*Adjust CardView's constraint to right location*/
    private func adjustConstraintOfCardView(cardView: UICardView, withTargetIndex index: Int){
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
    
    private func isVisibleOfIndex(index: Int) -> Bool{
        if dataSource == nil{
            return false
        }
        
        if index < currentHeadCardIndex || index >= currentHeadCardIndex + visibleCardQueue.count{
            return false
        }
        
        return true
    }
    
    private func finishLastworkAfterSlideDown(headCard: UICardView){
        headCard.layer.zPosition = CGFloat(101)
        currentHeadCardIndex += 1
        visibleCardQueue.removeFirst()
        backupCardQueue.append(headCard)
        
        if needsFillVisibleQueue == true{
            fillVisibleQueue()
        }
        layoutVisibleCardViews()
    }

    private var needsFillVisibleQueue: Bool{
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
    
    private func fillVisibleQueue(){
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
    private let panGesture = UIPanGestureRecognizer()
    private var isInitiallyDown: Bool = true
    private var previousHeadCard: UICardView?
    
    @objc private func panGestureAction(gesture: UIPanGestureRecognizer){
        if dataSource == nil{
            return
        }
        
        let velocity = gesture.velocityInView(self)
        let percent = gesture.translationInView(self).y/150
        var flipTransform3D = CATransform3DIdentity
        flipTransform3D.m34 = -1.0 / 2000.0
        
        switch gesture.state{
        case .Began:
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
        case .Changed:
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
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI) * percent, 1, 0, 0)
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
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI), 1, 0, 0)
                    headCard?.layer.transform = flipTransform3D
                default: break
                }
            }else{
                switch percent{
                case -1.0...0:
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI) * (percent + 1.0), 1, 0, 0)
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
        case .Ended, .Cancelled:
            if visibleCardQueue.count == 0 && isInitiallyDown == true{
                return
            }
            
            if currentHeadCardIndex == 0 && isInitiallyDown == false{
                return
            }
            
            if isInitiallyDown{
                let headCard = visibleCardQueue.first
                if percent >= 0.5{
                    flipTransform3D = CATransform3DRotate(flipTransform3D, CGFloat(M_PI), 1, 0, 0)
                    UIView.animateWithDuration(0.2, animations: {
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
                    UIView.animateWithDuration(0.2, animations: {
                        headCard?.layer.transform = CATransform3DIdentity
                    })
                }
            }else{
                if percent <= -0.5{
                    if needsBorder{
                        previousHeadCard?.layer.borderWidth = headCardBorderWidth
                    }

                    UIView.animateWithDuration(0.2, animations: {
                        self.previousHeadCard?.layer.transform = CATransform3DIdentity
                        }, completion: {_ in
                    })
                    self.currentHeadCardIndex -= 1
                    self.visibleCardQueue.insert(self.previousHeadCard!, atIndex: 0)
                    self.layoutVisibleCardViews()
                }else{
                    backupCardQueue.append(previousHeadCard!)
                    UIView.animateWithDuration(0.2, animations: {
                        self.previousHeadCard?.layer.transform = CATransform3DRotate(flipTransform3D, CGFloat(-M_PI), 1, 0, 0)
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
    private func calculateYOffsetForIndex(indexInQueue: Int) -> CGFloat{
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
