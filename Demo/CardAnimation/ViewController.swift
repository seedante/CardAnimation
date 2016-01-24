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
        
        cardContainerView.clipsToBounds = false
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

