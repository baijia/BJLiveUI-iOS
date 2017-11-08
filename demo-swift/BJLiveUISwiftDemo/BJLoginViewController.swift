//
//  BJLoginViewController.swift
//  BJLiveUISwiftDemo
//
//  Created by HuangJie on 2017/9/21.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

import Foundation
import UIKit
// import BJLiveUI

struct loginConstants {
    static let BJLoginCodeKey = "BJLoginCode"
    static let BJLoginNameKey = "BJLoginName"
}

class BJLoginViewController: UIViewController, UITextFieldDelegate, BJLRoomViewControllerDelegate {
    
    private var codeLoginView: BJLoginView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.codeLoginView = self.createLoginView()
        let codeString: String? = UserDefaults.standard.string(forKey: loginConstants.BJLoginCodeKey)
        let nameString: String? = UserDefaults.standard.string(forKey: loginConstants.BJLoginNameKey)
        if (codeString != nil) && (nameString != nil) {
            self.set(code: codeString!, name: nameString!)
        }
        
        self.makeSignals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return (UIApplication.shared.statusBarOrientation != UIInterfaceOrientation.portrait)
    }
    
    private func set(code : String, name : String) {
        let loginView = self.codeLoginView!
        loginView.codeTextField.text = code
        loginView.nameTextField.text = name
    }
    
    private func createLoginView() -> BJLoginView {
        let loginView = BJLoginView.init(frame: CGRect.zero)
        self.view.addSubview(loginView)
        loginView.mas_makeConstraints { (make: MASConstraintMaker!) in
            make.edges.equalTo()(self.view)
        }
        return loginView
    }
    
    private func makeSignals() {
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(NSMutableAttributedString.endEditing))
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(NSMutableAttributedString.endEditing))
        self.view.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(panGesture)
        
        // clear cache if changed
        self.codeLoginView?.codeTextField.rac_textSignal().distinctUntilChanged().skip(1).subscribeNext({ (codeText: NSString?) in
            UserDefaults.standard.removeObject(forKey: loginConstants.BJLoginCodeKey)
            UserDefaults.standard.synchronize()
            self.setDoneButtonEnable()
        })
        self.codeLoginView?.nameTextField.rac_textSignal().distinctUntilChanged().skip(1).subscribeNext({ (nameText: NSString?) in
            UserDefaults.standard.removeObject(forKey: loginConstants.BJLoginNameKey)
            UserDefaults.standard.synchronize()
            self.setDoneButtonEnable()
        })
        
        // delegate
        self.codeLoginView?.codeTextField.delegate = self
        self.codeLoginView?.nameTextField.delegate = self
        
        // login
        self.codeLoginView?.doneButton .rac_signal(for: UIControlEvents.touchUpInside).subscribeNext({ (button) in
            self.login()
        })
    }
    
    private func login() {
        self.endEditing()
        
        let codeString  = self.codeLoginView?.codeTextField.text
        let nameString = self.codeLoginView?.nameTextField.text
        let roomViewController = BJLRoomViewController.instance(withSecret: codeString!, userName: nameString!, userAvatar: nil) as! BJLRoomViewController
        roomViewController.delegate = self
        self.present(roomViewController, animated: true, completion: nil)
        self.storeCodeAndName()
    }
    
    // MARK: <UITextFieldDelegate>
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.codeLoginView?.codeTextField {
            self.codeLoginView?.nameTextField.becomeFirstResponder()
        }
        else if textField == self.codeLoginView?.nameTextField {
            if (self.codeLoginView?.doneButton.isEnabled)! {
                self.login()
            }
        }
        return false
    }
    
    // MARK: <BJLRoomViewControllerDelegate>
    
    func roomViewControllerEnterRoomSuccess(_ roomViewController: BJLRoomViewController) {
        print("enter room success")
    }
    
    func roomViewController(_ roomViewController: BJLRoomViewController, enterRoomFailureWithError error: Error) {
        print("enter room failure with error:" + error.localizedDescription)
    }
    
    func roomViewController(_ roomViewController: BJLRoomViewController, willExitWithError error: Error?) {
        var logString = "will exit room"
        if (error != nil) {
            logString = logString + "with error:" + (error?.localizedDescription)!
        }
        print(logString)
    }
    
    func roomViewController(_ roomViewController: BJLRoomViewController, didExitWithError error: Error?) {
        var logString = "did exit room"
        if (error != nil) {
            logString = logString + "with error:" + (error?.localizedDescription)!
        }
        print(logString)
    }
    
    func roomViewController(_ roomViewController: BJLRoomViewController, viewControllerToShowForCustomButton button: UIButton) -> UIViewController? {
        return nil
    }
    
    private func setDoneButtonEnable() {
        let codeString = self.codeLoginView?.codeTextField.text
        let nameString = self.codeLoginView?.nameTextField.text
        self.codeLoginView?.doneButton.isEnabled = (!(codeString?.isEmpty)! && !(nameString?.isEmpty)!)
    }
    
    private func storeCodeAndName() {
        UserDefaults.standard.set(self.codeLoginView?.codeTextField.text, forKey: loginConstants.BJLoginCodeKey)
        UserDefaults.standard.set(self.codeLoginView?.nameTextField.text, forKey: loginConstants.BJLoginNameKey)
        UserDefaults.standard.synchronize()
    }
    
    func endEditing() {
        self.view.endEditing(true);
    }
}
