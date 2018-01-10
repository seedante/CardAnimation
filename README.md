# CardAnimation

[Design from Dribble](https://dribbble.com/shots/1265487-First-shot-in-Chapps-Animation).
![Design from Dribble](https://d13yacurqjgara.cloudfront.net/users/32399/screenshots/1265487/attachments/173545/secret-project-animation_2x.gif)

[实现思路在这里](http://www.jianshu.com/p/286222d4edf8)。

## Two Solutions

At the begin, I didn't encapsulate code, [@luxorules](https://github.com/luxorules/CardAnimation/tree/Component) refactor code into class and improve it to support not only image, then I encapsulate my code
into class. So, there are two choices.

#### CardContainerView by seedante

Here is [CardContainerView API reference](https://seedante.github.io/CardAnimation/Classes/CardContainerView.html). [CardContainerView](https://github.com/seedante/CardAnimation/blob/master/Classes/CardContainerView.swift) supports custom card size, pan gesture. 

Example:
	
	let cardContainerView = CardContainerView(frame: aFrame)// with defalut card size.
	cardContainerView.dataSource = id<CardContainerDataSource>
	
Done.

    public protocol CardContainerDataSource: class{
        func numberOfCards(for cardContainerView: UICardContainerView) -> Int
        func cardContainerView(_ cardContainerView: UICardContainerView, imageForCardAt index: Int) -> UIImage?
    }


#### CardAnimationView by @luxorules

[CardAnimationView](https://github.com/seedante/CardAnimation/blob/master/Classes/CardAnimationView.swift) supports custom card size, pan gesture. 

Usage is simple also:

    let cardAnimationView = CardAnimationView.init(frame: aFrame)// with defalut card size.
    cardAnimationView.dataSourceDelegate = id<CardAnimationViewDataSource>

It adds a little complexity to exchange for: custom card view(not only image).

    protocol CardAnimationViewDataSource : class {
        func numberOfVisibleCards() -> Int
        func numberOfCards() -> Int
        // Return view displayed in the CardAnimationView. If reusedView is not nil,
        // you could configure and return it to reuse it.
        func cardNumber(number:Int, reusedView:BaseCardView?) -> BaseCardView
    }

Classes:

- CardAnimationView: UIView, the view to display a list of card view.
- BasedCardView: UIView, all custom card view must be inherited from this class. 
- ImageCardView: BasedCardView, child class of BasedCardView, if you just want to use image, use this class.

## Requirements

* iOS 8.0/Swift 4.0

## Installation

Two solutions are both single file. They are in `Classes` folder. Just need to import file into your project.

## Other

The project is released under the [MIT LICENSE](https://github.com/seedante/CardAnimation/blob/master/LICENSE). And relative technical points are moved to [wiki](https://github.com/seedante/CardAnimation/wiki/CardAnimation-Technical-Point).