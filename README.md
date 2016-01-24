# CardAnimation
[Design from Dribble](https://dribbble.com/shots/1265487-First-shot-in-Chapps-Animation). And a [blog](http://www.jianshu.com/p/286222d4edf8) for this, only chinese.
![Design from Dribble](https://d13yacurqjgara.cloudfront.net/users/32399/screenshots/1265487/attachments/173545/secret-project-animation_2x.gif)

## API

I rewrite it. Support reuse card view and pan gesture. You just need to provide number of cards and relative image.

	protocol CardContainerDataSource {
    	func numberOfCardsForCardContainerView(cardContainerView: UICardContainerView) -> Int
    	func cardContainerView(cardContainerView: UICardContainerView, imageForCardAtIndex: Int) -> UIImage?
	}

	class UICardContainerView : UIView {
		var dataSource: CardContainerDataSource?
		
    	//If you want to custom these properties, configure them before asign dataSource, and don't change them once you custom them.
    	//'needsCardCenterVertically' decide card is center vertically in container, or distance of bottom between card and contaienr is the height of card.
    	var needsCardCenterVertically: Bool = false 
    	var enableBrightnessControl: Bool = true
    	var maxVisibleCardCount: Int = 10
    	var defaultCardSize: CGSize = CGSize(width: 400, height: 300)
    	var needsBorder: Bool = true
 		var headCardBorderWidth: CGFloat = 5

    	func slideDown()
    	func slideUp()
    	func reloadData()
    	func insertCardAtIndex(toIndex: Int)
    	func deleteCardAtIndex(toIndex: Int)
    	//Call this method in viewDidLayoutSubviews()
    	func respondsToSizeChange()
	}

Example:
	
	let cardContainerView = UICardContainerView(frame: aFrame)
	aSuperView.addSubview(cardContainerView)
	cardContainerView.dataSource = id<CardContainerDataSource>
	
Done.

[@luxorules](https://github.com/luxorules/CardAnimation/tree/Component) packaged there code before, support pan gesture, card size and custom card view, not only image view. So there are two solutions for choice now. @luxorules's solution:

Classes:

- CardAnimationView: UIView, the view to display a list of card view.
- BasedCardView: UIView, all custom card view must be inherited from this class. 
- ImageCardView: BasedCardView, child class of BasedCardView, if you just want to use image, use this class.

You can custom animation behavior by set the below properties.

	//Animation time for a single card animation.
	public var animationsSpeed = 0.2
	//Defines the card size that will be used. (width, height)
	public var cardSize : (width:CGFloat, height:CGFloat)

CardAnimationView needs a data source delegate to display the content, like UICollectionView.

	public weak var dataSourceDelegate : CardAnimationViewDataSource?
	
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
## How to use?

You can find two solutions in 'Classes' folder. Drag them in your project.

 

## Technical Q&A

#### Change Anchor Point of CALayer

like: (0.5, 0.5) ->(0.5, 1)

Frame:

There are [many ways](http://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view) to do this:

    subView.frame = frame
    subView.layer.anchorPoint = CGPointMake(0.5, 1)
    subView.frame = frame

AutoLayout:

[Discussion](http://stackoverflow.com/questions/12943107/how-do-i-adjust-the-anchor-point-of-a-calayer-when-auto-layout-is-being-used/14105757#14105757) on stackoverflow, but I find a simple way:

    let subViewHeight = 
    let oldConstraintConstant = centerYConstraint.constant
    subView.layer.anchorPoint = CGPointMake(0.5, 1)
    //Like what you do with frame, you need to compensate for additional translation.
    centerYConstraint.constant = subView.bounds.size.height/2 + oldConstraintConstant
    
#### Transform and AutoLayout

From iOS8, transform and autolayout play nice. There is a blog for this: [Constraints & Transformations](http://revealapp.com/blog/constraints-and-transforms.html)

Transform doesn't affect autolayout, only constraints can affect autolayout.

Transform affects view's frame, but do nothing to view's center and bounds.

#### Flip animation with non-transparent background 

Use a subview, and change the container view's background color to what color you want.

When the container view is vertical to screen, make the subview hidden, and after the container view back, make subview visible.

#### Rotation Animation Bug in action method

    let flipTransform = CATransform3DRotate(CATransform3DIdentity, CGFloat(-M_PI), 1, 0, 0)
    UIView.animateWithDuration(0.3, {
      view.layer.transform = flipTransform
    })
    
The animation will not execute and the view just change if you execute above code in an action method, like clip a button. UIView keyFrame animation works fine.