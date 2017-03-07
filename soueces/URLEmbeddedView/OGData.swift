//
//  OGData.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/11.
//
//

import Foundation
import CoreData

public final class OGData: NSManagedObject {
    fileprivate enum PropertyName: String {
        case description = "og:description"
        case image       = "og:image"
        case siteName    = "og:site_name"
        case title       = "og:title"
        case type        = "og:type"
        case url         = "og:url"
    }
    
    fileprivate lazy var URL: Foundation.URL? = {
        return Foundation.URL(string: self.sourceUrl)
    }()

    class func fetchOrInsertOGData(url: String) -> OGData {
        guard let ogData = fetchOGData(url: url) else {
            let managedObjectContext = OGDataCacheManager.sharedInstance.updateManagedObjectContext
            let newOGData = NSEntityDescription.insertNewObject(forEntityName: "OGData", into: managedObjectContext) as! OGData
            let date = Date()
            newOGData.createDate = date
            newOGData.updateDate = date
            return newOGData
        }
        return ogData
    }
    
    class func fetchOGData(url: String) -> OGData? {
        let managedObjectContext = OGDataCacheManager.sharedInstance.updateManagedObjectContext
        let fetchRequest = NSFetchRequest<OGData>()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "OGData", in: managedObjectContext)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "sourceUrl = %@", url)
        let fetchedList = (try? managedObjectContext.fetch(fetchRequest))
        return fetchedList?.first
    }
    
    func setValue(property: String, content: String) {
        guard let propertyName = PropertyName(rawValue: property) else { return }
        switch propertyName  {
        case .siteName    : siteName        = content
        case .type        : pageType        = content
        case .title       : pageTitle       = content
        case .image       : imageUrl        = content
        case .url         : url             = content
        case .description : pageDescription = content.replacingOccurrences(of: "\n", with: " ")
        }
    }
    
    func save() {
        updateDate = Date()
        OGDataCacheManager.sharedInstance.saveContext(nil)
    }
}
