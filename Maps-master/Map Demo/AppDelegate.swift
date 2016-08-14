import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADInterstitialDelegate {

    var window: UIWindow?
    var adViewController: UIViewController?
    var fullScreenAd: GADInterstitial!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func showFullScreenAd() {
        let id = "ca-app-pub-0874165521080747/1625249516"; // Test: ca-app-pub-3940256099942544/4411468910
        self.fullScreenAd = GADInterstitial.init(adUnitID: id)
        
        self.fullScreenAd.delegate = self
        let Request  = GADRequest()
//        Request.testDevices = ["5122115a9514303c3e4cf8893c96c394"]
        self.fullScreenAd.loadRequest(Request)
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        ad.presentFromRootViewController(self.adViewController!)
    }
}

