//
//  AnimatedCardsView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 14/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit


protocol AnimatedCardsViewDataSource : class {
    
}

public class AnimatedCardsView: UIView {

    private var cardArray : [UIView]!
    
    public struct Constants {
        struct DefaultSize {
            static let width = 400.0
            static let height = 300.0
        }
        static let numberOfCards = 8
    }
    
    override init(frame: CGRect) {
        cardArray = []
        super.init(frame: frame)
        generateCards()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        cardArray = []
        super.init(coder: aDecoder)
        backgroundColor = UIColor.yellowColor()
        generateCards()
    }
    
    
    // MARK: Private stuff
    
    private func generateCards() {
        cardArray = (0...Constants.numberOfCards).map { (tagId) in
            let view = generateNewCardViewWithTagId(tagId)
            self.addSubview(view)
            applyConstraintsToView(view)
            return view
        }
    }
    
    private func generateNewCardViewWithTagId(tagId:NSInteger) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = tagId
        view.backgroundColor = UIColor.purpleColor()
        return view
    }
    
    private func applyConstraintsToView(view:UIView) {
        view.addConstraints([
            NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: CGFloat(1.0), constant: CGFloat(Constants.DefaultSize.width)),
            NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: CGFloat(1.0), constant: CGFloat(Constants.DefaultSize.height)),
            ])
        view.superview!.addConstraints([
            NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: view.superview, attribute: .CenterX, multiplier: CGFloat(1.0), constant: 0),
            NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: view.superview, attribute: .CenterY, multiplier: CGFloat(1.0), constant: 0),
            ])
    }

}
