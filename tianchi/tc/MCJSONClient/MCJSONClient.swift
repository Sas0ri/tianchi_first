//
//  MCJSONClient.swift
//  customer
//
//  Created by Sasori on 16/3/21.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit
import SwiftyJSON

class MCJSONResponseSerializer : AFHTTPResponseSerializer {
    
    override init() {
        super.init()
        acceptableContentTypes = ["application/json", "text/json", "plain/text", "text/html"]
    }

    override func responseObject(for response: URLResponse?, data: Data?, error: NSErrorPointer) -> Any? {
        DDLogInfo("json: " + String(data:data!, encoding: .utf8)!)
        do {
            try self.validate(response as? HTTPURLResponse, data: data)
            let json = JSON(data: data!).object
            return json
        } catch {
            DDLogInfo("AFHTTPResponseSerializer Error: " + String(data: data!, encoding: .utf8)!)
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class MCJSONClient: AFHTTPSessionManager {
    
    override init(baseURL url: URL?, sessionConfiguration configuration: URLSessionConfiguration?) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        responseSerializer = MCJSONResponseSerializer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func MCPost(_ path: String!, parameters: [AnyHashable: Any]!, success: ((JSON) -> Void)!, failure: ((NSError?) -> Void)!) {
        _ = self.post(path, parameters: parameters, success: { (dataTask, response) -> Void in
            if let json = response {
                success(JSON(json as AnyObject))
            } else {
                let err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "解析错误"])
                failure(err)

            }
            }) { (dataTask, error) -> Void in
                DDLogError(error.localizedDescription)
                var err:NSError!
                if !AFNetworkReachabilityManager.shared().isReachable {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "网络错误"])
                } else {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "服务器错误"])
                }
                failure(err)
 
        }
    }
    
    func MCGet(_ path: String!, parameters: [AnyHashable: Any]!, success: ((JSON) -> Void)!, failure: ((NSError?) -> Void)!) {
        _ = self.get(path, parameters: parameters, success: { (dataTask, response) -> Void in
            if let json = response {
                success(JSON(json as AnyObject))
            } else {
                let err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "解析错误"])
                failure(err)
                
            }
            }) { (dataTask, error) -> Void in
                DDLogError(error.localizedDescription)
                var err:NSError!
                if !AFNetworkReachabilityManager.shared().isReachable {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "网络错误"])
                } else {
                    err = NSError(domain: "com.tianchi.tc", code: 400, userInfo: [NSLocalizedDescriptionKey: "服务器错误"])
                }
                failure(err)
                
        }

    }
}
