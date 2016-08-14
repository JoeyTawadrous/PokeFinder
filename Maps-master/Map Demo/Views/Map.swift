import MapKit
import Foundation
import UIKit
import CoreLocation
import GoogleMobileAds

class Map: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GADInterstitialDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var isInitialized = false
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var map: MKMapView!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        // add long press action
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(Map.userAddLocation(_:)))
        longPress.minimumPressDuration = 0.5
        map.addGestureRecognizer(longPress)
        
        
        // get pokemon and create pins
        self.sendPost("getPokemon=true")
        
        
        // load ads
        self.showBannerAd()
        NSTimer.scheduledTimerWithTimeInterval(240, target: self, selector: #selector(self.showFullScreenAd), userInfo: nil, repeats: true)
    }
    
    
    
    /* Ad Methods
    /////////////////////////////////////////// */
    func showBannerAd() {
        self.bannerView.adUnitID = "ca-app-pub-0874165521080747/9148516314" // Test: ca-app-pub-3940256099942544/2934735716
        self.bannerView.rootViewController = self
        self.bannerView.loadRequest(GADRequest())
    }
    
    func showFullScreenAd() {
        let App = UIApplication.sharedApplication().delegate as! AppDelegate
        App.adViewController = self;
        App.showFullScreenAd()
    }

    
    
    /* Button Methods
    /////////////////////////////////////////// */
    @IBAction func refreshButtonPressed(sender: UIButton){
        self.map.removeAnnotations(self.map.annotations)
        self.sendPost("getPokemon=true")
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation, MKCoordinateSpanMake(CLLocationDegrees(0.05), CLLocationDegrees(0.05)))
        self.map.setRegion(region, animated: true)
    }
    
    
    
    /* Map Methods
    /////////////////////////////////////////// */
    func addAnnotationToMap(location: CLLocationCoordinate2D, name: String) {
        
        var allPokemon = Array(arrayLiteral: "Bulbasaur","Ivysaur","Venusaur","Charmander","Charmeleon","Charizard","Squirtle","Wartortle","Blastoise","Caterpie","Metapod","Butterfree","Weedle","Kakuna","Beedrill","Pidgey","Pidgeotto","Pidgeot","Rattata","Raticate","Spearow","Fearow","Ekans","Arbok","Pikachu","Raichu","Sandshrew","Sandslash","Nidoran","Nidorina","Nidoqueen","Nidoran","Nidorino","Nidoking","Clefairy","Clefable","Vulpix","Ninetales","Jigglypuff","Wigglytuff","Zubat","Golbat","Oddish","Gloom","Vileplume","Paras","Parasect","Venonat","Venomoth","Diglett","Dugtrio","Meowth","Persian","Psyduck","Golduck","Mankey","Primeape","Growlithe","Arcanine","Poliwag","Poliwhirl","Poliwrath","Abra","Kadabra","Alakazam","Machop","Machoke","Machamp","Bellsprout","Weepinbell","Victreebel","Tentacool","Tentacruel","Geodude","Graveler","Golem","Ponyta","Rapidash","Slowpoke","Slowbro","Magnemite","Magneton","Farfetch'd","Doduo","Dodrio","Seel","Dewgong","Grimer","Muk","Shellder","Cloyster","Gastly","Haunter","Gengar","Onix","Drowzee","Hypno","Krabby","Kingler","Voltorb","Electrode","Exeggcute","Exeggutor","Cubone","Marowak","Hitmonlee","Hitmonchan","Lickitung","Koffing","Weezing","Rhyhorn","Rhydon","Chansey","Tangela","Kangaskhan","Horsea","Seadra","Goldeen","Seaking","Staryu","Starmie","Mr. Mime","Scyther","Jynx","Electabuzz","Magmar","Pinsir","Tauros","Magikarp","Gyarados","Lapras","Ditto","Eevee","Vaporeon","Jolteon","Flareon","Porygon","Omanyte","Omastar","Kabuto","Kabutops","Aerodactyl","Snorlax","Articuno","Zapdos","Moltres","Dratini","Dragonair","Dragonite","Mewtwo","Mew");
        
        let pokemonName = allPokemon[Int(name)!-1]
        
        var imageNumber = ""
        if String(name).characters.count == 1 {
            imageNumber = "00" + String(name)
        }
        if String(name).characters.count == 2 {
            imageNumber = "0" + String(name)
        }
        else if String(name).characters.count == 3 {
            imageNumber = String(name)
        }
        let imageName = imageNumber + "-" + pokemonName + "-icon.png"
        
        
        let annotation = CustomAnnotation()
        annotation.coordinate = location
        annotation.title = pokemonName + " seen here!"
        annotation.subtitle = "< Track"
        annotation.imageName = imageName
        
        self.map.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomAnnotation) {
            return nil
        }
        
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view!.canShowCallout = true
        }
        else {
            view!.annotation = annotation
        }
        
        
        let customAnnotation = annotation as! CustomAnnotation
        view!.image = UIImage(named:customAnnotation.imageName)
        
        
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.frame.size.width = 44
        button.frame.size.height = 44
        button.setImage(UIImage(named: "location"), forState: .Normal)
        view!.leftCalloutAccessoryView = button
        
        
        return view
    }
    
    /* This will draw a line from the users current location to the location of the pin they tapped the button on
    *******************************/
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? CustomAnnotation {
            self.map.removeOverlays(self.map.overlays) // reset
            
            let destinationLocation = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            let sourcePlacemark = MKPlacemark(coordinate: self.currentLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .Automobile
            
            // Calculate the direction
            let directions = MKDirections(request: directionRequest)
            directions.calculateDirectionsWithCompletionHandler {(response, error) -> Void in
                guard let response = response else {
                    if let error = error {
                        let alert = UIAlertController(title: "Wow!", message: "That's way too far to plot a route to catch the Pokemon!!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                let route = response.routes[0]
                self.map.addOverlay((route.polyline), level: MKOverlayLevel.AboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orangeColor()
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func userAddLocation(gesture: UIGestureRecognizer) {
        let location: CLLocationCoordinate2D = self.map.convertPoint(gesture.locationInView(self.map), toCoordinateFromView: self.map)
        
        
        NSUserDefaults.standardUserDefaults().setObject(location.latitude.description, forKey: Constants.Pokemon.LATITUDE)
        NSUserDefaults.standardUserDefaults().setObject(location.longitude.description, forKey: Constants.Pokemon.LONGITUDE)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("AddPokemon") as UIViewController
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
            
            
            if(params.containsString("getPokemon")) {
                let allPokemon: NSMutableArray = urlContents.parseJSONString!
                
                for pokemon in allPokemon {
                    let name = pokemon["name"] as! String
                    let latitude = pokemon["latitude"] as! String
                    let longitude = pokemon["longitude"] as! String
                    
                    let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!, CLLocationDegrees(longitude)!)
                    self.addAnnotationToMap(location, name: name)
                }
            }
        }
        
        task.resume()
    }
    
    
    
    /* Location Manager
    /////////////////////////////////////////// */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isInitialized {
            isInitialized = true
            
            let userLoction: CLLocation = locations[0]
            let latitude = userLoction.coordinate.latitude
            let longitude = userLoction.coordinate.longitude
            self.currentLocation = CLLocationCoordinate2DMake(latitude, longitude)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(self.currentLocation, MKCoordinateSpanMake(CLLocationDegrees(0.05), CLLocationDegrees(0.05)))
            self.map.setRegion(region, animated: true)
            self.map.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}


class CustomAnnotation: MKPointAnnotation {
    var imageName: String!
}

extension String {
    var parseJSONString: NSMutableArray? {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            do {
                let message = try NSJSONSerialization.JSONObjectWithData(jsonData, options:.MutableContainers)
                if let jsonResult = message as? NSMutableArray {
                    return jsonResult
                }
                else {
                    return nil
                }
            }
            catch let error as NSError {
                print("An error occurred: \(error)")
                return nil
            }
        }
        else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}
