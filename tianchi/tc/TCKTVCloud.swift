//
//  TCKTVCloud.swift
//  tc
//
//  Created by Sasori on 16/6/21.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit
import SwiftyJSON

class TCKTVCloud: NSObject {
    var songId:Int64 = 0
    var songNum:Int = 0
    /** Not-null value. */
    var songName:String = ""
    /** Not-null value. */
    var singer:String = ""
    
    func config(_ json:JSON) {
        self.songId = json["songId"].int64Value
        self.songNum = json["songNum"].intValue
        self.songName = json["songName"].stringValue
        self.singer = json["singer"].stringValue
    }
}
