//
//  CardView.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 16/10/15.
//  Copyright © 2016年 seedante
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
