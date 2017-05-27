//
//  ViewController.swift
//  abc
//
//  Created by Sasori on 16/6/13.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func acAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "AC", bundle: nil).instantiateViewController(withIdentifier: "AC")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func soundAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "SoundControl", bundle: nil).instantiateViewController(withIdentifier: "sound_control")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func appsAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "Apps", bundle: nil).instantiateViewController(withIdentifier: "Apps")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cinemaAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "Cinema", bundle: nil).instantiateViewController(withIdentifier: "cinema_main")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

