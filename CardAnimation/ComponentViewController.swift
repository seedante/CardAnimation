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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onUpPushed(sender: UIButton) {
    }

    @IBAction func onDownPushed(sender: UIButton) {
    }
    
}
