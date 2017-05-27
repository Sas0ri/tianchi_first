//
//  TVKTVLanguageViewController.swift
//  tc
//
//  Created by Sasori on 16/6/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

enum TCKTVLanguage:Int {
    case mandarin = 2
    case korean = 3
    case japanese = 4
    case taiwanese = 5
    case english = 6
    case cantonese = 7
}

class TCKTVLanguageViewController: UIViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return CGSize(width: 216, height: 208)
        }
        return CGSize(width: (collectionView.bounds.size.height - 10)/2, height: (collectionView.bounds.size.height - 10)/2)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let button = sender as! UIButton
        let vc = segue.destination as! TCKTVSongsViewController
        vc.language = TCKTVLanguage(rawValue: button.tag)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
