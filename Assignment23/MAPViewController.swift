/*
 Made by Navpreet Kaur
 This class contains all the code for displaying a map and showing the users current location
 */
import UIKit
import CoreLocation
import MapKit

class MAPViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    //Global variables
    let locationManager = CLLocationManager()
    // sheridan college brampton
    let initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534)
    let location2 = CLLocation(latitude: 43.6506, longitude: 79.7345)
    let location3 = CLLocation(latitude: 43.6761, longitude:  -79.4105)
    @IBOutlet var myMapView : MKMapView!
    @IBOutlet var tbLocEntered: UITextField!
    @IBOutlet var myTableView: UITableView!
    
    var routeSteps  = ["Enter a destination to see the steps"] as NSMutableArray
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        centerMapOnLocation(location: initialLocation)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "Player 1"
        self.myMapView.addAnnotation(dropPin)
        self.myMapView.selectAnnotation( dropPin, animated: true)
        
    
    }

    @IBAction func findNewLocation()
    {
        // Step 2.1 get location text
        let locEnteredText = tbLocEntered.text
        
        
        // Step 2.2 convert text input to lat-lng
        // using CLGeocoder object
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locEnteredText!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                
                // Step 2.3 - convert location into lat-lng
                // and then center map there and drop a pin.
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                self.centerMapOnLocation(location: newLocation)
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = locEnteredText
                self.myMapView.addAnnotation(dropPin)
                self.myMapView.selectAnnotation( dropPin, animated: true)
                
                // Step 3 - Calculate directions
                let request = MKDirectionsRequest()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate:
                    self.initialLocation.coordinate,  addressDictionary: nil))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                request.requestsAlternateRoutes = false
                request.transportType = .automobile
                
                let directions = MKDirections(request: request)
                directions.calculate (completionHandler: { [unowned self] response, error in
                    // guard let unwrappedResponse = response else { return }
                    
                    for route in (response?.routes)! {
                        self.myMapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                        self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        self.routeSteps.removeAllObjects()
                        for step in route.steps {
                            self.routeSteps.add(step.instructions)
                            
                            self.myTableView.reloadData();
                        }
                        
                    }
                })
                
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0;
        return renderer
    }
    
    
    // Step 0 - create a generic method to center
    // map at the desired location
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        myMapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        
        tableCell.textLabel?.text = routeSteps[indexPath.row] as? String
        
        return tableCell
        
    }

}
