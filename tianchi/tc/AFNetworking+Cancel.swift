//
//  AFNetworking+Cancel.swift
//  tc
//
//  Created by Sasori on 16/8/23.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

extension AFURLSessionManager {
    func cancelAllHTTPOperations(withPath path:String) {
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            self.cancelTasks(inArray: dataTasks, withPath: path)
            self.cancelTasks(inArray: uploadTasks, withPath: path)
            self.cancelTasks(inArray: downloadTasks, withPath: path)
        }
    }
    
    func cancelTasks(inArray taskArray:[URLSessionTask], withPath path:String) {
        for dataTask in taskArray {
            if let _ = dataTask.currentRequest?.url?.absoluteString.range(of: path) {
                dataTask.cancel()
            }
        }
    }
}
