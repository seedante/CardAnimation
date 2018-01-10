//
//  ViewController.swift
//  CardAnimation
//
//  Created by seedante on 15/9/30.
//  Copyright © 2016 seedante
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

enum JusticeLeague: String{
    case WonderWoman = "wonder_woman_logo_by_kalangozilla.jpg"
    case Superman = "superman_logo_by_kalangozilla.jpg"
    case Batman = "batman_begins_poster_style_logo_by_kalangozilla.jpg"
    case GreenLantern = "green_lantern_corps_logo_by_kalangozilla.jpg"
    case Flash = "flash_logo_by_kalangozilla.jpg"
    case Aquaman = "aquaman_young_justice_logo_by_kalangozilla.jpg"
    case CaptainMarvel = "classic_captain_marvel_jr_logo_by_kalangozilla.jpg"
    case JL = "JL.jpg"
    
    static var members:[JusticeLeague] = [.Superman, .WonderWoman, .Batman, .GreenLantern, .Flash, .Aquaman, .CaptainMarvel, .JL]
    static func summon() -> JusticeLeague{
        return members[Int(arc4random_uniform(UInt32(members.count)))]
    }
}

class ViewController: UIViewController, CardContainerDataSource {
    let cardContainerView = CardContainerView()
    var JLHeros: [JusticeLeague] = [.Superman]
    
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
    func numberOfCards(for cardContainerView: CardContainerView) -> Int{
        return JLHeros.count
    }
    func cardContainerView(_ cardContainerView: CardContainerView, imageForCardAt index: Int) -> UIImage?{
        if index < 0{
            return nil
        }else{
            return index < JLHeros.count ? UIImage(named: JLHeros[index].rawValue)! : nil
        }
    }

    //MARK: Action Method
    @IBAction func flipUp(_ button: UIButton) {
        cardContainerView.slideUp()
    }

    @IBAction func flipDown(_ button: UIButton) {
        cardContainerView.slideDown()
    }

    @IBAction func insertACard(_ sender: AnyObject) {
        if let headIndex = cardContainerView.headCardIndexAtDataSource{
            let visibleCount = min(JLHeros.count - headIndex, cardContainerView.maxVisibleCardCount)
            let insertIndex = headIndex + Int(arc4random_uniform(UInt32(visibleCount)))
            JLHeros.insert(JusticeLeague.summon(), at: insertIndex)
            cardContainerView.insertCard(at: insertIndex)
        }else{
            JLHeros.insert(JusticeLeague.summon(), at: 0)
            cardContainerView.insertCard(at: 0)
        }
    }

    
    @IBAction func deleteACard(_ sender: AnyObject) {
        guard JLHeros.count > 0 else{return}
        let headIndex = cardContainerView.headCardIndexAtDataSource!
        let visibleCount = min(JLHeros.count - headIndex, cardContainerView.maxVisibleCardCount)
        let deleteIndex = headIndex + Int(arc4random_uniform(UInt32(visibleCount)))
        JLHeros.remove(at: deleteIndex)
        cardContainerView.removeCard(at: deleteIndex)
    }
    
    var sizeChanged: Bool = false
    @IBAction func changeCardSize(_ sender: Any) {
        if sizeChanged{
            cardContainerView.cardSize = CGSize.init(width: 400, height: 300)
            sizeChanged = false
        }else{
            cardContainerView.cardSize = CGSize.init(width: 300, height: 200)
            sizeChanged = true
        }
        cardContainerView.layoutCardsIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

