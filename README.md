# CardAnimation
[Design from Dribble](https://dribbble.com/shots/1265487-First-shot-in-Chapps-Animation). And a [blog](http://www.jianshu.com/p/286222d4edf8) for this, only chinese.
![Design from Dribble](https://d13yacurqjgara.cloudfront.net/users/32399/screenshots/1265487/attachments/173545/secret-project-animation_2x.gif)

Thanks for [@luxorules](https://github.com/luxorules/CardAnimation/tree/Component)'s great work. Now you can use this animation in your project easily.

Features:
- Custom card View size. (New added by @luxorules)
- Custom card view, not only image view. (New added by @luxorules)
- Support pan gesture.

**How to use it in your project**

Drap class files in the "Classes" folder into your project, includes CardAnimationView.swift and ImageCardView.swift.

Classes:

- CardAnimationView: UIView, the view to display a list of card view.
- BasedCardView: UIView, all custom card view must be inherited from this class. 
- ImageCardView: BasedCardView, child class of BasedCardView, if you just want to use image, use this class.

You can custom animation behavior by set the below properties.

//Animation time for a single card animation.

`public var animationsSpeed = 0.2`
    
//Defines the card size that will be used. (width, height)

`public var cardSize : (width:CGFloat, height:CGFloat)` 

CardAnimationView needs a data source delegate to display the content, like UICollectionView.

`public weak var dataSourceDelegate : CardAnimationViewDataSource?`

    protocol CardAnimationViewDataSource : class {
        func numberOfVisibleCards() -> Int
        func numberOfCards() -> Int
        /**
        Ask the delegate for a new card to display in the container.
        - parameter number: number that is needed to be displayed.
        - parameter reusedView: the component may provide you with an unused view.
        - returns: correctly configured card view.
        */
        func cardNumber(number:Int, reusedView:BaseCardView?) -> BaseCardView
    }

How to reuse a card view? There is an example in `ComponentExampleViewController.swift`:

    func cardNumber(number: Int, reusedView: BaseCardView?) -> BaseCardView {
        var retView : ImageCardView? = reusedView as? ImageCardView
        print(" 🃏 Requested card number \(number)")
        if retView == nil {
            retView = ImageCardView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        } else {
            print(" ✌️ View Cached ✌️ ")
        }
        retView!.imageView.image = UIImage.init(named: JusticeLeagueLogos.logoArray[number].rawValue)
        return retView!
    }

**Techniques in the animation:** 

**Change Anchor Point of CALayer**

like: (0.5, 0.5) ->(0.5, 1)

Frame:

There are many ways to do this: [link](http://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view)

    subView.frame = frame
    subView.layer.anchorPoint = CGPointMake(0.5, 1)
    subView.frame = frame

AutoLayout:

Discussion on stackoverflow: [link](http://stackoverflow.com/questions/12943107/how-do-i-adjust-the-anchor-point-of-a-calayer-when-auto-layout-is-being-used/14105757#14105757), but I find a simple way:

    let subViewHeight = 
    let oldConstraintConstant = centerYConstraint.constant
    subView.layer.anchorPoint = CGPointMake(0.5, 1)
    //Like what you do with frame, you need to compensate for additional translation.
    centerYConstraint.constant = subView.bounds.size.height/2 + oldConstraintConstant
    
**Transform and AutoLayout**

From iOS8, transform and autolayout play nice. There is a blog for this: [Constraints & Transformations](http://revealapp.com/blog/constraints-and-transforms.html)

Transform doesn't affect autolayout, only constraints can affect autolayout.

Transformes affect view's frame, but do nothing to view's center and bounds.

**Make flip animation background not transparent**

Use a subview, and change the container view's background color to what color you want.

When the container view is vertical to screen, make the subview hidden, and after the container view back, make subview visible.

**Rotation Animation Bug in action method**

    let flipTransform = CATransform3DRotate(CATransform3DIdentity, CGFloat(-M_PI), 1, 0, 0)
    UIView.animateWithDuration(0.3, {
      view.layer.transform = flipTransform
    })
    
The animation will not execute and the view just change if you execute above code in an action method, like clip a button.
You could use 'CGFloat(-M_PI) * 0.99' to fix this.

**To-Do List**

~~1.reuse card view~~
2.reorder card view
3.delete and add card view with pan gesture
