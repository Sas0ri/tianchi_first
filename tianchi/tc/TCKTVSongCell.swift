//
//  TCKTVSongCell.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

protocol TCKTVSongCellDelegate {
    func onFirstAction(_ cell: UICollectionViewCell)
    func onSecondAction(_ cell:UICollectionViewCell)
}

class TCKTVSongCell: UICollectionViewCell {
    
    var delegate:TCKTVSongCellDelegate?
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var singerNameLabel: UILabel!
    
    @IBAction func firstAction(_ sender: AnyObject) {
        self.delegate?.onFirstAction(self)
    }
    
    @IBAction func secondAction(_ sender: AnyObject) {
        self.delegate?.onSecondAction(self)
    }
}
