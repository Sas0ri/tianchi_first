//
//  TCKTVCloudSearchViewController.swift
//  tc
//
//  Created by Sasori on 16/8/13.
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


class TCKTVCloudSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,TCKTVSongCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var singer:String?
    var language:TCKTVLanguage?
    var category:String?
    var searchText:String?
    var words:Int = 0
    
    var page:Int = 1
    var client = TCKTVSongClient()
    var clouds:[Int:[TCKTVCloud]] = [Int:[TCKTVCloud]]()
    var totalPage:String = "0"
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var pageLabel: UILabel!
    
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
        self.segmentedControl.selectedSegmentIndex = words
        self.searchBar.setImage(UIImage(named: "ktv_search_icon"), for: .search, state: UIControlState())
        self.searchBar.text = self.searchText
        if let subViews = self.searchBar.subviews.last?.subviews {
            for v in  subViews {
                if v.isKind(of: UITextField.self) {
                    let tf = v as! UITextField
                    tf.backgroundColor = UIColor.clear
                }
            }
        }
        self.loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: NSNotification.Name(rawValue: TCKTVDownloadLoadedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: NSNotification.Name(rawValue: TCKTVDownloadUpdatedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: NSNotification.Name(rawValue: TCKTVDownloadRemovedNotification), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segChanged(_ sender: AnyObject) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.loadData()
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.loadData()
    }
    
    func loadData() {
        var limit = 9
        if UI_USER_INTERFACE_IDIOM() == .phone {
            limit = 6
        }
        
        let page = self.page
        let nextPage = self.page + 1
        self.client.searchCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, language: self.language?.rawValue, singer: self.singer, type: self.category) {
            (clouds, totalPage, flag) in
            
            if flag {
                self.totalPage = totalPage
                self.clouds[page] = clouds!
                self.collectionView.reloadData()
                if self.page == 1 {
                    self.updatePage(shouldSelect: false)
                }
            } else {
                self.view.showTextAndHide("加载失败")
            }
        }
        //预加载
        self.client.searchCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit, language: self.language?.rawValue, singer: self.singer, type: self.category) {
            (clouds, totalPage, flag) in
            
            if flag {
                self.clouds[nextPage] = clouds!
            }
        }
        
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
    
    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        let page = collectionView.tag + 1
        if let clouds = self.clouds[page] {
            return clouds.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            if self.collectionView.isDragging {
                self.page = indexPath.row + 1
            }
            if self.clouds[self.page] == nil {
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
        let page = collectionView.tag + 1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "song", for: indexPath) as! TCKTVSongCell
        let clouds = self.clouds[page]
        let cloud = clouds![indexPath.row]
        cell.singerNameLabel.text = cloud.singer
        cell.songNameLabel.text = cloud.songName
        let statusLabel = cell.viewWithTag(1) as! UILabel
        
        var waiting = false
        for song in TCContext.sharedContext().downloads {
            if song.songNum == cloud.songNum {
                waiting = true
                break
            }
        }
        let downloading = TCContext.sharedContext().downloads.first?.songNum == cloud.songNum
        if downloading {
            statusLabel.text = "下载中"
        } else if waiting {
            statusLabel.text = "等待下载"
        } else {
            statusLabel.text = "未下载"
        }
        
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return collectionView.bounds.size
        }
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return CGSize(width: 256, height: 102)
        }
        return CGSize(width: 256/1024*self.view.bounds.width, height: collectionView.bounds.size.height/2 - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return 0
        }
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return 30
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let payload = TCSocketPayload()
        
        let clouds = self.clouds[page]
        let cloud = clouds![indexPath.row]
        payload.cmdType = 1005
        payload.cmdContent = cloud.songNum
        TCContext.sharedContext().socketManager.sendPayload(payload)

        let download = TCKTVDownload()
        download.songNum = cloud.songNum
        download.songName = cloud.songName
        download.singer = cloud.singer
        TCContext.sharedContext().downloads.append(download)
        let cell = collectionView.cellForItem(at: indexPath) as! TCKTVSongCell
        let statusLabel = cell.viewWithTag(1) as! UILabel
        statusLabel.text = TCContext.sharedContext().downloads.count == 1 ? "下载中" : "等待下载"
    }
    
    func updatePage(shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        let indexPath = IndexPath(item: self.page - 1, section: 0)
        if shouldSelect && self.collectionView.numberOfItems(inSection: 0) > 0 {
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
        }
    }

    // MARK: - Cell delegate
    func onFirstAction(_ cell: UICollectionViewCell) {
        
    }
    
    func onSecondAction(_ cell: UICollectionViewCell) {
        
    }
    
    func reloadData(_ sender:Notification) {
        self.collectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
