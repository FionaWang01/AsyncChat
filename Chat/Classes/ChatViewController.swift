//
//  ChatViewController.swift
//  Chat
//
//  Created by Petr Pavlik on 23/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol ChatViewControllerDataSource: class {
    func messageCellForIndex(index: UInt) -> MessageCell
    func numberOfMessages() -> UInt
}

class ChatViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    
    weak var dataSource: ChatViewControllerDataSource!
    
    enum Sections: Int {
        case LoadingIndicator = 0, Content, TypingIndicator
    }
    
    enum Avatar {
        case URL(NSURL)
        case image(UIImage)
    }
    var otherUserAvatar: Avatar!
    
    let tableView = ASTableView(frame: CGRectZero, style: .Plain)
    
    var typing = false {
        didSet {
            if tableView.numberOfSections > 0 {
                tableView.beginUpdates()
                tableView.reloadSections(NSIndexSet(index: Sections.TypingIndicator.rawValue), withRowAnimation: .Automatic)
                tableView.endUpdatesAnimated(!typing, completion: { (completed: Bool) -> Void in
                    assert(NSThread.isMainThread())
                    if self.typing == true {
                        self.scrollToBottom(true)
                    }
                })
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        tableView.separatorStyle = .None
        tableView.keyboardDismissMode = .Interactive
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRectMake(0, topLayoutGuide.length, view.bounds.width, view.bounds.height - topLayoutGuide.length)
    }
    
    func scrollToBottom(animated: Bool) {
        
        if tableView.numberOfSections == 0 {
            return
        }
        
        let indexPath: NSIndexPath!
        if tableView.numberOfRowsInSection(Sections.TypingIndicator.rawValue) > 0 {
            indexPath = NSIndexPath(forRow: 0, inSection: Sections.TypingIndicator.rawValue)
        } else if tableView.numberOfRowsInSection(Sections.Content.rawValue) > 0 {
            tableView.numberOfRowsInSection(Sections.Content.rawValue)
            indexPath = NSIndexPath(forRow: tableView.numberOfRowsInSection(Sections.Content.rawValue)-1, inSection: Sections.Content.rawValue)
        } else {
            return
        }
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: animated)
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.Content.rawValue: return Int(dataSource.numberOfMessages())
        case Sections.TypingIndicator.rawValue: return Int(typing == true)
        case Sections.LoadingIndicator.rawValue: return 1
        default: return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 3
    }

    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        
        if indexPath.section == Sections.Content.rawValue {
            
            return dataSource.messageCellForIndex(UInt(indexPath.row))
            
        } else if indexPath.section == Sections.LoadingIndicator.rawValue {
            return LoadingCellNode()
        } else {
            let cellNode = TypingMessageCell()
            /*switch(otherUserAvatar) {
                case .URL(let u): print("a")
                case .image(let u): print("a")
            }*/
            cellNode.configure(NSURL(string: "https://pbs.twimg.com/profile_images/477397164453527552/uh2w1u1o.jpeg")!)
            return cellNode
        }
    }
    
    func tableView(tableView: ASTableView!, willDisplayNodeForRowAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.section == Sections.LoadingIndicator.rawValue {
            let loadingCellNode = tableView.nodeForRowAtIndexPath(indexPath) as! LoadingCellNode
            loadingCellNode.startAnimating()
        } else if indexPath.section == Sections.TypingIndicator.rawValue {
            let typingCellNode = tableView.nodeForRowAtIndexPath(indexPath) as! TypingMessageCell
            typingCellNode.startAnimating()
        }
    }

}
