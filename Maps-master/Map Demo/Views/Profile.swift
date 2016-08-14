import Foundation
import UIKit

class Profile: UIViewController {
    
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var teamLabel: UILabel!
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        scrollView.frame = self.view.bounds; // Instead of using auto layout
        scrollView.contentSize.height = self.view.frame.size.height
        
        let username = NSUserDefaults.standardUserDefaults().stringForKey(Constants.User.USERNAME)!
        let team = NSUserDefaults.standardUserDefaults().stringForKey(Constants.User.TEAM)!
        
        usernameLabel.text = "Username " + username
        teamLabel.text = "Team " + team
    }
    
    
    /* Button Methods
    /////////////////////////////////////////// */
    @IBAction func infoButtonPressed(sender: UIButton){
        let alert = UIAlertController(title: "Info", message: "1. Long press on map to add a Pokemon you have seen 2. Press pin icon in Pokemon annotation to map route to catch Pokemon", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in }))
        presentViewController(alert, animated: true, completion: nil)
    }
}