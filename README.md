# BMInputBox

BMInputBox is an iOS drop-in class wrote in Swift that displays input boxes for the user to input different kinds of data, for instance username and password, email address, numbers, plain text. BMInputBox is meant as a replacement for the limited UIAlertView input options.

![alt tag](http://blackmirror.media/wp-content/uploads/2016/04/BMInputBoxPlainText.png)
![alt tag](http://blackmirror.media/wp-content/uploads/2016/04/BMInputBoxLogin.png)
![alt tag](http://blackmirror.media/wp-content/uploads/2016/04/BMInputBoxLoginFilled.png)

## Requirements

Built in Swift 3 for iOS 8.0+. All devices supported. BMInputBox can be used in both Swift and in ObjectiveC projects. 

You will need Xcode 8 for version 1.3.x and above.
You will need Xcode 7 for version 1.2.x and above.

For older projects using Swift 2, use version 1.2.x.
For older projects using Swift 1.2, use version 1.1.3.

## Adding BMInputBox To Your Project

### CocoaPods

CocoaPods is the recommended way to add BMInputBox to your project. As BMInputBox is written in Swift, you need to add the `use_frameworks!` option to your podfile.

```
pod 'BMInputBox'
```

## Usage

Import the module to your project.

```Swift
import BMInputBox
```

### Creating an input box

```Swift
let inputBox = BMInputBox.boxWithStyle(.NumberInput)
inputBox.show()
```

Available styles:
* `.plainTextInput` - Simple text field
* `.numberInput` - Text field accepting numbers only - numeric keyboard
* `.phoneNumberInput` - Text field accepting numbers only - phone keyboard
* `.emailInput` - Text field accepting email addresses -  email keyboard
* `.secureTextInput` - Secure text field for passwords
* `.loginAndPasswordInput` - Two text fields for user and password entry

### Customising the box

#### Blur Effect

UIBlurEffectStyle: .extraLight, .light, .dark

```Swift
inputBox.blurEffectStyle = .light
```

#### Custom Texts And I18n

You can set a custom text for all the components in the view.
See also the Validation section.

```Swift
inputBox.title = NSLocalizedString("This Is The Title", comment: "")
inputBox.message = NSLocalizedString("This is the message in the view, can be as long as three lines.", comment: "")
inputBox.submitButtonText = NSLocalizedString("OK", comment: "")
inputBox.cancelButtonText = NSLocalizedString("Cancel", comment: "")
inputBox.validationLabelText = NSLocalizedString("Text must be 6 characters long.", comment: "")
```

#### Mandatory Decimals

For the .NumberInput type. Default is 0. If set, the user input will be convertd to Double with 2 decimals. For instance "1" becomes "0.01" and "1234" becomes "12.34".

```Swift
inputBox.numberOfDecimals = 2
```

#### Going Crazy

Doing whatever you need with the textField in the box.

```Swift
inputBox.customiseInputElement = {(element: UITextField) in
  element.placeholder = "Custom placeholder"
  if element.secureTextEntry == true {
    element.placeholder = "Secure placeholder"
  }
  return element
}
```

### Validation

#### Minimum And Maximum Values
Setting minimum and maximum values for the .NumberInput type. Shows a message to the user below the textField. The entered value is validated against these values.

Setting a minimum value:

```Swift
inputBox.minimumValue = 10
inputBox.validationLabelText = "A number greater %@."
```

Setting minimum and maximum values:

```Swift
inputBox.minimumValue = 10
inputBox.maximumValue = 30
inputBox.validationLabelText = "A number between %@ and %@."
```

#### Text Length
Setting minimum and maximum lenght of the entered text. If the values are the same, it will check for an exact length.

```Swift
inputBox.minimumLenght = 4
inputBox.maximumLength = 6
inputBox.validationLabelText = "A text between %i and %i characters."
```

#### Optional Input

When setting the box to be `optional`, nil values will be accepted as well. 
However, if text is entered, it will be validated agains the rest of the properties above.

```Swift
inputBox.isOptional = true
```


### Closures For Events

#### Submit

```Swift
inputBox.onSubmit = {(value: AnyObject...) in
  for text in value {
    if text is String {
      NSLog("%@", text as String)
    }
    else if text is NSDate {
      NSLog("%@", text as NSDate)
    }
    else if text is Int {
      NSLog("%i", text as Int)
    }
  }
}
```

#### Cancel

```Swift
inputBox.onCancel = {
  NSLog("Cancelled")
}
```

Tuples in Objective C are not supported, therefore, you have to use the `onSubmitObjc` closure if your project is in Objective C. This returns an array with the values of the Input Box.

```Swift
inputBox.onSubmitObjc = {(values: [AnyObject]) in
  for text in values {
    if text is String {
      NSLog("%@", text as String)
    }
    else if text is NSDate {
      NSLog("%@", text as NSDate)
    }
    else if text is Int {
      NSLog("%i", text as Int)
    }
  }
}
```

#### Change

You can interact with the text as it is being entered. The closure is tied to the `.editingChanged` event of the UITextField.

```Swift
inputBox.onChange = {(value: String) in
  return value.uppercaseString
}
```
