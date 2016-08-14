import Foundation
import UIKit

class Login: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        if NSUserDefaults.standardUserDefaults().stringForKey(Constants.User.USERNAME) != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("Map") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.layer.cornerRadius = 5
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
    
    @IBAction func registerButtonPressed(sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Register") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton){
        if usernameTextField.text == "" || passwordTextField.text == "" {
            self.presentViewController(Utils.showOkButtonAlert("Please ensure username and passowrd are filled in."), animated: true, completion: nil)
        }
        else {
            // set data in defaults
            NSUserDefaults.standardUserDefaults().setObject(usernameTextField.text, forKey: Constants.User.USERNAME)
            
            var params = "getUser=true"
            params = params + "&username=" + usernameTextField.text!
            params = params + "&password=" + Utils.md5(passwordTextField.text!) // md5 encryption
            self.sendPost(params)
        }
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
            
            
            let reply: NSMutableArray = urlContents.parseJSONString!
            let status: String? = reply[0].valueForKey("status") as? String
            
            if status == "success" {
                dispatch_async(dispatch_get_main_queue(), {
                    let team: String? = reply[0].valueForKey(Constants.User.TEAM) as? String
                    NSUserDefaults.standardUserDefaults().setObject(team, forKey: Constants.User.TEAM)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("Map") as UIViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(Utils.showOkButtonAlert("Username / password combination does not exist! Please try agian.."), animated: true, completion: nil)
                })
            }
        }
        
        task.resume()
    }
}