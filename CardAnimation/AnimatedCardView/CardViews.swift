//
//  CardView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 16/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit

public class BaseCardView: UIView {

}

class ImageCardView: BaseCardView {
    var imageView:UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        imageView = UIImageView.init(frame: frame)
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        addSubview(imageView)
    }
}
