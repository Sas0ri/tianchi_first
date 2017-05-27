//
//  TCKTVSongsViewController.swift
//  tc
//
//  Created by Sasori on 16/6/20.
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TCKTVSongsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,TCKTVSongCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var singer:String?
    var language:TCKTVLanguage?
    var category:String?
    var ranking:Bool = false
    var cloud:Bool = false
    var download:Bool = false
    var ordered:Bool = false
    
    var page:Int = 1
    var client = TCKTVSongClient()
    var songs:[Int: [TCKTVSong]] = [Int: [TCKTVSong]]()
    var clouds:[Int: [TCKTVCloud]] = [Int: [TCKTVCloud]]()
    var ordereds:[TCKTVPoint] = [TCKTVPoint]()
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
        self.segmentedControl.selectedSegmentIndex = 0
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
        if self.download || self.cloud {
            NotificationCenter.default.addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: NSNotification.Name(rawValue: TCKTVDownloadLoadedNotification), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: NSNotification.Name(rawValue: TCKTVDownloadUpdatedNotification), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: NSNotification.Name(rawValue: TCKTVDownloadRemovedNotification), object: nil)
        }
        if self.ordered {
            NotificationCenter.default.addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: NSNotification.Name(rawValue: TCKTVOrderedUpdatedNotification), object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.ordered {
            self.page = 1
            self.loadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segChanged(_ sender: AnyObject) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.clearData()
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
        self.clearData()
        self.loadData()
    }
    
    func loadData() {
        let limit = self.getLimit()
        let page = self.page
        let nextPage = self.page + 1
        if self.singer != nil {
            self.client.getSongsBySinger(self.searchBar.text, singer: self.singer!, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }

        if self.language != nil {
            self.client.getSongsByLanguage(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, language: self.language!.rawValue, page: self.page, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
                self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            })
        }
        
        if self.category != nil {
            self.client.getSongsByCategory(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, type: self.category!, page: self.page, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.ranking {
            self.client.getRankingSongs(self.searchBar.text, page: self.page, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.download {
            self.totalPage = "\(TCContext.sharedContext().downloads.count%limit == 0 ? TCContext.sharedContext().downloads.count/limit : TCContext.sharedContext().downloads.count/limit + 1)"
            if self.page > Int(self.totalPage) {
                self.page = Int(self.totalPage)!
            }
            self.updatePage(shouldSelect: true)
            self.collectionView.reloadData()
        }
        if self.cloud {
            self.client.getCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, complete: { (clouds, totalPage, flag) in
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
            })
        }
        if self.ordered {
            self.client.getOrderedSongs({ (ordereds, flag) in
                if flag {
                    self.ordereds = ordereds!
                    self.collectionView.reloadData()
                    self.totalPage = "\(self.ordereds.count%limit == 0 ? self.ordereds.count/limit : self.ordereds.count/limit + 1)"
                    if self.page > Int(self.totalPage) {
                        self.page = Int(self.totalPage)!
                    }
                    self.updatePage(shouldSelect: true)
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.page == 1 {
            self.updatePage(shouldSelect: false)
        }
        //预加载
        if self.singer != nil {
            self.client.getSongsBySinger(nil, singer: self.singer!, words: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
        
        if self.language != nil {
            self.client.getSongsByLanguage(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, language: self.language!.rawValue, page: nextPage, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
        
        if self.category != nil {
            self.client.getSongsByCategory(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, type: self.category!, page: nextPage, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
        if self.ranking {
            self.client.getRankingSongs(nil, page: nextPage, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
       
        if self.cloud {
            self.client.getCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit, complete: { (clouds, totalPage, flag) in
                if flag {
                    self.clouds[nextPage] = clouds!
                }
            })
        }
    }
    
    func hasOrdered(_ songNum:Int) -> Bool {
        for order in self.ordereds {
            if songNum == order.songNum {
                return true
            }
        }
        return false
    }
    
    @IBAction func prePage(_ sender: AnyObject) {
        if self.page == 1 {
            return
        }
        self.page = self.page - 1
        self.updatePage(shouldSelect: true)
        if self.ordered || self.download {
            self.collectionView.reloadData()
            self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            return
        }
        self.loadData()
    }
    
    @IBAction func nextPage(_ sender: AnyObject) {
        if Int(self.totalPage) < self.page + 1 {
            return
        }
        self.page = self.page + 1
        self.updatePage(shouldSelect: true)
        if self.ordered || self.download {
            self.collectionView.reloadData()
            self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            return
        }
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
        let limit = self.getLimit()
        let page = collectionView.tag + 1
        if self.cloud {
            if let clouds = self.clouds[page] {
                return clouds.count
            }
            return 0
        }
        if self.download {
            let count = page * limit
            if TCContext.sharedContext().downloads.count >= count {
                return limit
            }
            return TCContext.sharedContext().downloads.count%limit
        }
        if self.ordered {
            let count = page * limit
            if self.ordereds.count >= count {
                return limit
            }
            return self.ordereds.count%limit
        }
        if let songs = self.songs[page] {
            return songs.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            self.page = indexPath.row + 1
            if self.cloud {
                if self.clouds[self.page] == nil {
                    self.loadData()
                }
                return
            }
            if self.download {
                return
            }
            if self.ordered {
                return
            }
            if self.songs[self.page] == nil {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "song", for: indexPath) as! TCKTVSongCell
        let page = collectionView.tag + 1
        if self.cloud {
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
        } else if self.download {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath.row
            let download = TCContext.sharedContext().downloads[index]
            cell.singerNameLabel.text = download.singer
            cell.songNameLabel.text = download.songName
            let statusLabel = cell.viewWithTag(1) as! UILabel
            let downloading = TCContext.sharedContext().downloads.first
            statusLabel.text = downloading?.songNum == download.songNum ? "下载中" : "等待下载"
        } else if self.ordered {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath.row
            let ordered = self.ordereds[index]
            cell.singerNameLabel.text = ordered.singer
            cell.songNameLabel.text = ordered.songName
            let btn1 = cell.contentView.viewWithTag(1)
            let btn2 = cell.contentView.viewWithTag(2)
            let label = cell.contentView.viewWithTag(3)
            btn1?.isHidden = index == 0
            btn2?.isHidden = btn1!.isHidden
            label?.isHidden = !btn1!.isHidden
        } else {
            let songs = self.songs[page]
            let song = songs![indexPath.row]
            cell.singerNameLabel.text = song.singer
            cell.songNameLabel.text = song.songName
            cell.songNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.red : UIColor.white
            cell.singerNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.red : UIColor.white
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
        if collectionView == self.collectionView {
            return
        }
        let cell = collectionView.cellForItem(at: indexPath) as! TCKTVSongCell
        let collectionView = cell.superview as! UICollectionView
        let page = collectionView.tag + 1
        let payload = TCSocketPayload()
        if self.cloud {
            let clouds = self.clouds[page]
            let cloud = clouds![indexPath.row]
            payload.cmdType = 1005
            payload.cmdContent = cloud.songNum
            
            let download = TCKTVDownload()
            download.songNum = cloud.songNum
            download.songName = cloud.songName
            download.singer = cloud.singer
            TCContext.sharedContext().downloads.append(download)
            let statusLabel = cell.viewWithTag(1) as! UILabel
            statusLabel.text = TCContext.sharedContext().downloads.count == 1 ? "下载中" : "等待下载"
        } else if self.download {
            
        } else if self.ordered {
    
        } else {
            let songs = self.songs[page]
            let song = songs![indexPath.row]
            payload.cmdType = 1003
            payload.cmdContent = song.songNum
            
            let cell = collectionView.cellForItem(at: indexPath) as! TCKTVSongCell
            cell.songNameLabel.textColor = UIColor.red
            cell.singerNameLabel.textColor = UIColor.red
        }
  
        if self.searchBar.text?.characters.count > 0 {
            self.searchBar.resignFirstResponder()
            self.searchBar.text = nil
            self.loadData()
        }
        if payload.cmdType == 0 {
            return
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    

    // MARK: - Cell delegate
    func onFirstAction(_ cell: UICollectionViewCell) {
        let collectionView = cell.superview as! UICollectionView
        let page = collectionView.tag + 1
        let payload = TCSocketPayload()
        let indexPath = collectionView.indexPath(for: cell)
        let limit = self.getLimit()
        let index = (page - 1) * limit + indexPath!.row

        if self.language != nil {
            let songsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ktv_songs") as! TCKTVSongsViewController
            let collectionView = cell.superview as! UICollectionView
            let indexPath = collectionView.indexPath(for: cell)
            let page = collectionView.tag + 1
            let songs = self.songs[page]
            let song = songs![indexPath!.row]
            songsVC.singer = song.singer
            self.navigationController?.pushViewController(songsVC, animated: false)
        } else if self.ordered {
            let ordered = self.ordereds[index]
            payload.cmdType = 1002
            payload.cmdContent = ordered.songNum
            self.ordereds.remove(at: index)
            self.collectionView.reloadData()
            let totalPage = self.ordereds.count%limit == 0 ? self.ordereds.count/limit : self.ordereds.count/limit + 1
            if self.page > totalPage {
                self.page = totalPage
            }
            self.totalPage = "\(totalPage)"
            self.updatePage(shouldSelect: false)
        } else if self.download {
          let download = TCContext.sharedContext().downloads[index]
            payload.cmdType = 1008
            payload.cmdContent = download.songNum
            
            TCContext.sharedContext().downloads.remove(at: index)
            self.collectionView.reloadData()
            
            let totalPage = TCContext.sharedContext().downloads.count%limit == 0 ? TCContext.sharedContext().downloads.count/limit : TCContext.sharedContext().downloads.count/limit + 1
            if self.page > totalPage {
                self.page = totalPage
            }
            self.totalPage = "\(totalPage)"
            self.updatePage(shouldSelect: false)
        } else if self.ranking {
            let songsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ktv_songs") as! TCKTVSongsViewController
            let songs = self.songs[page]
            let song = songs![indexPath!.row]
            songsVC.singer = song.singer
            self.navigationController?.pushViewController(songsVC, animated: false)
        } else {
            let songs = self.songs[page]
            let song = songs![indexPath!.row]
            payload.cmdType = 1004
            payload.cmdContent = song.songNum
            
            let c = cell as! TCKTVSongCell
            c.songNameLabel.textColor = UIColor.red
            c.singerNameLabel.textColor = UIColor.red
        }
        if payload.cmdType == 0 {
            return
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func onSecondAction(_ cell: UICollectionViewCell) {
        let collectionView = cell.superview as! UICollectionView
        let page = collectionView.tag + 1

        let payload = TCSocketPayload()
        let indexPath = collectionView.indexPath(for: cell)
        let limit = self.getLimit()
        let index = (self.page - 1) * limit + indexPath!.row

        if self.cloud {
           
        } else if self.download {
        } else if self.ordered {
            let ordered = self.ordereds.remove(at: index)
            self.ordereds.insert(ordered, at: 1)
            self.collectionView.reloadData()
            payload.cmdType = 1001
            payload.cmdContent = ordered.songNum
        } else {
            let songs = self.songs[page]
            let song = songs![indexPath!.row]
            payload.cmdType = 1004
            payload.cmdContent = song.songNum
            
            let c = cell as! TCKTVSongCell
            c.songNameLabel.textColor = UIColor.red
            c.singerNameLabel.textColor = UIColor.red
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func reloadData(_ sender:Notification) {
        self.loadData()
        self.collectionView.reloadData()
    }
    
    func getLimit() -> Int {
        var limit = 9
        if UI_USER_INTERFACE_IDIOM() == .phone {
            limit = 6
        }
        return limit
    }
    
    func updatePage(shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        let indexPath = IndexPath(item: self.page - 1, section: 0)
        if shouldSelect && self.collectionView.numberOfItems(inSection: 0) > 0 {
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
        }
    }
    
    func clearData() {
        self.songs.removeAll()
        self.clouds.removeAll()
        self.collectionView.reloadData()
    }
    
    deinit {
        if self.download {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: TCKTVCloudSearchViewController.self) {
            let vc = segue.destination as! TCKTVCloudSearchViewController
            vc.singer = self.singer
            vc.language = self.language
            vc.category = self.category
            vc.searchText = self.searchBar.text
            vc.words = self.segmentedControl.selectedSegmentIndex
        }
    }
    

}
