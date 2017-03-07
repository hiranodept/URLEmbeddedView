//
//  AttributedTextProvider.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/07.
//
//

import Foundation

public final class AttributedTextProvider {
    static let sharedInstance = AttributedTextProvider()
    
    fileprivate let TitleAttributeManager       = AttributeManager(style: .title)
    fileprivate let DomainAttributeManager      = AttributeManager(style: .domain)
    fileprivate let DescriptionAttributeManager = AttributeManager(style: .description)
    fileprivate let NoDataTitleAttributeManager = AttributeManager(style: .noDataTitle)
    
    var didChangeValue: ((AttributeManager.Style, AttributeManager.Attribute, Any) -> Void)?
    
    fileprivate init() {
        self[.title].didChangeValue       = { [weak self] in self?.didChangeValue?($0, $1, $2) }
        self[.domain].didChangeValue      = { [weak self] in self?.didChangeValue?($0, $1, $2) }
        self[.description].didChangeValue = { [weak self] in self?.didChangeValue?($0, $1, $2) }
        self[.noDataTitle].didChangeValue = { [weak self] in self?.didChangeValue?($0, $1, $2) }
    }
    
    public subscript(style: AttributeManager.Style) -> AttributeManager {
        switch style {
        case .title       : return TitleAttributeManager
        case .domain      : return DomainAttributeManager
        case .description : return DescriptionAttributeManager
        case .noDataTitle : return NoDataTitleAttributeManager
        }
    }
    
    func didChangeValue(_ closure: ((AttributeManager.Style, AttributeManager.Attribute, Any) -> Void)?) {
        self[.title].didChangeValue       = { closure?($0, $1, $2) }
        self[.domain].didChangeValue      = { closure?($0, $1, $2) }
        self[.description].didChangeValue = { closure?($0, $1, $2) }
        self[.noDataTitle].didChangeValue = { closure?($0, $1, $2) }
    }
}

