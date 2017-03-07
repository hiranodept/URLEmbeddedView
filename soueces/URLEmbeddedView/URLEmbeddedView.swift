//
//  URLEmbeddedView.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/06.
//
//

import UIKit
import MisterFusion

open class URLEmbeddedView: UIView {
    fileprivate typealias ATP = AttributedTextProvider
    //MARK: - Static constants
    fileprivate struct Const {
        static let faviconURL = "http://www.google.com/s2/favicons?domain="
    }
    
    //MARK: - Properties
    fileprivate let alphaView = UIView()
    
    let imageView = URLImageView()
    fileprivate var imageViewWidthConstraint: NSLayoutConstraint?
    
    fileprivate let titleLabel = UILabel()
    fileprivate var titleLabelHeightConstraint: NSLayoutConstraint?
    fileprivate let descriptionLabel = UILabel()
    
    fileprivate let domainConainter = UIView()
    fileprivate var domainContainerHeightConstraint: NSLayoutConstraint?
    fileprivate let domainLabel = UILabel()
    fileprivate let domainImageView = URLImageView()
    fileprivate var domainImageViewToDomainLabelConstraint: NSLayoutConstraint?
    fileprivate var domainImageViewWidthConstraint: NSLayoutConstraint?
    
    fileprivate let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate lazy var linkIconView: LinkIconView = {
        return LinkIconView(frame: self.bounds)
    }()
    
    fileprivate var URL: Foundation.URL?
    fileprivate var uuidString: String?
    open let textProvider = AttributedTextProvider.sharedInstance
    
    open var didTapHandler: ((URLEmbeddedView, Foundation.URL?) -> Void)?
    open var stopTaskWhenCancel = false {
        didSet {
            domainImageView.stopTaskWhenCancel = stopTaskWhenCancel
            imageView.stopTaskWhenCancel = stopTaskWhenCancel
        }
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setInitialiValues()
        configureViews()
    }
    
    public convenience init(url: String) {
        self.init(url: url, frame: .zero)
    }
    
    public init(url: String, frame: CGRect) {
        super.init(frame: frame)
        URL = Foundation.URL(string: url)
        setInitialiValues()
        configureViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setInitialiValues()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        configureViews()
    }
    
    open func prepareViewsForReuse() {
        cancelLoad()
        imageView.image = nil
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        domainLabel.attributedText = nil
        domainImageView.image = nil
        linkIconView.isHidden = true
    }
    
    fileprivate func setInitialiValues() {
        borderColor = .lightGray
        borderWidth = 1
        cornerRaidus = 8
    }
    
    fileprivate func configureViews() {
        setNeedsDisplay()
        layoutIfNeeded()
        
        textProvider.didChangeValue = { [weak self] style, attribute, value in
            self?.handleTextProviderChanged(style, attribute: attribute, value: value)
        }
        
        addLayoutSubview(linkIconView, andConstraints:
            linkIconView.top,
            linkIconView.left,
            linkIconView.bottom,
            linkIconView.width |==| linkIconView.height
        )
        linkIconView.clipsToBounds = true
        linkIconView.isHidden = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addLayoutSubview(imageView, andConstraints:
            imageView.top,
            imageView.left,
            imageView.bottom
        )
        changeImageViewWidthConstrain(nil)
        
        titleLabel.numberOfLines = textProvider[.title].numberOfLines
        addLayoutSubview(titleLabel, andConstraints:
            titleLabel.top    |+| 8,
            titleLabel.right  |-| 12,
            titleLabel.left   |==| imageView.right |+| 12
        )
        changeTitleLabelHeightConstraint()
        
        addLayoutSubview(domainConainter, andConstraints:
            domainConainter.right  |-| 12,
            domainConainter.bottom |-| 10,
            domainConainter.left   |==| imageView.right |+| 12
        )
        changeDomainContainerHeightConstraint()
        
        descriptionLabel.numberOfLines = textProvider[.description].numberOfLines
        addLayoutSubview(descriptionLabel, andConstraints:
            descriptionLabel.right  |-| 12,
            descriptionLabel.height |>=| 0,
            descriptionLabel.top    |==| titleLabel.bottom   |+| 2,
            descriptionLabel.bottom |<=| domainConainter.top |+| 4,
            descriptionLabel.left   |==| imageView.right     |+| 12
        )
        
        domainImageView.activityViewHidden = true
        domainConainter.addLayoutSubview(domainImageView, andConstraints:
            domainImageView.top,
            domainImageView.left,
            domainImageView.bottom
        )
        changeDomainImageViewWidthConstraint(nil)
        
        domainLabel.numberOfLines = textProvider[.domain].numberOfLines
        domainConainter.addLayoutSubview(domainLabel, andConstraints:
            domainLabel.top,
            domainLabel.right,
            domainLabel.bottom
        )
        changeDomainImageViewToDomainLabelConstraint(nil)
        
        activityView.hidesWhenStopped = true
        addLayoutSubview(activityView, andConstraints:
            activityView.centerX,
            activityView.centerY,
            activityView.width  |==| 30,
            activityView.height |==| 30
        )
        
        alphaView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        alphaView.alpha = 0
        addLayoutSubview(alphaView, andConstraints:
            alphaView.top,
            alphaView.right,
            alphaView.bottom,
            alphaView.left
        )
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alphaView.alpha = 1
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        alphaView.alpha = 0
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alphaView.alpha = 0
        didTapHandler?(self, URL)
    }
}

extension URLEmbeddedView {
    fileprivate func changeImageViewWidthConstrain(_ constant: CGFloat?) {
        if let constraint = imageViewWidthConstraint {
            removeConstraint(constraint)
        }
        let misterFusion: MisterFusion
        if let constant = constant {
            misterFusion = imageView.width |==| constant
        } else {
            misterFusion = imageView.width |==| imageView.height
        }
        imageViewWidthConstraint = addLayoutConstraint(misterFusion)
    }
    
    fileprivate func changeDomainImageViewWidthConstraint(_ constant: CGFloat?) {
        if let constraint = domainImageViewWidthConstraint {
            removeConstraint(constraint)
        }
        let misterFusion: MisterFusion
        if let constant = constant {
            misterFusion = domainImageView.width |==| constant
        } else {
            misterFusion = domainImageView.width |==| domainConainter.height
        }
        domainImageViewWidthConstraint = addLayoutConstraint(misterFusion)
    }
    
    fileprivate func changeDomainImageViewToDomainLabelConstraint(_ constant: CGFloat?) {
        let constant = constant ?? (textProvider[.domain].font.lineHeight / 5)
        if let constraint = domainImageViewToDomainLabelConstraint {
            if constant == constraint.constant { return }
            removeConstraint(constraint)
        }
        let misterFusion = domainLabel.left |==| domainImageView.right |+| constant
        domainImageViewToDomainLabelConstraint = addLayoutConstraint(misterFusion)
    }
    
    fileprivate func changeTitleLabelHeightConstraint() {
        let constant = textProvider[.title].font.lineHeight
        if let constraint = titleLabelHeightConstraint {
            if constant == constraint.constant { return }
            removeConstraint(constraint)
        }
        titleLabelHeightConstraint = addLayoutConstraint(titleLabel.height |>=| constant)
    }
    
    fileprivate func changeDomainContainerHeightConstraint() {
        let constant = textProvider[.domain].font.lineHeight
        if let constraint = domainContainerHeightConstraint {
            if constant == constraint.constant { return }
            removeConstraint(constraint)
        }
        domainContainerHeightConstraint = addLayoutConstraint(domainConainter.height |==| constant)
    }
}

extension URLEmbeddedView {
    fileprivate func handleTextProviderChanged(_ style: AttributeManager.Style, attribute: AttributeManager.Attribute, value: Any) {
        switch style {
        case .title:       didChangeTitleAttirbute(attribute, value: value)
        case .domain:      didChangeDomainAttirbute(attribute, value: value)
        case .description: didChangeDescriptionAttirbute(attribute, value: value)
        case .noDataTitle: didChangeNoDataTitleAttirbute(attribute, value: value)
        }
    }
    
    fileprivate func didChangeTitleAttirbute(_ attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .font: changeDomainContainerHeightConstraint()
        case .fontColor: break
        case .numberOfLines: break
        }
    }
    
    fileprivate func didChangeDomainAttirbute(_ attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .font: changeDomainContainerHeightConstraint()
        case .fontColor: break
        case .numberOfLines: break
        }
    }
    
    fileprivate func didChangeDescriptionAttirbute(_ attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .font: break
        case .fontColor: break
        case .numberOfLines: break
        }
    }
    
    fileprivate func didChangeNoDataTitleAttirbute(_ attribute: AttributeManager.Attribute, value: Any) {
        switch attribute {
        case .font: changeTitleLabelHeightConstraint()
        case .fontColor: break
        case .numberOfLines: break
        }
    }
}

extension URLEmbeddedView {
    public func loadURL(_ urlString: String, completion: ((NSError?) -> Void)? = nil) {
        guard let URL = Foundation.URL(string: urlString) else {
            completion?(nil)
            return
        }
        self.URL = URL
        load(completion)
    }
    
    public func load(_ completion: ((NSError?) -> Void)? = nil) {
        guard let URL = URL else { return }
        prepareViewsForReuse()
        activityView.startAnimating()
        uuidString = OGDataProvider.sharedInstance.fetchOGData(urlString: URL.absoluteString) { [weak self] ogData, error in
            DispatchQueue.main.async {
                self?.activityView.stopAnimating()
                if let error = error {
                    self?.imageView.image = nil
                    self?.titleLabel.attributedText = self?.textProvider[.noDataTitle].attributedText(URL.absoluteString)
                    self?.descriptionLabel.attributedText = nil
                    self?.domainLabel.attributedText = self?.textProvider[.domain].attributedText(URL.host ?? "")
                    self?.changeDomainImageViewWidthConstraint(0)
                    self?.changeDomainImageViewToDomainLabelConstraint(0)
                    self?.changeImageViewWidthConstrain(nil)
                    self?.linkIconView.isHidden = false
                    self?.layoutIfNeeded()
                    completion?(error)
                    return
                }
                
                self?.linkIconView.isHidden = true
                if ogData.pageTitle.isEmpty {
                    self?.titleLabel.attributedText = self?.textProvider[.noDataTitle].attributedText(URL.absoluteString)
                } else {
                    self?.titleLabel.attributedText = self?.textProvider[.title].attributedText(ogData.pageTitle)
                }
                self?.descriptionLabel.attributedText = self?.textProvider[.description].attributedText(ogData.pageDescription)
                if !ogData.imageUrl.isEmpty {
                    self?.imageView.loadImage(urlString: ogData.imageUrl) {
                        if let _ = $0 , $1 == nil {
                            self?.changeImageViewWidthConstrain(nil)
                        } else {
                            self?.changeImageViewWidthConstrain(0)
                        }
                        self?.layoutIfNeeded()
                    }
                } else {
                    self?.changeImageViewWidthConstrain(0)
                    self?.imageView.image = nil
                }
                let host = URL.host ?? ""
                self?.domainLabel.attributedText = self?.textProvider[.domain].attributedText(host)
                let faciconURL = Const.faviconURL + host
                self?.domainImageView.loadImage(urlString: faciconURL) {
                    if let _ = $0 , $1 == nil {
                        self?.changeDomainImageViewWidthConstraint(nil)
                        self?.changeDomainImageViewToDomainLabelConstraint(nil)
                    } else {
                        self?.changeDomainImageViewWidthConstraint(0)
                        self?.changeDomainImageViewToDomainLabelConstraint(0)
                    }
                    self?.layoutIfNeeded()
                }
                self?.layoutIfNeeded()
                completion?(nil)
            }
        }
    }
    
    public func cancelLoad() {
        domainImageView.cancelLoadImage()
        imageView.cancelLoadImage()
        activityView.stopAnimating()
        guard let uuidString = uuidString else { return }
        OGDataProvider.sharedInstance.cancelLoad(uuidString, stopTask: stopTaskWhenCancel)
    }
}
