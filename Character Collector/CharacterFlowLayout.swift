//
//  CharacterFlowLayout.swift
//  Character Collector
//
//  Created by buiduyhien on 6/28/20.
//  Copyright © 2020 Razeware, LLC. All rights reserved.
//

import UIKit

class CharacterFlowLayout: UICollectionViewFlowLayout {
    let standardItemAlpha: CGFloat = 0.5
    let standardItemScale: CGFloat = 0.5
    
    override func prepare() {
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in attributes! {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            
            changeLayoutAttributes(itemAttributesCopy)
            attributesCopy.append(itemAttributesCopy)
        }
        
        return attributesCopy
    }
    
    /*
     Nếu ko có method này, offset của scroll mỗi khi vuốt sẽ ko được update liên tục, giống như bị cache lại
     */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func changeLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        let collectionCenter = collectionView!.frame.size.height / 2
        let offset = collectionView!.contentOffset.y
        /*
         Vì itemSize set là (200, 200) mà màn hình iPhone 7, width là 375, nên chỉ đủ 1 item trong 1 row
         Cơ chế mặc định của collection view là center nên nếu chỉ có 1 item trên 1 row thì nó sẽ ở giữa
         Vậy center của item 0 là (375/2, 200/2)
         375 là width của iPhone 7, 200 là height của cell
         */
        let normalizedCenter = attributes.center.y - offset
        
        /*
         minimumLineSpacing default = 10
         maxDistance const
         */
        let maxDistance = self.itemSize.height + self.minimumLineSpacing
        /*
         max of distance is maxDistance
         distance = {0, maxDistance)
         */
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        
        /*
         ratio = {0, 1}
         */
        let ratio = (maxDistance - distance) / maxDistance
        /*
         ratio * (1 - self.standardItemAlpha) = {0, 0.5)
         alpha = ratio * (1 - self.standardItemAlpha) + self.standardItemAlpha = {0.5, 1}
         */
        let alpha = ratio * (1 - self.standardItemAlpha) + self.standardItemAlpha
        /*
         scale = {0.5 ,1}
         */
        let scale = ratio * (1 - self.standardItemScale) + self.standardItemScale
        
        attributes.alpha = alpha
        /*
         Khi scale thì center giữ nguyên, width, height thay đổi trước rồi từ đó origin thay đổi
         Before: (87.5, 0, 200, 200)
         => center = (187.5, 100)
         scale = 0.5
         => new (width, height) = (100, 100)
         CenterX = width / 2 + originX
         => new originX = centerX - width / 2 = 187.5 - 100/2 = 137.5
         CenterY = height / 2 + originY
         => new originY = centerY - height / 2 = 100 - 100/2 = 50
         */
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        
        attributes.zIndex = Int(alpha * 10)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let layoutAttributes = self.layoutAttributesForElements(in: collectionView!.bounds)
        
        let center = collectionView!.bounds.size.height / 2
        let proposedContentOffsetCenterOrigin = proposedContentOffset.y + center
        
        let closest = layoutAttributes!.sorted {
            abs($0.center.y - proposedContentOffsetCenterOrigin) <
            abs($1.center.y - proposedContentOffsetCenterOrigin)
        }.first ?? UICollectionViewLayoutAttributes()
        
        let targetContentOffset = CGPoint(x: proposedContentOffset.x,
                                          y: floor(closest.center.y - center))
        
        return targetContentOffset
    }
}
