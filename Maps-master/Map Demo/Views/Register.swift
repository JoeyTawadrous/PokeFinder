import Foundation
import UIKit

class Register: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var teamSegmentedControl: UISegmentedControl!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    
    
    
    override func viewDidLoad() {
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        signupButton.layer.cornerRadius = 5
        
        teamSegmentedControl.subviews[0].tintColor = UIColor.yellowColor()
        teamSegmentedControl.subviews[1].tintColor = UIColor.blueColor()
        teamSegmentedControl.subviews[2].tintColor = UIColor.redColor()
    }
    
    
    /* Button Methods
    /////////////////////////////////////////// */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton){
        let presentingViewController: UIViewController! = self.presentingViewController
        self.dismissViewControllerAnimated(false) {
            presentingViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    @IBAction func registerButtonPressed(sender: UIButton){
        if usernameTextField.text! == "" || emailTextField.text! == "" || !(emailTextField.text?.containsString("@"))! || passwordTextField.text! == "" {
            self.presentViewController(Utils.showOkButtonAlert("Please ensure all fields are filled in correctly."), animated: true, completion: nil)
        }
        else {
            var params = "checkUser=true"
            params = params + "&username=" + usernameTextField.text!
            params = params + "&email=" + emailTextField.text!
            self.sendPost(params)
        }
    }
    
    func registerUser() {
        // set data in defaults
        NSUserDefaults.standardUserDefaults().setObject(usernameTextField.text, forKey: Constants.User.USERNAME)
        NSUserDefaults.standardUserDefaults().setObject(teamSegmentedControl.titleForSegmentAtIndex(teamSegmentedControl.selectedSegmentIndex)!, forKey: Constants.User.TEAM)
        
        var params = "addUser=true"
        params = params + "&username=" + usernameTextField.text!
        params = params + "&email=" + emailTextField.text!
        params = params + "&password=" + Utils.md5(passwordTextField.text!) // md5 encryption
        params = params + "&team=" + teamSegmentedControl.titleForSegmentAtIndex(teamSegmentedControl.selectedSegmentIndex)!
        self.sendPost(params)
    }
    

    
    /* POST Methods
    /////////////////////////////////////////// */
    func sendPost(params: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://applandr.com/Pokemon/actions.php")!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        
        let task = session.downloadTaskWithRequest(request) {(let location, let response, let error) in
            guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                return
            }
            let urlContents: String = try! NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding) as String
            guard let _:NSString = urlContents else {
                return
            }
            
            
            
            if params.containsString("checkUser")  {
                if urlContents.containsString("username exists") {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(Utils.showOkButtonAlert("Username already exists. Please choose another."), animated: true, completion: nil)
                    })
                }
                else if urlContents.containsString("email exists") {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(Utils.showOkButtonAlert("Email already exists. Please choose another."), animated: true, completion: nil)
                    })
                }
                else {
                    self.registerUser()
                }
            }
            else if params.containsString("addUser") {
                if urlContents.containsString("success") {
                    // show map
                    dispatch_async(dispatch_get_main_queue(), {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewControllerWithIdentifier("Map") as UIViewController
                        self.presentViewController(vc, animated: true, completion: nil)
                    })
                }
                else if urlContents.containsString("failure")  {
                    self.presentViewController(Utils.showOkButtonAlert("Could not register due to server load. Please mail joeytawadrous@gmail.com for more info."), animated: true, completion: nil)
                }
            }
        }
        
        task.resume()
    }
}