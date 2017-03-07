//
//  OGImageProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

private class TaskContainer: TaskContainable {
    typealias Completion = ((UIImage?, NSError?) -> Void)
    
    let uuidString: String
    let task: URLSessionDataTask
    var completion: Completion?
    
    required init(uuidString: String, task: URLSessionDataTask, completion: Completion?) {
        self.uuidString = uuidString
        self.task = task
        self.completion = completion
    }
}

public final class OGImageProvider: NSObject {
    
    //MARK: - Static constants
    public static let sharedInstance = OGImageProvider()
    
    //MARK: - Properties
    fileprivate let session = URLSession(configuration: URLSessionConfiguration.default)
    fileprivate var taskContainers: [String : TaskContainer] = [:]
    
    fileprivate override init() {
        super.init()
    }
}

extension OGImageProvider {
    public func loadImage(urlString: String, completion: ((UIImage?, NSError?) -> Void)? = nil) -> String? {
        guard let URL = URL(string: urlString) else {
            completion?(nil, NSError(domain: "can not create NSURL with \(urlString)", code: 9999, userInfo: nil))
            return nil
        }
        if !urlString.isEmpty {
            if let image = OGImageCacheManager.sharedInstance.cachedImage(urlString: urlString) {
                completion?(image, nil)
                return nil
            }
        }
        let uuidString = UUID().uuidString
        let task = session.dataTask(with: URL) { [weak self] data, response, error in
            let completion = self?.taskContainers[uuidString]?.completion
            self?.taskContainers.removeValue(forKey: uuidString)
            
            if let error = error {
                completion?(nil,  error as NSError?)
                return
            }
            guard let data = data else {
                completion?(nil, NSError(domain: "can not fetch image data with \(urlString)", code: 9999, userInfo: nil))
                return
            }
            guard let image = UIImage(data: data) else {
                completion?(nil, NSError(domain: "can not fetch image with \(urlString)", code: 9999, userInfo: nil))
                return
            }
            OGImageCacheManager.sharedInstance.storeImage(image, data: data, urlString: urlString)
            
            completion?(image, nil)
        }
        taskContainers[uuidString] = TaskContainer(uuidString: uuidString, task: task, completion: completion)
        task.resume()
        return uuidString
    }
    
    public func clearMemoryCache() {
        OGImageCacheManager.sharedInstance.clearMemoryCache()
    }
    
    public func clearAllCache() {
        OGImageCacheManager.sharedInstance.clearAllCache()
    }
    
    func cancelLoad(_ uuidString: String, stopTask: Bool) {
       taskContainers[uuidString]?.completion = nil
        if stopTask {
            taskContainers[uuidString]?.task.cancel()
        }
        taskContainers.removeValue(forKey: uuidString)
    }
}
