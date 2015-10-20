//
//  ComponentViewController.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 14/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit

class ComponentExampleViewController: UIViewController {

    @IBOutlet weak var cardsView: CardAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        cardsView.cardSize = (300,300)
        cardsView.dataSourceDelegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Actions
    @IBAction func onUpPushed(sender: UIButton) {
        cardsView.flipUp()
    }

    @IBAction func onDownPushed(sender: UIButton) {
        cardsView.flipDown()
    }
    
    @IBAction func onClosePushed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

enum JusticeLeagueLogos: String {
    case WonderWoman = "wonder_woman_logo_by_kalangozilla.jpg"
    case Superman = "superman_kingdom_come_logo_by_kalangozilla.jpg"
    case Batman = "batman_begins_poster_style_logo_by_kalangozilla.jpg"
    case GreenLantern = "green_lantern_corps_logo_by_kalangozilla.jpg"
    case Flash = "flash_logo_by_kalangozilla.jpg"
    case Aquaman = "aquaman_young_justice_logo_by_kalangozilla.jpg"
    case CaptainMarvel = "classic_captain_marvel_jr_logo_by_kalangozilla.jpg"
    //can't find Cybord's Logo.
    case AllMembers = "JLA.jpeg"
    
    static var logoArray : [JusticeLeagueLogos]  {
        get {
            return [.Superman, .WonderWoman, .Batman, .GreenLantern, .Flash, .Aquaman, .CaptainMarvel, .AllMembers]
        }
    }
}

// MARK: - AnimatedCardsViewDataSource
extension ComponentExampleViewController : CardAnimationViewDataSource {
    
    func numberOfVisibleCards() -> Int {
        return 6
    }
    
    func numberOfCards() -> Int {
        return 8
    }
    
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
    
}