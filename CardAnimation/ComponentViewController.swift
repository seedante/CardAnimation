//
//  ComponentViewController.swift
//  CardAnimation
//
//  Created by Luis Sanchez Garcia on 14/10/15.
//  Copyright © 2015 seedante. All rights reserved.
//

import UIKit

class ComponentViewController: UIViewController {

    @IBOutlet weak var cardsView: AnimatedCardsView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}

// MARK: - AnimatedCardsViewDataSource
extension ComponentViewController : AnimatedCardsViewDataSource {
    
    func numberOfVisibleCards() -> Int {
        return 2
    }
    
    func numberOfCards() -> Int {
        return 8
    }
    
    func contentForCardNumber(number:Int, size:(width:CGFloat, height:CGFloat)) -> UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    }
    
}