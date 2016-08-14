import Foundation
import UIKit

class AddPokemon: UIViewController {
    
    
    @IBOutlet var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = self.view.bounds
        scrollView.contentSize.height = self.view.bounds.height * 4
    
        NSUserDefaults.standardUserDefaults().setObject("Joey", forKey: Constants.User.USERNAME) // TODO: remove

        
        var across = CGFloat(5)
        var down = CGFloat(20)
        var index = 1
        
        let filemanager:NSFileManager = NSFileManager()
        let files = filemanager.enumeratorAtPath(NSBundle.mainBundle().bundlePath)
        while let file = files?.nextObject() {
            if file.containsString("-icon.png") {
                let fileName = file as! String
                
                let button = UIButton(type: UIButtonType.Custom)
                button.frame = CGRectMake(across, down, self.view.frame.size.width / 5, self.view.frame.size.width / 5) // 414
                button.setImage(UIImage(named: fileName), forState: .Normal)
                button.addTarget(self, action: #selector(pokemonButtonPressed), forControlEvents: .TouchUpInside)
                button.tag = Int(String(fileName.characters.prefix(3)))!
                self.scrollView.addSubview(button)
                
                across = across + self.view.frame.size.width / 5
                if index % 5 == 0 {
                    down = down + self.view.frame.size.width / 5
                    across = 5
                }
                index = index + 1
            }
        }
    }

    
    /* Button Methods
    /////////////////////////////////////////// */
    @IBAction func pokemonButtonPressed(sender: UIButton){
        var params = "addPokemon=true"
        params = params + "&username=" + NSUserDefaults.standardUserDefaults().stringForKey(Constants.User.USERNAME)!
        params = params + "&name=" + String(sender.tag)
        params = params + "&latitude=" + NSUserDefaults.standardUserDefaults().stringForKey(Constants.Pokemon.LATITUDE)!
        params = params + "&longitude=" + NSUserDefaults.standardUserDefaults().stringForKey(Constants.Pokemon.LONGITUDE)!
        self.sendPost(params)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Map") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonPressed(sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("Map") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
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
        }
        
        task.resume()
    }
    

}

