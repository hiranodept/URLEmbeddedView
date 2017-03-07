//
//  OGImageCacheManager.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

/*
 * In this file, CommonCrypto is used to create md5 hash.
 * CommonCrypto is created by Marcin Krzyżanowski.
 * https://github.com/krzyzanowskim/CryptoSwift
 * The original copyright is here.
 */

/*
 * Copyright (C) 2014 Marcin Krzyżanowski marcin.krzyzanowski@gmail.com
 * This software is provided 'as-is', without any express or implied warranty.
 *
 * In no event will the authors be held liable for any damages arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 *
 * - The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
 *   If you use this software in a product, an acknowledgment in the product documentation is required.
 * - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * - This notice may not be removed or altered from any source or binary distribution.
 */

import UIKit

class OGImageCacheManager {
    static let sharedInstance = OGImageCacheManager()
    
    fileprivate struct Const {
        static let timeOfExpirationForOGImageCacheKey = "TimeOfExpirationForOGImageCache"
    }
        
    fileprivate let fileManager = FileManager()
    fileprivate lazy var memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 30
        return cache
    }()
    fileprivate lazy var cacheDirectory: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return (paths[paths.count-1] as NSString).appendingPathComponent("images")
    }()
    
//    var timeOfExpiration: NSTimeInterval {
//        get {
//            let ud = NSUserDefaults.standardUserDefaults()
//            return ud.doubleForKey(Const.timeOfExpirationForOGImageCacheKey)
//        }
//        set {
//            let ud = NSUserDefaults.standardUserDefaults()
//            ud.setDouble(newValue, forKey: Const.timeOfExpirationForOGImageCacheKey)
//            ud.synchronize()
//        }
//    }
    
    fileprivate init() {
        createDirectoriesIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).didReceiveMemoryWarning(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    dynamic func didReceiveMemoryWarning(_ notification: Notification) {
        clearMemoryCache()
    }
}

//MARK: - Create directories
extension OGImageCacheManager {
    fileprivate func createDirectoriesIfNeeded() {
        createRootDirectoryIfNeeded()
        createSubDirectoriesIfNeeded()
    }
    
    fileprivate func createRootDirectoryIfNeeded() {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: cacheDirectory, isDirectory: &isDirectory)
        if exists && isDirectory.boolValue { return }
        do {
            try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {}
    }
    
    fileprivate func createSubDirectoriesIfNeeded() {
        for i in 0..<16 {
            for j in 0..<16 {
                let directoryName = String(format: "%@/%x%x", self.cacheDirectory, i, j)
                var isDirectory: ObjCBool = false
                let exists = fileManager.fileExists(atPath: directoryName, isDirectory: &isDirectory)
                if exists && isDirectory.boolValue { continue }
                do {
                    try fileManager.createDirectory(atPath: directoryName, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    continue
                }
            }
        }
    }
}

//MARK: - Read and write
extension OGImageCacheManager {
    fileprivate func pathForURLString(_ urlString: String) -> String {
        let md5String = md5(urlString)
        if md5String.characters.count < 2 { return cacheDirectory + "/" }
        return cacheDirectory + "/" +  md5String.substring(to: md5String.characters.index(md5String.startIndex, offsetBy: 2)) + "/" + md5String
    }
    
    func cachedImage(urlString: String) -> UIImage? {
        if let image = memoryCache.object(forKey: urlString as NSString) {
            return image
        }
        if let image = UIImage(contentsOfFile: pathForURLString(urlString)) {
            memoryCache.setObject(image, forKey: urlString as NSString)
            return image
        }
        return nil
    }
    
    func storeImage(_ image: UIImage, data: Data, urlString: String) {
        memoryCache.setObject(image, forKey: urlString as NSString)
        try? data.write(to: URL(fileURLWithPath: pathForURLString(urlString)), options: [])
    }
}

//MARK: - Cache clear
extension OGImageCacheManager {
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    func clearAllCache() {
        clearMemoryCache()
        if !fileManager.fileExists(atPath: cacheDirectory) {
            createDirectoriesIfNeeded()
            return
        }
        do {
            try fileManager.removeItem(atPath: cacheDirectory)
            createDirectoriesIfNeeded()
        } catch {}
    }
}

//MARK: - MD5
/* （メモ）
 * Bridging-Header.hに
 * #import <CommonCrypto/CommonDigest.h>
 * を書いておく。
 */
extension OGImageCacheManager {
        func md5(_ string: String) -> String {
        var md5String = ""
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
        
        if let data = string.data(using: .utf8) {
            data.withUnsafeBytes({ (bytes: UnsafePointer<CChar>) -> Void in
                CC_MD5(bytes, CC_LONG(data.count), md5Buffer)
                md5String = (0..<digestLength).reduce("") { $0 + String(format:"%02x", md5Buffer[$1]) }
            })
        }
        
        return md5String
    }
}
