//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Vidur Gupta on 2/21/20.
//  Copyright © 2020 Vidur Gupta. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts =  [PFObject]()
    var selectedPost:PFObject!
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground();
        tableView.reloadData()
        
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let comments =  (posts[section]["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments =  (posts[indexPath.section]["comments"] as? [PFObject]) ?? []
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
            
            let user = post["author"] as! PFUser
            cell.lblUserName.text = user.username
            
            cell.lblCaption.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        } else if (indexPath.row <= comments.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            cell.lblComment.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.lblName.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if (indexPath.row == comments.count + 1) {
            showsCommentBar = true
            becomeFirstResponder()
            
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "keys", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if (posts != nil) {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func keybordWillBeHidden(note: NSNotification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController");
        
        self.view.window?.rootViewController = loginViewController
        
    }
    
}
