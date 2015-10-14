//
//  AnimatedCardsView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 14/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit

public class AnimatedCardsView: UIView {

    private var cardArray : [UIView]!
    
    public struct Constants {
        struct DefaultSize {
            let width = 400
            let height = 300
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        cardArray = []
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        cardArray = []
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.yellowColor()
    }
    
    
    // MARK: Private stuff
    
    func generateCards() {
        
    }

}
