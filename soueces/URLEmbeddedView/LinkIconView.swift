//
//  LinkIconView.swift
//  URLEmbeddedView
//
//  Created by Taiki Suzuki on 2016/03/10.
//
//

import UIKit

final class LinkIconView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let pdfPage = loadPdf()
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()
        let boxRect = pdfPage!.getBoxRect(.mediaBox)
        let xScale = bounds.size.width / boxRect.size.width
        let yScale = bounds.size.height / boxRect.size.height
        let scale = xScale < yScale ? xScale : yScale
        context!.translateBy(x: 0.0, y: boxRect.size.height * yScale)
        context!.scaleBy(x: scale, y: -scale);
        context!.drawPDFPage(pdfPage!);
        context!.restoreGState()
    }
    
    fileprivate func loadPdf() -> CGPDFPage? {
        let pdfURL = Bundle(for: type(of: self)).url(forResource: "LinkIcon", withExtension: "pdf")
        let pdfDocument = CGPDFDocument((pdfURL as CFURL?)!)
        return pdfDocument!.page(at: 1)
    }
}
