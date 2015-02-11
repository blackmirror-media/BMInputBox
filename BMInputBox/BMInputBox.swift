//
//  BMInputBox.swift
//  BMInputBox
//
//  Created by Adam Eri on 10/02/2015.
//  Copyright (c) 2015 blackmirror media. All rights reserved.
//

import UIKit

class BMInputBox: UIView {

    enum BMInputBoxStyle {
        case PlainTextInput         // Simple text field
        case NumberInput            // Text field accepting numbers only - numeric keyboard
        case PhoneNumberInput       // Text field accepting numbers only - phone keyboard
        case EmailInput             // Text field accepting email addresses -  email keyboard
        case SecureTextInput        // Secure text field for passwords
        case LoginAndPasswordInput  // Two text fields for user and password entry
        case DatePickerInput        // Date picker
        case PickerInput            // Value picker
    }


    // MARK: Initializers

    /// Title of the box
    var title: NSString?

    /// Message in the box
    var message: NSString?

    /// Text on submit button
    var submitButtonText: NSString?

    /// Text on cancel button
    var cancelButtonText: NSString?

    /// The current style of the box
    var style: BMInputBoxStyle = .PlainTextInput

    /// Array holding all elements in the view.
    var elements = NSMutableArray()

    /// Visual effect style
    var blurEffectStyle: UIBlurEffectStyle?

    /// Visual effects view holding the content
    private var visualEffectView: UIVisualEffectView?


    /**
    Class method creating an instace of the input box with a specific style. See BMInputBoxStyle for available styles. Every style comes with different kind and number of input types.

    :param: style Style of the input box

    :returns: instance of the input box.
    */
    class func boxWithStyle (style: BMInputBoxStyle) -> BMInputBox {
        let window = UIApplication.sharedApplication().windows.first as UIWindow

        let padding: CGFloat = 25.0
        let boxFrame = CGRectMake(padding, window.frame.size.height / 2 - 200, window.frame.size.width - padding * 2, 210)

        var inputBox = BMInputBox(frame: boxFrame)
        inputBox.style = style
        return inputBox
    }


    // MARK: Showing and hiding the box

    /**
    Shows the input box
    */
    func show () {

        self.alpha = 0
        self.setupView()

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1
            })

        // TODO: add animation
        let window = UIApplication.sharedApplication().windows.first as UIWindow
        window.addSubview(self)
        window.bringSubviewToFront(self)
    }

    /**
    Hides the input box
    */
    func hide () {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0
        }) { (completed) -> Void in
            self.removeFromSuperview()
        }
    }


    // MARK: Handling user input and actions

    /// Text input used in styles: PlainTextInput, NumberInput, PhoneNumberInput, EmailInput and as a first input in LoginAndPasswordInput.
    private var textInput: UITextField?

    /// Text input used in SecureTextInput and as a second input in LoginAndPasswordInput.
    private var secureInput: UITextField?

    /// Elemenet used in datePicker style.
    private var datePicker: UIDatePicker?

    /// Elemenet used in picker style.
    var picker: UIPickerView?

    /// Closure to allow customisation of the input element
    var customiseInputElement: ((element: UITextField) -> UITextField)!

    /// Closure executed when user submits the values.
    var onSubmit: ((value: AnyObject...) -> Void)!

    /// Closure executed when user cancels submission
    var onCancel: (() -> Void)!

    internal func cancelButtonTapped () {
        if self.onCancel != nil {
            self.onCancel()
        }
        self.hide()
    }

    internal func submitButtonTapped () {
        if self.onSubmit != nil {
            let valueToReturn: String? = self.textInput!.text

            if let value2ToReturn = self.secureInput?.text {
                self.onSubmit(value: valueToReturn!, value2ToReturn)
            }
            else {
                self.onSubmit(value: valueToReturn!)
            }
        }
        self.hide()
    }


    // MARK: Priate methods for creating the box based on style

    /**
    Method called when creating the box. Sets up the user elements based on the style and the possible custom elements.
    */
    private func setupView () {

        /// Corners
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true

        /// Blur stuff
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: self.blurEffectStyle? ?? UIBlurEffectStyle.Light))

        /// Constants
        let padding: CGFloat = 20.0
        let width = self.frame.size.width - padding * 2

        /// Labels
        var titleLabel = UILabel(frame: CGRectMake(padding, padding, width, 20))
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        titleLabel.text = self.title?
        titleLabel.textAlignment = .Center
        titleLabel.textColor = (self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor()
        self.visualEffectView?.contentView.addSubview(titleLabel)

        var messageLabel = UILabel(frame: CGRectMake(padding, padding + titleLabel.frame.size.height + 10, width, 20))
        messageLabel.numberOfLines = 4;
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.text = self.message?
        messageLabel.textAlignment = .Center
        messageLabel.textColor = (self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor()
        messageLabel.sizeToFit()
        self.visualEffectView?.contentView.addSubview(messageLabel)


        /**
        *  Inputs
        */
        switch self.style {
        case .PlainTextInput, .NumberInput, .EmailInput, .SecureTextInput:
            self.textInput = UITextField(frame: CGRectMake(padding, messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 2, width, 35))
            self.textInput?.textAlignment = .Center

            // Allow customisation
            if self.customiseInputElement != nil {
                self.textInput = self.customiseInputElement(element: self.textInput!)
            }

            self.elements.addObject(self.textInput!)

        case .LoginAndPasswordInput:

            // TextField

            self.textInput = UITextField(frame: CGRectMake(padding, messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 2, width, 35))
            self.textInput?.textAlignment = .Center

            // Allow customisation
            if self.customiseInputElement != nil {
                self.textInput = self.customiseInputElement(element: self.textInput!)
            }

            self.elements.addObject(self.textInput!)

            // PasswordField
            self.secureInput = UITextField(frame: CGRectMake(padding, self.textInput!.frame.origin.y + self.textInput!.frame.size.height + padding / 2, width, 35))
            self.secureInput?.textAlignment = .Center
            self.secureInput?.secureTextEntry = true

            // Allow customisation
            if self.customiseInputElement != nil {
                self.secureInput = self.customiseInputElement(element: self.secureInput!)
            }

            self.elements.addObject(self.secureInput!)

            var extendedFrame = self.frame
            extendedFrame.size.height += 50
            self.frame = extendedFrame

//
//        case .DatePickerInput:
//
//        case .PickerInput:
            
        default:
            NSLog("")
        }

        if self.style == .NumberInput {
            self.textInput?.keyboardType = .NumberPad
        }

        if self.style == .PhoneNumberInput {
            self.textInput?.keyboardType = .PhonePad
        }

        if self.style == .EmailInput {
            self.textInput?.keyboardType = .EmailAddress
        }

        if self.style == .SecureTextInput {
            self.textInput?.secureTextEntry = true
        }

        for element in self.elements {
            let element: UITextField = element as UITextField
            element.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
            element.layer.borderWidth = 0.5
            element.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.5)
            self.visualEffectView?.contentView.addSubview(element)
        }


        /**
        *  Setting up buttons
        */

        let buttonHeight: CGFloat = 45.0
        let buttonWidth = self.frame.size.width / 2

        var cancelButton = UIButton(frame: CGRectMake(0, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        cancelButton.setTitle(self.cancelButtonText? ?? "Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped", forControlEvents: .TouchUpInside)
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        cancelButton.setTitleColor((self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        cancelButton.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
        cancelButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
        cancelButton.layer.borderWidth = 0.5
        self.visualEffectView?.contentView.addSubview(cancelButton)

        var submitButton = UIButton(frame: CGRectMake(buttonWidth, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        submitButton.setTitle(self.submitButtonText? ?? "OK", forState: .Normal)
        submitButton.addTarget(self, action: "submitButtonTapped", forControlEvents: .TouchUpInside)
        submitButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        submitButton.setTitleColor((self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        submitButton.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
        submitButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
        submitButton.layer.borderWidth = 0.5
        self.visualEffectView?.contentView.addSubview(submitButton)


        self.visualEffectView!.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        self.addSubview(self.visualEffectView!)
    }

}
