//
//  ViewController.swift
//  fuckingHard
//
//  Created by Alex FEDORENKO on 4/7/19.
//  Copyright © 2019 Alex FEDORENKO. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation

var sourceName : String!
var destinationName: String!
var sourceLocation : CLLocationCoordinate2D!
var destinationLocation: CLLocationCoordinate2D!
var transportType: String!
var sortingType: String!

class ViewController: UIViewController , UISearchBarDelegate,MKMapViewDelegate, CLLocationManagerDelegate{
    
    
    
    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    var searchName : String!
    var i = 0

    
    
    @IBAction func apModeChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index{
        case 0: map.mapType = MKMapType.standard
        case 1: map.mapType = MKMapType.satellite
        case 2: map.mapType = MKMapType.hybrid
        default: break
        }
    }
    
    
    
    var currentColor = 0
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        let colors = [UIColor.blue, UIColor.red, UIColor.yellow, UIColor.green]
        let annotationView = MKPinAnnotationView()
        annotationView.pinTintColor = colors[currentColor % colors.count]
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton()
        currentColor += 1;
        return annotationView
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location Updated")
        let location = locations[0]
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
    }
    
    
    
    
    var currentRouteIndex = 0
    var globalRoute: [MKRoute] = []
    @IBAction func nextPath(_ sender: Any) {
    
        if (currentPolyline == nil || globalRoute.count == 0) {
            return
        }
        
        map.removeOverlays([currentPolyline])
        currentRouteIndex += 1
        if (currentRouteIndex == globalRoute.count) {
            currentRouteIndex = 0
        }
        currentPolyline = globalRoute[currentRouteIndex].polyline
        self.map.add(currentPolyline, level: .aboveRoads)
        
        currentDistance = globalRoute[currentRouteIndex].distance
        currentTime = globalRoute[currentRouteIndex].expectedTravelTime
        
        infoDistanceValue.text = "\(Int64(currentDistance / 1000.0))km"
        let hours = Int64(currentTime / 60 / 60)
        let minutes = Int64(currentTime / 60) - Int64(hours * 60)
        infoTimeValue.text = "\(hours)h \(minutes)m"
        
    }
    
    @IBAction func showRouteIndo(_ sender: Any) {
        
        if currentPolyline == nil{
            return
        }
        
        if (infoTime.isHidden == true) {
            infoDistance.isHidden = false
            infoTime.isHidden = false
            infoDistanceValue.isHidden = false
            infoTimeValue.isHidden = false
            //currentPolyline.
            infoDistanceValue.text = "\(Int64(currentDistance / 1000.0))km"
            let hours = Int64(currentTime / 60 / 60)
            let minutes = Int64(currentTime / 60) - Int64(hours * 60)
            infoTimeValue.text = "\(hours)h \(minutes)m"
            
            
            
            
            
        }
        else {
            infoDistance.isHidden = true
            infoTime.isHidden = true
            infoDistanceValue.isHidden = true
            infoTimeValue.isHidden = true
        }
        
    }
    
    
    @IBOutlet weak var infoDistance: UILabel!
    @IBOutlet weak var infoTime: UILabel!
    @IBOutlet weak var infoDistanceValue: UILabel!
    @IBOutlet weak var infoTimeValue: UILabel!
    
    
    @IBAction func clearMap(_ sender: Any) {
        if (currentPolyline != nil) {
            map.removeOverlays([currentPolyline])
        }
        let annotations = self.map.annotations
        self.map.removeAnnotations(annotations)
    }
    
    
    @IBAction func startLocate(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        let location = map.userLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.map.setRegion(region, animated: true)
        print("button")
    }
    
    
    
    @IBAction func searchButton(_ sender: Any)
    {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        searchName = search.searchBar.text!/////
        present(search, animated: true, completion: nil)
    }
    
    
    //функція відповідає за пошук!!!!!
    func finalCoordFirst(_ first: Double, _ second: Double) -> (){
        let one: Double = first
        let two: Double = second
        print(one, two)
    }
    
    
    
    func finalCoordSecond(_ first: Double, _ second: Double) -> (){
        let one: Double = first
        let two: Double = second
        print(one, two)
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        UIApplication.shared.beginIgnoringInteractionEvents()
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        let Request = MKLocalSearchRequest()
        Request.naturalLanguageQuery = searchBar.text
        inizalization()
        let activeSearch = MKLocalSearch(request: Request)
        activeSearch.start(completionHandler: searchHandler)
    }

    
    
    func searchHandler(response: MKLocalSearchResponse?, error: Error?){
        UIApplication.shared.endIgnoringInteractionEvents()
        if response == nil
        {
            //Ерор якщо адрес не найдено
            print("error")
            // ерор винесений в окрему функцію locationNotFaound
            self.locationNotFound()
            return
        }
        //Remove Annotations
        let annotations = self.map.annotations
        self.map.removeAnnotations(annotations)
        //Getting data
        let latitude = response?.boundingRegion.center.latitude
        let longitude = response?.boundingRegion.center.longitude
        let annotation = MKPointAnnotation()
        annotation.title = searchName
        annotation.subtitle = searchName
        annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.map.addAnnotation(annotation)
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        print(coordinate)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.map.setRegion(region, animated: true)
        //В змінній кординати зберігаються координати точки яка була знайдена
    }

    
    
    func inizalization(){
        let Indicator = UIActivityIndicatorView()
        Indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        Indicator.center = self.view.center
        Indicator.hidesWhenStopped = true
        Indicator.startAnimating()
        Indicator.stopAnimating()
        self.view.addSubview(Indicator)
    }
    
    
    
    func locationNotFound() -> (){
        let alert = UIAlertController(title: "Error", message: "Location not found ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 3.0
        return renderer
    }
    
    
    
    func makeRoute() {
        
        let placemark1 = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let placemark2 = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let annotation1 = MKPointAnnotation()
        let annotation2 = MKPointAnnotation()
        
        if (placemark1.location == nil) {
            return
        }
        if (placemark2.location == nil) {
            return
        }
        
        annotation1.title = sourceName
        annotation2.title = destinationName
        
        annotation1.coordinate = (placemark1.location?.coordinate)!
        annotation2.coordinate = (placemark2.location?.coordinate)!
        self.map.showAnnotations([annotation1,annotation2], animated: true)
        
        let mapItem1 = MKMapItem(placemark: placemark1)
        let mapItem2 = MKMapItem(placemark: placemark2)
        
        let request = MKDirectionsRequest()
        request.source = mapItem1
        request.destination = mapItem2
        request.requestsAlternateRoutes = true
        switch transportType {
        case "Ножками": request.transportType = .walking
        case "By Car":  request.transportType = .automobile
        default: break
        }
        
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: directionHandler)
    }
    
    var currentPolyline : MKPolyline!
    var currentDistance : CLLocationDistance!
    var currentTime : TimeInterval = 0.0
    func directionHandler(response: MKDirectionsResponse?, error: Error?) {
        if let response = response{
           
            var allRoutes = response.routes
            
            switch sortingType {
            case "Distance": allRoutes = allRoutes.sorted{$0.distance < $1.distance}
            case "Expected travel time": allRoutes = allRoutes.sorted{$0.expectedTravelTime < $1.expectedTravelTime}
            default: break
            }
            
            let route = allRoutes[0]
            globalRoute = allRoutes
            self.map.add(route.polyline, level: .aboveRoads)
            
            //let rect = route.polyline.boundingMapRect
            //self.map.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            currentPolyline = route.polyline
            currentDistance = route.distance
            currentTime = route.expectedTravelTime
        }
        if error != nil{
            routeNotFound()
        }
    }
    
    
    func routeNotFound() {
        let alert = UIAlertController(title: "Error", message: "Route not found ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        map.showsUserLocation = true
        infoDistance.isHidden = true
        infoTime.isHidden = true
        infoDistanceValue.isHidden = true
        infoTimeValue.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        infoDistance.isHidden = true
        infoTime.isHidden = true
        infoDistanceValue.isHidden = true
        infoTimeValue.isHidden = true
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        infoDistance.isHidden = true
//        infoTime.isHidden = true
//        infoDistanceValue.isHidden = true
//        infoTimeValue.isHidden = true
//    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
      
        if (currentPolyline != nil) {
            map.removeOverlays([currentPolyline])
        }
        let annotations = self.map.annotations
        self.map.removeAnnotations(annotations)
        makeRoute()
    }
    
    var previousValue = 0
    @IBAction func stepperChanged(_ sender: UIStepper) {
        let currentValue = Int(sender.value)
        var latitudeDelta = map.region.span.latitudeDelta
        var longitudeeDelta = map.region.span.longitudeDelta
        
        if currentValue > previousValue {
            latitudeDelta = latitudeDelta / 1.2
            longitudeeDelta = longitudeeDelta / 1.2
        }
        else {
            latitudeDelta = latitudeDelta * 1.2
            longitudeeDelta = longitudeeDelta * 1.2
        }
        
        let center = map.centerCoordinate
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeeDelta)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        self.map.setRegion(region, animated: true)
        previousValue = currentValue
    }
    
    
    
}

