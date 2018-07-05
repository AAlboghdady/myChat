//
//  ViewController.swift
//  myChat
//
//  Created by Sain-R Edwards on 7/4/18.
//  Copyright © 2018 Swift Koding 4 Everyone. All rights reserved.
//

import UIKit

class MyChatVC: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    
    /* Lazy properties are only initialized once - when they
     are accessed. Every subsequent access, the initial value
     is returned. */
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = "1234"
        senderDisplayName = "SKE"
        
        // Hides the attachment button on the left of the chat text input field
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // Set the avatar size to zero(hiding it).
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        /* Ternary conditional operator is used to say when the 'messages[indexPath.item].senderId == senderId' is true - return
         the outgoingBubble, if it is false, return the incomingBubble. */
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    // Hide avatars for message bubbles
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // Called when the label text is needed
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    // Called when the height of the top label is needed
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }

}










