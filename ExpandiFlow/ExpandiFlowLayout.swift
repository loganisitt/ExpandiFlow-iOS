//
//  ExpandiFlowLayout.swift
//  ExpandiFlow
//
//  Created by Logan Isitt on 10/5/17.
//  Copyright © 2017 Logan Isitt. All rights reserved.
//

import UIKit

open class ExpandiFlowLayout: UICollectionViewFlowLayout {
    
    open var columns: Int = 3
    open var spacing: CGFloat = 8.0
    open var itemHeight: CGFloat = 80.0
    
    open var selectedIndexPath: IndexPath? {
        didSet {
            guard let collectionView = collectionView else { return }
            collectionView.performBatchUpdates(nil, completion: nil)
        }
    }
    
    private var actualBounds: CGRect = .zero
    
    private var condensedItemWidth: CGFloat = 0.0
    private var expandedItemWidth: CGFloat {
        if columns > 1 {
            return (condensedItemWidth * 2) + minimumInteritemSpacing
        } else {
            return condensedItemWidth
        }
    }
    
    open override func prepare() {
        super.prepare()
        
        minimumInteritemSpacing = spacing
        sectionInset = UIEdgeInsetsMake(0.0, spacing, 0.0, spacing)
        
        updateLayout()
    }
    
    fileprivate func setupCollectionView() {
        
        guard let collectionView = self.collectionView else { return }
        
        if collectionView.decelerationRate != UIScrollViewDecelerationRateFast {
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        }
    }
    
    fileprivate func updateLayout() {
        
        guard let collectionView = self.collectionView else { return }
        
        let collectionSize = collectionView.bounds.size
        
        let columnsF = CGFloat(columns)
        let totalSpacing = (columnsF - 1.0) * minimumInteritemSpacing
        let totalWidth = collectionSize.width - totalSpacing - (sectionInset.left + sectionInset.right)
        
        condensedItemWidth = totalWidth / columnsF
        actualBounds = collectionView.bounds
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: - Override
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard
            let superAttributes = super.layoutAttributesForElements(in: rect),
            let layoutAttributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes],
            let collectionView = collectionView
            else { return nil }
        
        var currentSection = 0
        var currentIndexPath = IndexPath(row: 0, section: 0)
        
        var deadIndexPaths = [IndexPath]()
        
        actualBounds = .zero
        
        func incrementIndex(in section: Int) {
            
            if currentSection != section {
                currentSection = section
                currentIndexPath.section += 1
                currentIndexPath.row = 0
            } else {
                currentIndexPath.row += 1
            }
        }
        
        func elementOriginY(with indexPath: IndexPath) -> Int {
            
            var itemtotal = 0
            for preSection in 0..<indexPath.section {
                
                let sectionItems = collectionView.numberOfItems(inSection: preSection)
                let remainder = sectionItems % columns
                
                itemtotal += sectionItems + remainder
            }
            
            itemtotal += indexPath.row
            
            return itemtotal
        }
        
        if let expandedIndexPath = selectedIndexPath, let expandedElementAttributes = layoutAttributes.filter({ $0.indexPath == expandedIndexPath}).first {
            
            let currentIndexPath = elementOriginY(with: expandedIndexPath)
            
            let trueRow = CGFloat(currentIndexPath / columns)
            let trueCol = CGFloat(currentIndexPath % columns)
            
            let adjustedCol = columns > 1 ? min(trueCol, CGFloat(columns - 2)) : 0
            
            let killIndex = expandedIndexPath.row - (adjustedCol == trueCol ? 0 : 1)
            
            deadIndexPaths.append(IndexPath(row: killIndex, section: currentSection))
            deadIndexPaths.append(IndexPath(row: killIndex + 1, section: currentSection))
            
            if columns > 1 {
                deadIndexPaths.append(IndexPath(row: killIndex + columns, section: currentSection))
                deadIndexPaths.append(IndexPath(row: killIndex + columns + 1, section: currentSection))
            }
            
            let x = (adjustedCol * condensedItemWidth) + ((adjustedCol + 1) * spacing)
            let y = (trueRow * itemHeight) + ((trueRow + 1) * spacing)
            
            let expandedItemHeight = 2 * itemHeight + spacing
            
            let box = CGRect(x: x, y: y, width: expandedItemWidth, height: expandedItemHeight)
            
            actualBounds = actualBounds.union(box)
            
            expandedElementAttributes.center = box.center()
            expandedElementAttributes.size = CGSize(width: expandedItemWidth, height: expandedItemHeight)
        }
        
        for attr in layoutAttributes {
            
            defer {
                incrementIndex(in: attr.indexPath.section)
            }
            
            guard attr.indexPath != selectedIndexPath else { continue }
            
            while deadIndexPaths.contains(currentIndexPath) {
                incrementIndex(in: attr.indexPath.section)
            }
            
            let trueIndex = elementOriginY(with: currentIndexPath)
            
            let trueRow = CGFloat(trueIndex / columns)
            let trueCol = CGFloat(trueIndex % columns)
            let adjustedCol = trueCol
            
            let x = (adjustedCol * condensedItemWidth) + ((adjustedCol + 1) * spacing)
            let y = (trueRow * itemHeight) + ((trueRow + 1) * spacing)
            
            let box = CGRect(x: x, y: y, width: condensedItemWidth, height: itemHeight)
            
            actualBounds = actualBounds.union(box)

            attr.center = box.center()
            attr.size = CGSize(width: condensedItemWidth, height: itemHeight)
        }
        
        return layoutAttributes
    }
    
    open override var collectionViewContentSize: CGSize {
        get {
            return actualBounds.size
        }
    }
}

extension CGRect {
    
    func center() -> CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

