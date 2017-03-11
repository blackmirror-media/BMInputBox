//
//  BMInputBox.swift
//  BMInputBox
//
//  Created by Adam Eri on 10/02/2015.
//  Copyright (c) 2015 blackmirror media. All rights reserved.
//

import UIKit

@objc public enum BMInputBoxStyle: Int {
  case plainTextInput         // Simple text field
  case numberInput            // Text field accepting numbers only - numeric keyboard
  case phoneNumberInput       // Text field accepting numbers only - phone keyboard
  case emailInput             // Text field accepting email addresses -  email keyboard
  case secureTextInput        // Secure text field for passwords
  case loginAndPasswordInput  // Two text fields for user and password entry
  //        case DatePickerInput        // Date picker
  //        case PickerInput            // Value picker
}

public class BMInputBox: UIView {
  
  // MARK: Initializers
  
  /// Title of the box
  public var title: String?
  
  /// Message in the box
  public var message: String?
  
  /// Text on submit button
  public var submitButtonText: String?
  
  /// Text on cancel button
  public var cancelButtonText: String?
  
  /// The current style of the box
  @objc public var style: BMInputBoxStyle = .plainTextInput
  
  
  /**
   Customisation of the NumberInput type
   */
  
  /// The amount of mandatory decimals in case of NumberInput
  public var numberOfDecimals: Int = 0
  /// If set, the value entered into a NumberInput will be validated against it as a minimum value.
  public var minimumValue: NSNumber!
  /// If set, the value entered into a NumberInput will be validated against it as a maximum value.
  public var maximumValue: NSNumber!
  
  
  /**
   Customisation of the PlainText type
   */
  /// Maximum length of the text.  If set, the entered text's length 
  /// will be checked against this.
  public var maximumLength: Int?
  
  /// Minimum length of the text. If set, the entered text's length
  //// will be checked against this.
  public var minimumLength: Int?
  
  /// If true, nil values are accepted. But if something is entered, 
  /// it has to be in the format specified by the other validation properties.
  public var isOptional: Bool = false
  
  /**
   String used to notify the user about the value critera 
   (minimum and maximum values).
   
   @discussion
   There are three cases that could occur:
   - Only minimum validation
   - Only maximum validation
   - Validation in a range (minimum to maximum)
   
   The property should have the string approproate for your use case. 
   It should also have NSNumber placeholder(s) (%@) within. If not set, 
   the default strings will be used.
   */
  public var validationLabelText: String?
  
  /// UILabel for displaying the validation message
  private var validationLabel: UILabel!
  
  
  /// Array holding all elements in the view.
  var elements = NSMutableArray()
  
  /// Visual effect style
  public var blurEffectStyle: UIBlurEffectStyle?
  
  /// Visual effects view holding the content
  private var visualEffectView: UIVisualEffectView?
  
  
  /**
   Class method creating an instace of the input box with a specific style. 
   See BMInputBoxStyle for available styles. Every style comes with different 
   kind and number of input types.
   
   - parameter style: Style of the input box
   
   - returns: instance of the input box.
   */
  @objc public class func boxWithStyle (_ style: BMInputBoxStyle) -> BMInputBox {
    let window = UIApplication.shared.windows.first as UIWindow!
    let boxFrame = CGRect(
      x: 0,
      y: 0,
      width: min(325, (window?.frame.size.width)! - 50),
      height: 210)
    
    let inputBox = BMInputBox(frame: boxFrame)
    inputBox.center = CGPoint(
      x: (window?.center.x)!,
      y: (window?.center.y)! - 30)
    
    inputBox.style = style
    return inputBox
  }
  
  
  // MARK: Showing and hiding the box
  
  /**
   Shows the input box
   */
  public func show () {
    
    self.alpha = 0
    self.setupView()
    
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.alpha = 1
    })
    
    let window = UIApplication.shared.windows.first as UIWindow!
    window?.addSubview(self)
    window?.bringSubview(toFront: self)
    
    // Rotation support
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter
      .default
      .addObserver(
        self,
        selector: #selector(self.deviceOrientationDidChange),
        name: NSNotification.Name.UIDeviceOrientationDidChange,
        object: nil)
    
    // Keyboard
    NotificationCenter
      .default
      .addObserver(
        self,
        selector: #selector(self.keyboardDidShow),
        name: NSNotification.Name.UIKeyboardDidShow,
        object: nil)
    
    NotificationCenter
      .default
      .addObserver(
        self,
        selector: #selector(self.keyboardDidHide),
        name: NSNotification.Name.UIKeyboardDidHide,
        object: nil)
  }
  
  /**
   Hides the input box
   */
  public func hide () {
    UIView.animate(withDuration: 0.3, animations: { () -> Void in
      self.alpha = 0
    }) { (completed) -> Void in
      self.removeFromSuperview()
      
      // Rotation support
      UIDevice.current.endGeneratingDeviceOrientationNotifications()
      NotificationCenter
        .default
        .removeObserver(
          self,
          name: NSNotification.Name.UIDeviceOrientationDidChange,
          object: nil)
      
      // Keyboard
      NotificationCenter
        .default
        .removeObserver(
          self,
          name: NSNotification.Name.UIKeyboardDidShow,
          object: nil)
      
      NotificationCenter
        .default
        .removeObserver(
          self,
          name: NSNotification.Name.UIKeyboardDidHide,
          object: nil)
    }
  }
  
  /**
   Method called when creating the box. Sets up the user elements based on the style and the possible custom elements.
   */
  private func setupView () {
    
    /// Corners
    self.layer.cornerRadius = 4.0
    self.layer.masksToBounds = true
    
    /// Blur stuff
    self.visualEffectView = UIVisualEffectView(
      effect: UIBlurEffect(style:
        self.blurEffectStyle ?? UIBlurEffectStyle.extraLight))
    
    let isDark = (self.blurEffectStyle == .dark)
    
    /// Constants
    let padding: CGFloat = 20.0
    let width = self.frame.size.width - padding * 2
    
    /// Labels
    let titleLabel = UILabel(frame: CGRect(
      x: padding,
      y: padding,
      width: width,
      height: 20))
    
    titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
    titleLabel.text = self.title
    titleLabel.textAlignment = .center
    titleLabel.textColor = (isDark) ? UIColor.white : UIColor.black
    self.visualEffectView?.contentView.addSubview(titleLabel)
    
    let messageLabel = UILabel(frame: CGRect(
      x: padding,
      y: padding + titleLabel.frame.size.height + 10,
      width: width,
      height: 20))
    
    messageLabel.numberOfLines = 3;
    messageLabel.font = UIFont.systemFont(ofSize: 14)
    messageLabel.text = self.message
    messageLabel.textAlignment = .center
    messageLabel.textColor = (isDark) ? UIColor.white : UIColor.black
    
    /**
     *  Sizetofit fucks up the x coordinate and the label
     will be narrower. This fixes it.
     */
    let x = messageLabel.center.x
    messageLabel.sizeToFit()
    messageLabel.center = CGPoint(x: x, y: messageLabel.center.y)
    
    self.visualEffectView?.contentView.addSubview(messageLabel)
    
    
    /**
     *  Inputs
     */
    switch self.style {
    case .plainTextInput, .numberInput, .emailInput, .secureTextInput, .phoneNumberInput:
      self.textInput = UITextField(
        frame: CGRect(
          x: padding,
          y: messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 1.5,
          width: width,
          height: 35))
      
      self.textInput?.textAlignment = .center
      self.textInput?.textColor = (isDark) ? UIColor.white : UIColor.black
      
      // Allow customisation
      if self.customiseInputElement != nil {
        self.textInput = self.customiseInputElement(self.textInput!)
      }
      
      self.elements.add(self.textInput!)
      
    case .loginAndPasswordInput:
      
      // TextField
      self.textInput = UITextField(
        frame: CGRect(
          x: padding,
          y: messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 1.5,
          width: width,
          height: 35))
      
      self.textInput?.textAlignment = .center
      
      // Allow customisation
      if self.customiseInputElement != nil {
        self.textInput = self.customiseInputElement(self.textInput!)
      }
      
      self.elements.add(self.textInput!)
      
      // PasswordField
      self.secureInput = UITextField(
        frame: CGRect(
          x: padding,
          y: self.textInput!.frame.origin.y + self.textInput!.frame.size.height + padding / 2,
          width: width,
          height: 35))
      
      self.secureInput?.textAlignment = .center
      self.secureInput?.isSecureTextEntry = true
      
      // Allow customisation
      if self.customiseInputElement != nil {
        self.secureInput = self.customiseInputElement(self.secureInput!)
      }
      
      self.elements.add(self.secureInput!)
      
      var extendedFrame = self.frame
      extendedFrame.size.height += 45
      self.frame = extendedFrame
      
      //  TODO: Finish
      //        case .DatePickerInput:
      //
      //        case .PickerInput:
      
    }
    
    
    /**
     *  Validation and customisation for the number input type.
     */
    if self.style == .numberInput {
      self.textInput?.keyboardType = .numberPad
      
      self.validationLabel = UILabel(
        frame: CGRect(
          x: padding,
          y: self.textInput!.frame.origin.y + self.textInput!.frame.size.height + 5,
          width: width,
          height: 20))
      
      self.validationLabel.numberOfLines = 1;
      self.validationLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
      
      let messageString: String? = self.validationLabelText
      
      if (self.minimumValue != nil && self.maximumValue == nil) {
        self.validationLabel.text = String(
          format: messageString ?? "A value greater than %@.",
          self.minimumValue!) as String
      }
      else if (self.minimumValue == nil && self.maximumValue != nil) {
        self.validationLabel.text = String(
          format: messageString ?? "A value lower than %@.",
          self.maximumValue!) as String
      }
      else if (self.minimumValue != nil && self.maximumValue != nil) {
        self.validationLabel.text = String(
          format: messageString ?? "A value between %@ and %@.",
          self.minimumValue!,
          self.maximumValue!) as String
      }
      
      self.validationLabel.textAlignment = .center
      self.validationLabel.textColor = (isDark) ?
        UIColor.white :
        UIColor(red: 220/255, green: 53/255, blue: 34/255, alpha: 1)
      
      self.visualEffectView?.contentView.addSubview(self.validationLabel)
      
      // Extending the frame of the box
      var extendedFrame = self.frame
      extendedFrame.size.height += 15
      self.frame = extendedFrame
      
    }
    
    /**
     *  Validation and customisation for the plain text input type.
     */
    if self.style == .plainTextInput {
      self.validationLabel = UILabel(
        frame: CGRect(
          x: padding,
          y: self.textInput!.frame.origin.y + self.textInput!.frame.size.height + 5,
          width: width,
          height: 20))
      
      self.validationLabel.numberOfLines = 1;
      self.validationLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
      
      let messageString: String? = self.validationLabelText
      
      if (self.minimumLength != nil && self.maximumLength == nil) {
        self.validationLabel.text = String(
          format: messageString ?? "A text longer than %i characters.",
          self.minimumLength!) as String
      }
      else if (self.minimumLength == nil && self.maximumLength != nil) {
        self.validationLabel.text = String(
          format: messageString ?? "A text shorter than %i characters.",
          self.maximumLength!) as String
      }
      else if (self.minimumLength != nil && self.maximumLength != nil) {
        
        if (self.minimumLength == self.maximumLength) {
          self.validationLabel.text = String(
            format: messageString ?? "A text exactly %i characters long.",
            self.minimumLength!) as String
        } else {
          self.validationLabel.text = String(
            format: messageString ?? "A text between %i and %i characters.",
            self.minimumLength!,
            self.maximumLength!) as String
        }
      }
      
      self.validationLabel.textAlignment = .center
      self.validationLabel.textColor = (isDark) ?
        UIColor.white :
        UIColor(red: 220/255, green: 53/255, blue: 34/255, alpha: 1)
      
      self.visualEffectView?.contentView.addSubview(self.validationLabel)
      
      // Extending the frame of the box
      var extendedFrame = self.frame
      extendedFrame.size.height += 15
      self.frame = extendedFrame
    }
    
    if self.style == .phoneNumberInput {
      self.textInput?.keyboardType = .phonePad
    }
    
    if self.style == .emailInput {
      self.textInput?.keyboardType = .emailAddress
    }
    
    if self.style == .secureTextInput {
      self.textInput?.isSecureTextEntry = true
    }
    
    for element in self.elements {
      let element: UITextField = element as! UITextField
      element.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
      element.layer.borderWidth = 0.5
      element.backgroundColor = (isDark) ?
        UIColor(white: 1, alpha: 0.07) :
        UIColor(white: 1, alpha: 0.5)
      self.visualEffectView?.contentView.addSubview(element)
    }
    
    
    /**
     On change event.
     */
    self
      .textInput?
      .addTarget(
        self,
        action: #selector(self.textInputDidChange),
        for: .editingChanged)
    
    /**
     *  Setting up buttons
     */
    
    let buttonHeight: CGFloat = 45.0
    let buttonWidth = self.frame.size.width / 2
    
    let cancelButton = UIButton(frame: CGRect(x: 0, y: self.frame.size.height - buttonHeight, width: buttonWidth, height: buttonHeight))
    let cancelButtonTxt = (self.cancelButtonText ?? "Cancel")
    cancelButton.setTitle(cancelButtonTxt as String, for: UIControlState())
    cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped), for: .touchUpInside)
    cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    cancelButton.setTitleColor((self.blurEffectStyle == .dark) ? UIColor.white : UIColor.black, for: UIControlState())
    cancelButton.setTitleColor(UIColor.gray, for: .highlighted)
    cancelButton.backgroundColor = (self.blurEffectStyle == .dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
    cancelButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
    cancelButton.layer.borderWidth = 0.5
    self.visualEffectView?.contentView.addSubview(cancelButton)
    
    let submitButton = UIButton(frame: CGRect(x: buttonWidth, y: self.frame.size.height - buttonHeight, width: buttonWidth, height: buttonHeight))
    let submitButtonTxt = (self.submitButtonText ?? "OK")
    submitButton.setTitle(submitButtonTxt as String, for: UIControlState())
    submitButton.addTarget(self, action: #selector(self.submitButtonTapped), for: .touchUpInside)
    submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    submitButton.setTitleColor((self.blurEffectStyle == .dark) ? UIColor.white : UIColor.black, for: UIControlState())
    submitButton.setTitleColor(UIColor.gray, for: .highlighted)
    submitButton.backgroundColor = (self.blurEffectStyle == .dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
    submitButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
    submitButton.layer.borderWidth = 0.5
    self.visualEffectView?.contentView.addSubview(submitButton)
    
    
    /**
     Adding the visual effects view.
     */
    self.visualEffectView!.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    self.addSubview(self.visualEffectView!)
  }
  
  func deviceOrientationDidChange () {
    self.resetFrame(true)
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
  public var customiseInputElement: ((_ element: UITextField) -> UITextField)!
  
  /// Closure executed when user submits the values.
  public var onSubmit: ((_ value: AnyObject...) -> Void)!
  
  /// As tuples are not supported in Objc, this is a method, which is called as well, but instead an array of values are returned
  public var onSubmitObjc: ((_ value: [AnyObject]) -> Void)!
  
  /// Closure executed when user cancels submission
  public var onCancel: (() -> Void)!
  
  /// Closure executed when the value changes in the field. The caller can modify the value and return it
  public var onChange: ((_ value: String) -> String)?
  
  func cancelButtonTapped () {
    if self.onCancel != nil {
      self.onCancel()
    }
    self.hide()
  }
  
  func submitButtonTapped () {
    
    // Submitting the form if valid
    if self.validateInput() {
      if self.onSubmit != nil {
        let valueToReturn: String? = self.textInput!.text
        
        if let value2ToReturn = self.secureInput?.text {
          
          self.onSubmit?(valueToReturn! as AnyObject, value2ToReturn as AnyObject)
        }
        else {
          self.onSubmit?(valueToReturn! as AnyObject)
        }
      }
      
      if self.onSubmitObjc != nil {
        let valueToReturn: String? = self.textInput!.text
        
        if let value2ToReturn = self.secureInput?.text {
          self.onSubmitObjc?([valueToReturn! as AnyObject, value2ToReturn as AnyObject])
        }
        else {
          self.onSubmitObjc?([valueToReturn! as AnyObject])
        }
      }
      
      self.hide()
    }
      
      // Shaking the validation label if not valid
    else {
      self.animateLabel()
    }
  }
  
  private func validateInput () -> Bool {
    
    if self.textInput?.text == "" && self.isOptional == true {
      return true
    }
    
    /**
     *  Validating the number input.
     */
    if self.style == .numberInput && (self.minimumValue != nil || self.maximumValue != nil) {
      
      if self.textInput?.text == "" {
        return false
      }
      
      let formatter = NumberFormatter()
      formatter.numberStyle = NumberFormatter.Style.decimal;
      
      // BMInputBoxStyleNumberInput is using a dot for decimals independent of the locale
      formatter.decimalSeparator = "."
      let userValue = formatter.number(from: self.textInput!.text!)!
      
      // Lower than minimum value
      if self.minimumValue != nil {
        if self.minimumValue.doubleValue > userValue.doubleValue {
          return false
        }
      }
      
      // Greater maximum value
      if self.maximumValue != nil {
        if self.maximumValue.doubleValue < userValue.doubleValue {
          return false
        }
      }
    }
    
    /**
     *  Validating the plain text input. Lenght of the text.
     */
    if self.style == .plainTextInput && (self.minimumLength != nil || self.maximumLength != nil) {
      if self.textInput?.text == "" {
        return false
      }
      
      // Lower than minimum value
      if self.minimumLength != nil {
        if self.minimumLength! > self.textInput!.text!.characters.count {
          return false
        }
      }
      
      // Greater maximum value
      if self.maximumLength != nil {
        if self.maximumLength! < self.textInput!.text!.characters.count {
          return false
        }
      }
    }
    
    return true
  }
  
  private func animateLabel () {
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = 0.07
    animation.repeatCount = 3
    animation.autoreverses = true
    animation.fromValue = NSValue(cgPoint: CGPoint(x: self.validationLabel.center.x - 8, y: self.validationLabel.center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: self.validationLabel.center.x + 8, y: self.validationLabel.center.y))
    self.validationLabel.layer.add(animation, forKey: "position")
  }
  
  func textInputDidChange () {
    
    // Custom onChange closure if available.
    if self.onChange != nil {
      self.textInput?.text = self.onChange!(self.textInput!.text!)
    }
    
    if (self.style == .numberInput) {
      var text: String = self.textInput!.text as String!
      text = text.replacingOccurrences(of: ".", with: "")
      
      let power = pow(10.0, Double(self.numberOfDecimals))
      let number: Double = Double(text)! / Double(power)
      let formatter = "%." + (String(format: "%i", self.numberOfDecimals) as String) + "lf"
      
      let formattedString = String(format: formatter, number)
      self.textInput?.text = formattedString as String
    }
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.endEditing(true)
  }
  
  // MARK: Keyboard Changes
  
  func keyboardDidShow (_ notification: Notification) {
    self.resetFrame(true)
    
    UIView.animate(withDuration: 0.2, animations: { () -> Void in
      var frame = self.frame
      frame.origin.y -= self.yCorrection()
      self.frame = frame
    })
  }
  
  func keyboardDidHide (_ notification: Notification) {
    self.resetFrame(true)
  }
  
  private func yCorrection () -> CGFloat {
    
    var yCorrection: CGFloat = 30.0
    
    if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
      if UIDevice.current.userInterfaceIdiom == .phone {
        yCorrection = 60.0
      }
      else if UIDevice.current.userInterfaceIdiom == .pad {
        yCorrection = 100.0
      }
      
      if self.style == .loginAndPasswordInput {
        yCorrection += 45.0
      }
      
    }
    else {
      if UIDevice.current.userInterfaceIdiom == .pad {
        yCorrection = 0.0
      }
    }
    return yCorrection
  }
  
  private func resetFrame (_ animated: Bool) {
    let topMargin: CGFloat = (self.style == .loginAndPasswordInput) ? 0.0 : 45.0
    let window = UIApplication.shared.windows.first as UIWindow!
    
    
    if animated {
      UIView.animate(withDuration: 0.3, animations: { () -> Void in
        self.center = CGPoint(x: (window?.center.x)!, y: (window?.center.y)! - topMargin)
      })
    }
    else {
      self.center = CGPoint(x: (window?.center.x)!, y: (window?.center.y)! - topMargin)
    }
  }
}
