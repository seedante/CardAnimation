//
//  CardView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 16/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit

public class ImageCardView: BaseCardView {
    var imageView:UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        backgroundColor = UIColor.darkGrayColor()
        imageView = UIImageView(frame: frame)
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        addSubview(imageView)
    }

    //hidden property can't be animationable, I recommand using alpha.
    override func contentVisible(visible:Bool) {
        imageView.alpha = visible ? 1.0 : 0.0
    }
    
    override func prepareForReuse() {
        imageView.hidden = false
    }
}
