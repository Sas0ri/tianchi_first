//
//  TCKTVSinger.swift
//  tc
//
//  Created by Sasori on 16/6/21.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit
import SwiftyJSON

class TCKTVSinger: NSObject {
    var singerId:Int64 = 0
    /** Not-null value. */
    var singerName:String = ""

    func config(_ json:JSON) {
        self.singerId = json["singerId"].int64Value
        self.singerName = json["singerName"].stringValue
    }
}
