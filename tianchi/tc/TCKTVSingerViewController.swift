//
//  TVKTVSingerViewController.swift
//  tc
//
//  Created by Sasori on 16/6/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class TCKTVSingerViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pageLabel: UILabel!
    
    var page:Int = 1
    var client = TCKTVSingerClient()
    var singers:[Int:[TCKTVSinger]] = [Int:[TCKTVSinger]]()
    var totalPage:String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fontSize:CGFloat = 14.0
        if UI_USER_INTERFACE_IDIOM() == .phone {
            fontSize = 10.0
        }
        self.segmentedControl.clipsToBounds = true
        self.segmentedControl.layer.cornerRadius = 4
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)], for: .selected)
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)], for: UIControlState())
        self.segmentedControl.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"171717"), cornerRadius: 0), for: UIControlState(), barMetrics: .default)
        self.segmentedControl.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"fb8808"), cornerRadius: 0), for: .selected, barMetrics: .default)
        self.segmentedControl.selectedSegmentIndex = 0
        // Do any additional setup after loading the view.
        
        self.searchBar.setImage(UIImage(named: "ktv_search_icon"), for: .search, state: UIControlState())
        if let subViews = self.searchBar.subviews.last?.subviews {
            for v in  subViews {
                if v.isKind(of: UITextField.self) {
                    let tf = v as! UITextField
                    tf.backgroundColor = UIColor.clear
                }
            }
        }
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func segChanged(_ sender: AnyObject) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.loadData()
    }
    
    func loadData() {
        var limit = 8
        if UI_USER_INTERFACE_IDIOM() == .phone {
            limit = 12
        }
        
        let page = self.page
        let nextPage = self.page + 1
        self.client.getSingers(self.searchBar.text, type: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit) { (singers, totalPage, flag) in
            if flag {
                self.totalPage = totalPage
                self.singers[page] = singers!
                self.collectionView.reloadData()
                if self.page == 1 {
                    self.updatePage(shouldSelect: false)
                }
                
            } else {
                self.view.showTextAndHide("加载失败")
            }
        }
        //预加载
        self.client.getSingers(self.searchBar.text, type: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit) { (singers, totalPage, flag) in
            if flag {
                self.singers[nextPage] = singers!
            }
        }
    }

    
    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        let page = collectionView.tag + 1
        if let singers = self.singers[page] {
            return singers.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            self.page = indexPath.row + 1
            if self.singers[self.page] == nil {
                self.loadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.page =  self.collectionView.indexPathsForVisibleItems.first!.row + 1
        self.updatePage(shouldSelect: false)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "container", for: indexPath) as! TCKTVContainerCell
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "song", for: indexPath) as! TCKTVSingerCell
        let page = collectionView.tag + 1
        let singers = self.singers[page]
        let singer = singers![indexPath.row]
        cell.singerNameLabel.text = singer.singerName
        let url = self.client.singerIconURL(singer.singerId)
        cell.singerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "public_singer"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return collectionView.bounds.size
        }
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return CGSize(width: floor((collectionView.bounds.size.width - 50)/6), height: floor((collectionView.bounds.size.height - 10)/2))
        }
        return CGSize(width: 180, height: 180)
    }

    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.loadData()
    }

    @IBAction func prePage(_ sender: AnyObject) {
        if self.page == 1 {
            return
        }
        self.page = self.page - 1
        self.updatePage(shouldSelect: true)
        self.loadData()
    }
    
    @IBAction func nextPage(_ sender: AnyObject) {
        if Int(self.totalPage) < self.page + 1 {
            return
        }
        self.page = self.page + 1
        self.updatePage(shouldSelect: true)
        self.loadData()
    }
    
    func updatePage(shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        if shouldSelect {
            self.collectionView.scrollToItem(at: IndexPath(row:self.page-1,section: 0), at: UICollectionViewScrollPosition(), animated: false)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! TCKTVSingerCell
        let collectionView = cell.superview as! UICollectionView
        let indexPath = collectionView.indexPath(for: cell)
        let singers = self.singers[self.page]
        let singer = singers![indexPath!.row]
        let vc = segue.destination as! TCKTVSongsViewController
        vc.singer = singer.singerName
    }

}
