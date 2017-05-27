//
//  TCACViewController.swift
//  tc
//
//  Created by Sasori on 16/8/31.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCACViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var fontSize:CGFloat = 130
        if UI_USER_INTERFACE_IDIOM() == .phone {
            fontSize = 50
        }
        self.temperatureLabel.font = UIFont(name: "DBLCDTempBlack", size: fontSize)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        UIHelper.setNavigationBar(self.navigationController?.navigationBar, translucent: true)
    }

    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
