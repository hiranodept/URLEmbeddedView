//
//  TaskContainable.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/16.
//
//

import Foundation

protocol TaskContainable {
    associatedtype Completion
    
    var uuidString: String { get }
    var task: URLSessionDataTask { get }
    var completion: Completion? { get set }
    
    init(uuidString: String, task: URLSessionDataTask, completion: Completion?)
}
