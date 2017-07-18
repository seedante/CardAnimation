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
    func cardImageAtIndex(_ index:Int) -> UIImage?
}

enum panScrollDirection{
    case up, down
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
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 3/4, constant: 0))
        cardContainerView.addConstraint(NSLayoutConstraint(item: cardContainerView, attribute: .height, relatedBy: .equal, toItem: cardContainerView, attribute: .width, multiplier: 1, constant: 0))
        view.layoutIfNeeded()
        
        cardContainerView.dataSource = self
    }

    //MARK: Card Container Data Source
    func numberOfCardsForCardContainerView(_ cardContainerView: UICardContainerView) -> Int{
        return logoArray.count
    }
    func cardContainerView(_ cardContainerView: UICardContainerView, imageForCardAtIndex index: Int) -> UIImage?{
        return index < logoArray.count ? UIImage(named: logoArray[index].rawValue)! : nil
    }

    //MARK: Action Method
    @IBAction func flipUp(_ sender: AnyObject) {
        cardContainerView.slideUp()
    }

    @IBAction func flipDown(_ sender: AnyObject) {
        cardContainerView.slideDown()
    }

    @IBAction func insertACard(_ sender: AnyObject) {
        logoArray.insert(.Batman, at: 1)
        cardContainerView.insertCardAtIndex(1)
    }

    @IBAction func deleteACard(_ sender: AnyObject) {
        logoArray.remove(at: 1)
        cardContainerView.deleteCardAtIndex(1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardContainerView.respondsToSizeChange()
    }
}

