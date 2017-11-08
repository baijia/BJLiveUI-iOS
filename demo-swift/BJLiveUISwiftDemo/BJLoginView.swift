//
//  BJLoginView.swift
//  BJLiveUISwiftDemo
//
//  Created by HuangJie on 2017/9/22.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

import Foundation

class BJLoginView: UIView {
    var codeTextField = UITextField.init()
    var nameTextField = UITextField.init()
    var doneButton = UIButton.init()
    
    private var backgroundView: UIImageView?
    private var appLogoView, logoView: UIImageView?
    private var inputContainerView, inputSeparatorLine: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeSubViews()
        self.makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:subviews
    
    private func makeSubViews() {
        // backgroundView
        let backgroundView = UIImageView.init()
        backgroundView.contentMode = UIViewContentMode.scaleAspectFill
        backgroundView.image = UIImage.init(named: "login-bg")
        self.backgroundView = backgroundView
        self.addSubview(self.backgroundView!)
        
        // appLogoView
        self.appLogoView = UIImageView.init(image: UIImage.init(named: "login-logo-app"))
        self.addSubview(self.appLogoView!)
        
        // logoView
        self.logoView = UIImageView.init(image: UIImage.init(named: "login-logo"))
        self.addSubview(self.logoView!)
        
        // inputContainerView
        let inputContainerView = UIView.init()
        inputContainerView.backgroundColor = UIColor.init(white: 1.0, alpha: 0.5)
        inputContainerView.layer.masksToBounds = true
        inputContainerView.layer.cornerRadius = 3.0
        self.inputContainerView = inputContainerView;
        self.addSubview(self.inputContainerView!)
        
        let inputSeparatorLine = UIView.init()
        inputSeparatorLine.backgroundColor = UIColor.init(white: 1.0, alpha: 0.5)
        self.inputSeparatorLine = inputSeparatorLine
        self.addSubview(self.inputSeparatorLine!)
        
        // codeTextField
        self.codeTextField = self.textField(icon: UIImage.init(named: "login-icon-code")!, placeholder: "请输入参加码")
        self.codeTextField.returnKeyType = UIReturnKeyType.next
        self.inputContainerView?.addSubview(self.codeTextField)
        
        // nameTextField
        self.nameTextField = self.textField(icon: UIImage.init(named: "login-icon-name")!, placeholder: "请输入昵称")
        self.nameTextField.returnKeyType = UIReturnKeyType.done
        self.inputContainerView?.addSubview(self.nameTextField)
        
        // doneButton
        let doneButton = UIButton.init()
        doneButton.backgroundColor = UIColor.bjl_color(withHexString: "#1694FF")
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 2.0
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.init(white: 1.0, alpha: 0.5), for: UIControlState.disabled)
        doneButton.setTitle("登录", for: UIControlState.normal)
        self.doneButton = doneButton
        self.addSubview(self.doneButton)
    }
    
    // MARK:constraints
    
    private func makeConstraints() {
        let margin: CGFloat = 10.0
        
        _ = self.backgroundView?.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.edges.equalTo()(self)
        })
        
        _ = self.inputContainerView?.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.centerX.equalTo()(self)
            make.bottom.equalTo()(self.mas_centerY)?.offset()(-32.0)
            make.left.right().equalTo()(self)?.with().insets()(UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0))
            make.height.equalTo()(100.0)
        })
        
        _ = self.inputSeparatorLine?.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.center.equalTo()(self.inputContainerView)
            make.left.right().equalTo()(self.inputContainerView)?.with().insets()(UIEdgeInsetsMake(0.0, margin, 0.0, margin))
            make.height.equalTo()(1.0 / UIScreen.main.scale)
        })
        
        _ = self.codeTextField.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.top.left().right().equalTo()(self.inputContainerView)?.with().insets()(UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0))
        })
        
        _ = self.nameTextField.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.bottom.left().right().equalTo()(self.inputContainerView)?.with().insets()(UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0))
            make.top.equalTo()(self.codeTextField.mas_bottom)
            make.height.equalTo()(self.codeTextField)
        })
        
        _ = self.appLogoView?.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.centerX.equalTo()(self)
            make.bottom.equalTo()(self.inputContainerView?.mas_top)?.offset()(-32.0)
        })
        
        _ = self.logoView?.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.centerX.equalTo()(self)
            make.bottom.equalTo()(self)?.offset()(-40.0)
        })
        
        _ = self.doneButton.mas_makeConstraints({ (make: MASConstraintMaker!) in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.inputContainerView?.mas_bottom)?.offset()(32.0)
            make.width.equalTo()(self.inputContainerView)
            make.height.equalTo()(50.0)
        })
    }
    
    // MARK:private
    private func textField(icon: UIImage, placeholder: String) -> UITextField {
        let fontSize: CGFloat = 14.0
        
        let textField = UITextField.init()
        textField.font = UIFont.systemFont(ofSize: fontSize)
        textField.textColor = UIColor.white
        textField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        // placeholder
        let attributeDic: Dictionary = [NSFontAttributeName : UIFont.systemFont(ofSize: fontSize),
                                        NSForegroundColorAttributeName : UIColor.init(white: 1.0, alpha: 0.69)];
        textField.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes:attributeDic)
        
        // leftView
        let button = UIButton.init()
        button.setImage(icon, for: UIControlState.normal)
        textField.leftView = button
        textField.leftViewMode = UITextFieldViewMode.always
        button.mas_makeConstraints { (make: MASConstraintMaker!) in
            make.size.mas_equalTo()(CGSize.init(width: 27.0, height: 27.0))
        }
        button.rac_signal(for: UIControlEvents.touchUpInside).subscribeNext { (sender) in
            textField.becomeFirstResponder()
        }
        return textField
    }
}
