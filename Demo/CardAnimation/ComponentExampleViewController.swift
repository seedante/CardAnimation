//
//  ComponentViewController.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 14/10/15.
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
    @IBAction func onUpPushed(_ sender: UIButton) {
        let _ = cardsView.flipUp()
    }

    @IBAction func onDownPushed(_ sender: UIButton) {
        let _ = cardsView.flipDown()
    }
    
    @IBAction func onClosePushed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
    
    func cardNumber(_ number: Int, reusedView: BaseCardView?) -> BaseCardView {
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
