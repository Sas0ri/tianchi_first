//
//  TCCinemaFiltViewManager.swift
//  tc
//
//  Created by Sasori on 16/9/6.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

protocol TCCinemaFiltViewManagerDelegate:NSObjectProtocol {
    func onClearFilter()
    func onSelectType(_ index:Int)
    func onSelectArea(_ index:Int)
    func onSelectYear(_ index:Int)
}

class TCCinemaFiltViewManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var typeView: UICollectionView!
    @IBOutlet weak var areaView: UICollectionView!
    @IBOutlet weak var yearView: UICollectionView!
    weak var delegate:TCCinemaFiltViewManagerDelegate?
    
    let types = ["全部", "爱情", "喜剧", "动作", "战争", "科幻", "恐怖", "剧情", "古装", "灾难"]
    let areas = ["全部", "香港", "台湾", "美国", "英国", "大陆", "法国", "印度", "日本", "韩国"]
    let years = ["全部", "2016", "2015", "2014", "2013", "2012", "2011", "2010", "更早"]
    
    @IBAction func clearAction(_ sender: AnyObject) {
        let indexPath = IndexPath(item: 0, section: 0)
        self.typeView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        self.areaView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        self.yearView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        self.delegate?.onClearFilter()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.yearView {
            return 9
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as? UILabel
        if collectionView == self.typeView {
            label?.text = self.types[indexPath.row]
        } else if collectionView == self.areaView {
            label?.text = self.areas[indexPath.row]
        } else if collectionView == self.yearView {
            label?.text = self.years[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/2, height: collectionView.bounds.size.height/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.typeView {
            self.delegate?.onSelectType(indexPath.item)
        } else if collectionView == self.areaView {
            self.delegate?.onSelectArea(indexPath.item)
        } else if collectionView == self.yearView {
            self.delegate?.onSelectYear(indexPath.item)
        }
    }
}
