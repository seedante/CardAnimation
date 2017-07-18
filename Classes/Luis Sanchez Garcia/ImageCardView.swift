//
//  CardView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 16/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit

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
