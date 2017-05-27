//
//  TCKTVMainViewController.swift
//  tc
//
//  Created by Sasori on 16/6/13.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVMainViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navBackground: UIImageView!
    
    var mainVC:UINavigationController!
    var orderedVC:UIViewController!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ktv_main") as!TCKTVMainBoardViewController

        let navVC = UINavigationController(rootViewController: mainVC)
        self.addChildViewController(navVC)
        navVC.didMove(toParentViewController: self)
        self.containerView.addSubview(navVC.view)
        navVC.view.frame = self.containerView.bounds
        mainVC.didNavToNext = {
            self.navBackground.isHidden = true
            self.backButton.isHidden = false
        }
        mainVC.didNavBack = {
            self.backButton.isHidden = self.navigationController == nil
            self.navBackground.isHidden = false
        }

        self.mainVC = navVC
        
        let orderedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ktv_songs_from_ordered") as! TCKTVSongsViewController
        orderedVC.ordered = true
        self.addChildViewController(orderedVC)
        orderedVC.didMove(toParentViewController: self)
        orderedVC.view.frame = self.containerView.bounds
        orderedVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.orderedVC = orderedVC
        TCContext.sharedContext().orderedSongsViewController = orderedVC
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        if self.mainVC.viewControllers.count > 1 {
            self.mainVC.popViewController(animated: false)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Bottom Controller

    @IBAction func mainAction(_ sender: AnyObject) {
        self.mainVC.popToRootViewController(animated: false)
        self.containerView.addSubview(self.mainVC.view)
        self.orderedVC.view.removeFromSuperview()
        self.navBackground.isHidden = self.mainVC.viewControllers.count > 1
    }
    
    @IBAction func orderedAction(_ sender: AnyObject) {
        self.mainVC.view.removeFromSuperview()
        self.containerView.addSubview(self.orderedVC.view)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0))
        self.containerView.layoutIfNeeded()
        self.navBackground.isHidden = true
        self.backButton.isHidden = true
    }
    
    @IBAction func muteAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1203
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnUpAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1201
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnDownAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1202
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func pauseAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1103
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func originAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1104
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func switchAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1102
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func replayAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1101
        TCContext.sharedContext().socketManager.sendPayload(payload)
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
