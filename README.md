# CardAnimation
[Design from Dribble](https://dribbble.com/shots/1265487-First-shot-in-Chapps-Animation)，[blog](http://www.jianshu.com/p/286222d4edf8) for this, only chinese.
![Design from Dribble](https://d13yacurqjgara.cloudfront.net/users/32399/screenshots/1265487/attachments/173545/secret-project-animation_2x.gif)


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

1. reuse card view

2. reorder card view

3. delete and add card view with pan gesture
