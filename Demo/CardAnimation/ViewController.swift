//
//  ViewController.swift
//  CardAnimation
//
//  Created by seedante on 15/9/30.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

protocol SDECardSource{
    var cardCount: Int {get set}
    func cardImageAtIndex(index:Int) -> UIImage?
}

enum panScrollDirection{
    case Up, Down
}

enum JusticeLeagueHeroLogo: String{
    case WonderWoman = "wonder_woman_logo_by_kalangozilla.jpg"
    case Superman = "superman_kingdom_come_logo_by_kalangozilla.jpg"
    case Batman = "batman_begins_poster_style_logo_by_kalangozilla.jpg"
    case GreenLantern = "green_lantern_corps_logo_by_kalangozilla.jpg"
    case Flash = "flash_logo_by_kalangozilla.jpg"
    case Aquaman = "aquaman_young_justice_logo_by_kalangozilla.jpg"
    case CaptainMarvel = "classic_captain_marvel_jr_logo_by_kalangozilla.jpg"
    //can't find Cybord's Logo.
    case AllMembers = "JLA.jpeg"
}


class ViewController: UIViewController, CardContainerDataSource {

    let cardContainerView = UICardContainerView()
    var logoArray: [JusticeLeagueHeroLogo] = [.Superman, .WonderWoman, .Batman, .GreenLantern, .Flash, .Aquaman, .CaptainMarvel, .AllMembers]

    //MARK: View Life Management
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.backgroundColor = UIColor.blueColor()
        view.addSubview(cardContainerView)
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 3/4, constant: 0))
        cardContainerView.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .Height, relatedBy: .Equal, toItem: cardContainerView, attribute: .Width, multiplier: 1, constant: 0))
        view.layoutIfNeeded()
        
        cardContainerView.dataSource = self
    }

    //MARK: Card Container Data Source
    func numberOfCardsForCardContainerView(cardContainerView: UICardContainerView) -> Int{
        return logoArray.count
    }
    func cardContainerView(cardContainerView: UICardContainerView, imageForCardAtIndex index: Int) -> UIImage?{
        return index < logoArray.count ? UIImage(named: logoArray[index].rawValue)! : nil
    }

    //MARK: Action Method
    @IBAction func flipUp(sender: AnyObject) {
        cardContainerView.slideUp()
    }

    @IBAction func flipDown(sender: AnyObject) {
//        guard let frontView = view.viewWithTag(frontCardTag) else{
//            return
//        }
//
//
//        let duration: NSTimeInterval = 0.5
//        //adjust borderWidth. Because the animation of  borderWidth change in keyFrame animation can't work, so place it in dispatch_after
//        //本来 layer 的 borderWidth 是个可以动画的属性，但是在 UIView Animation 却不工作，没办法，只能用这种方式了
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC) / 2.0))
//        dispatch_after(delayTime, dispatch_get_main_queue(), {
//            frontView.layer.borderWidth = 0
//        })


        //There is a bug when you want to rotate 180, if you use UIView blcok animation, it doesn't work as expected: 1.no animation, just jump to final value; 2.rotate wrong direction.
        //You could use a closed value or animate it in UIView key frame animation.
        //此处有个很大的问题，折磨了我几个小时。官方的实现有Bug，在 UIView block animation 里旋转180度时会出现两种情况，一是不会执行动画而是直接跳到终点值，二是反方向旋转。
        //其他的角度没有问题，这里使用近似值替代不会产生这个个问题。不过, 在 key frame animation 里执行这个动画是正常的。
//        flipDownTransform3D = CATransform3DRotate(flipDownTransform3D, CGFloat(-M_PI)*0.99, 1, 0, 0)
//        UIView.animateWithDuration(duration, animations: {
//            frontView.layer.transform = flipDownTransform3D
//        })

        //And in key frame animtion, we can fix another bug: a view is transparent in transform rotate. 
        //I put the view which show the content in a container view, when the container view is vertical to screen, hide the nested content view, then we can see only the content of background color, just like the back of a card.
        //用 key frame animation 可以方便地解决卡片在旋转过程中背面透明的问题，解决办法是将内容视图放入一个容器视图，当容器视图旋转90时，此时将内容视图隐藏，从这时候开始我们就只能看到容器视图的背景色了，这样一来就和现实接近了。
        //而在普通的 UIView animation 里，在旋转一半的时候将内容视图隐藏比较麻烦，比如先旋转90度，在 completion block 里将内容视图隐藏，然后再添加一个动画继续旋转。用 key frame 里就比较方便，而且没有UIView animation 里旋转180有问题的 bug。
     
        cardContainerView.slideDown()
    }

    @IBAction func insertACard(sender: AnyObject) {
        logoArray.insert(.Batman, atIndex: 1)
        cardContainerView.insertCardAtIndex(1)
    }

    @IBAction func deleteACard(sender: AnyObject) {
        logoArray.removeAtIndex(1)
        cardContainerView.deleteCardAtIndex(1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardContainerView.respondsToSizeChange()
    }
}

