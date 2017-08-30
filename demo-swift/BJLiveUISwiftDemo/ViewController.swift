//
//  ViewController.swift
//  TestSwiftApp
//
//  Created by MingLQ on 2017-05-25.
//  Copyright © 2017 GSX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton.init();
        button.setTitle("", for: .normal);
        
        let room: BJLRoom = BJLRoom.room(withSecret: "", userName: "", userAvatar: "") as! BJLRoom;
        room.enterSuccess();
        
        let roomVC = BJRoomViewController()
        self.bjl_addChildViewController(roomVC, superview: self.view)
    }
    
}

