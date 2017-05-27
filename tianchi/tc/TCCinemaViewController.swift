//
//  TCCinemaViewController.swift
//  tc
//
//  Created by Sasori on 16/9/5.
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


class TCCinemaViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var movieDetailView: UIView!
    @IBOutlet weak var filtView: UIView!
    @IBOutlet var filtViewManager: TCCinemaFiltViewManager!

    
    var page:Int = 1
    var client = TCKTVSongClient()
    var songs:[Int: [TCKTVSong]] = [Int: [TCKTVSong]]()
    var totalPage:String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieDetailView.isHidden = true
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
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
    
    func loadData() {
        var limit = 9
        if UI_USER_INTERFACE_IDIOM() == .phone {
            limit = 6
        }
        let page = self.page
        let nextPage = self.page + 1
        self.client.getSongsByName(self.searchBar.text, words: 0, page: self.page, limit:limit) { (songs, totalPage, flag) in
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
        }
        //预加载
        self.client.getSongsByName(self.searchBar.text, words: 0, page: nextPage, limit:limit) { (songs, totalPage, flag) in
            if flag {
                self.songs[nextPage] = songs!
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
        if let songs = self.songs[page] {
            return songs.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            self.page = indexPath.item + 1
            if self.songs[self.page] == nil {
                self.loadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            return
        }
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
        let songs = self.songs[page]
        let song = songs![indexPath.row]
        cell.singerNameLabel.text = song.singer
        cell.songNameLabel.text = song.songName
        cell.singerNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.red : UIColor.white
        cell.songNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.red : UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if collectionView == self.collectionView {
            return
        }
        let page = collectionView.tag + 1
        let cell = collectionView.cellForItem(at: indexPath) as! TCKTVSongCell
        cell.songNameLabel.textColor = UIColor.red
        cell.singerNameLabel.textColor = UIColor.red
        let payload = TCSocketPayload()
        let songs = self.songs[page]
        let song = songs![indexPath.row]
        payload.cmdType = 1003
        payload.cmdContent = song.songNum
        
        TCContext.sharedContext().socketManager.sendPayload(payload)
        if self.searchBar.text?.characters.count > 0 {
            self.searchBar.resignFirstResponder()
            self.searchBar.text = nil
            self.loadData()
        }
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
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movie", for: indexPath)
        let imageView = UIImageView(image: UIImage(named: "ktv_navbar"))
        imageView.contentMode = .scaleAspectFill
        cell.selectedBackgroundView = imageView
        cell.backgroundColor = UIColor.clear
        let label = cell.contentView.viewWithTag(1) as? UILabel
        switch indexPath.row {
        case 0:
            label?.text = "全部电影"
        case 1:
            label?.text = "爱情电影"
        case 2:
            label?.text = "喜剧电影"
        case 3:
            label?.text = "动作电影"
        case 4:
            label?.text = "战争电影"
        case 5:
            label?.text = "科幻电影"
        case 6:
            label?.text = "恐怖电影"
        case 7:
            label?.text = "剧情电影"
        case 8:
            label?.text = "古装电影"
        case 9:
            label?.text = "灾难电影"
        default: break
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.size.height/10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.filtView.isHidden = false
        self.filtViewManager.typeView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.performSegue(withIdentifier: "main2search", sender: self)
        return false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.clearData()
        self.loadData()
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
        self.collectionView.reloadData()
    }

    @IBAction func hideFiltViewAction(_ sender: AnyObject) {
        self.filtView.isHidden = true
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.movieDetailView.isHidden = true
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
