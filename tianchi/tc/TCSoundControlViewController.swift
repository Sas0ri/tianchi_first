//
//  TCSoundControlViewController.swift
//  tc
//
//  Created by Sasori on 16/8/31.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCSoundControlViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        UIHelper.setNavigationBar(self.navigationController?.navigationBar, translucent: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
