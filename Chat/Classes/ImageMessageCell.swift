//
//  ImageMessageCell.swift
//  Chat
//
//  Created by Petr Pavlik on 25/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Toucan

class ImageMessageCell: MessageCell, ASNetworkImageNodeDelegate {
    
    private let imageNode = ASNetworkImageNode()
    
    //FIXME: This is probably called on multiple threads.
    private var requiredImageSize = CGSizeZero
    
    init(imageURL: NSURL, isIncomming: Bool) {
        super.init()
        
        self.isIncommingMessage = isIncomming
        
        addSubnode(imageNode)
        
        imageNode.delegate = self
        
        imageNode.imageModificationBlock = { [unowned self] (image) in
            var toucanImage = Toucan(image: image).resize(self.requiredImageSize)
            toucanImage = toucanImage.maskWithPath(path: UIBezierPath(roundedRect: CGRectMake(0, 0, toucanImage.image.size.width, toucanImage.image.size.height), cornerRadius: 18))
            return toucanImage.image
        }
        
        imageNode.setURL(imageURL, resetToDefault: true)
        
        isIncommingMessage = isIncomming
        
        if isIncomming == true {
            bubbleNode.tintColor = incomingMessageColorNormal
        } else {
            bubbleNode.tintColor = outgoingMessageColorNormal
        }
    }
    
    override func layout() {
        super.layout()
        imageNode.frame = bubbleNode.frame
        requiredImageSize = imageNode.bounds.size
    }
    
    func layoutSpecForMessageBubble() -> ASLayoutSpec {
        
        let sizeLayout = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [bubbleNode])
        
        sizeLayout.sizeRange = ASRelativeSizeRangeMake(
            ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(100), ASRelativeDimensionMakeWithPoints(0)),
            ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(100), ASRelativeDimensionMakeWithPoints(100))
        )
        
        let aspectLayout = ASRatioLayoutSpec(ratio: 4/3, child: bubbleNode)
        
        return ASStaticLayoutSpec(children: [sizeLayout, aspectLayout])
    }

    func imageNode(imageNode: ASNetworkImageNode!, didLoadImage image: UIImage!) {
        
    }
    
}
