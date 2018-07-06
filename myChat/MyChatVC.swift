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
        
        /* 1. Create a temporary constant for the standard 'UserDefaults'
           2. Then, check if the keys 'jsq_id and 'jsq_name' exist in the user defaults.
                - If they exist:
                    - Assign the found 'id' and 'name' to 'senderId' and 'senderDisplayName'
                - If they don't exist:
                    - Save the new 'senderId' in the user defaults, for key 'jsq_id' and save the user defaults (with 'synchronize())
                    - Show the display name alert dialog (the one coded earlier)
         3. Then, change the view controller title to "Chat: [display name]"
         4. Finally, create a gesture recognizer that calls the function 'showDisplayNameDialog' when the user taps the navigation bar. */
        let defaults = UserDefaults.standard
        
        if let id = defaults.string(forKey: "jsq_id"), let name = defaults.string(forKey: "jsq_name") {
            senderId = id
            senderDisplayName = name
        } else {
            senderId = String(arc4random_uniform(999999))
            senderDisplayName = ""
            
            defaults.set(senderId, forKey: "jsq_id")
            defaults.synchronize()
            
            showDisplayNameDialog()
        }
        
        title = "Chat: \(senderDisplayName!)"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDisplayNameDialog))
        tapGesture.numberOfTapsRequired = 1
        
        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        
        // Hides the attachment button on the left of the chat text input field
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // Set the avatar size to zero(hiding it).
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        /* 1. Create a query to get the last 10 chat messages
           2. Observe that query for newly added chat data and call a closure when there's new data
           3. Inside the closure the data is "unpacked," a new JSQMessage object is created, and added to the end of the messages array
           4. The function 'finishReceivingMessage() is called, which prompts JSQMVC to refresh the UI and show the new message */
        let query = Constants.refs.databaseChats.queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if let data = snapshot.value as? [String: String],
            let id = data["sender_id"],
            let name = data["name"],
            let text = data["text"],
                !text.isEmpty {
                
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    self?.messages.append(message)
                    
                    self?.finishReceivingMessage()
                }
                
            }
            
        })
    }
    
    /* 1. First, create an alert controller. With it, you can display an alert dialog box on screen. Provide with title and a message.
       2. Then, add a text field to the alert dialog. The text field is either provided with a value from 'UserDefaults', or with a random item from the array names.
       3. Then, add an action to the alert dialog. When the user taps "OK", the closure is executed. In the closure, the sender display name is changed, as well as the view controller title, and the new name is stored in 'UserDefaults'.
       4. Finally, the alert dialog is presented on screen. */
    @objc func showDisplayNameDialog() {
        
        let defaults = UserDefaults.standard
        
        let alert = UIAlertController(title: "Your Display Name", message: "Before you can chat, please choose a display name. Others will see this name when you send chat messages. You can change your display name again by tapping the navigation bar", preferredStyle: .alert)
        
        alert.addTextField { textField in
            
            if let name = defaults.string(forKey: "jsq_name") {
                textField.text = name
            } else {
                let names = ["Tom", "Dick", "Harry", "Marie", "The Master Blaster", "Big Brotha Wonder", "Butt Naked Thunder", "Black Thought", "Luke Cage"]
                textField.text = names[Int(arc4random_uniform(UInt32(names.count)))]
            }

        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak alert] _ in
            
            if let textField = alert?.textFields?[0], !textField.text!.isEmpty {
                self?.senderDisplayName = textField.text
                
                self?.title = "Chat: \(self!.senderDisplayName!)"
                
                defaults.set(textField.text, forKey: "jsq_name")
                defaults.synchronize()
            }
            
        }))
        
        present(alert, animated: true, completion: nil)
        
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
    
    /* 1. Create a reference to a new value, in Firebase on the /chats node, using 'childAutoId()'
     2. Create a dictionary called message that contains all the info about the to-be-sent message: sender ID, display name, and chat text
     3. Set the reference to the value - store the dictionary in the newly created node
     4. Call finishSendingMessage(), a function that tells JSQMVC you're done */
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let ref = Constants.refs.databaseChats.childByAutoId()
        
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]
        
        ref.setValue(message)
        
        finishSendingMessage()
        
    }

}










