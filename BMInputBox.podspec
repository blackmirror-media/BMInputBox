#
# Be sure to run `pod lib lint BMInputBox.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BMInputBox"
  s.version          = "1.2.2"
  s.summary          = "Drop-in replacement for the limited UIAlertView input options."
  s.description      = <<-DESC
                       BMInputBox is an iOS drop-in class wrote in Swift that displays input boxes for the user to input different kinds of data, for instance username and password, email address, numbers, plain text. BMInputBox is meant as a replacement for the limited UIAlertView input options.
                       DESC
  s.homepage         = "https://github.com/blackmirror-media/BMInputBox"
  s.screenshots      = "http://blackmirror.media/wp-content/uploads/2016/04/BMInputBoxPlainText.png", "http://blackmirror.media/wp-content/uploads/2016/04/BMInputBoxLogin.png", "http://blackmirror.media/wp-content/uploads/2016/04/BMInputBoxLoginFilled.png"
  s.license          = 'MIT'
  s.author           = { "Adam Eri" => "adam.eri@blackmirror-media.co.uk" }
  s.source           = { :git => "https://github.com/blackmirror-media/BMInputBox.git", :tag => s.version.to_s }
 

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
