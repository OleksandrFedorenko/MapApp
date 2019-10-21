//
//  SecondViewController.swift
//  fuckingHard
//
//  Created by Nazar NAUMENKO on 4/14/19.
//  Copyright © 2019 Alex FEDORENKO. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class SecondViewController: UIViewController, UISearchBarDelegate,MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var button: UIBarButtonItem!
    @IBOutlet weak var sourceLabel: UITextField!
    @IBOutlet weak var destinationLabel: UITextField!
    
    var error1 = true
    var error2 = true
    
    func isSameLocations() -> Bool{
        if (sourceLocation.latitude == destinationLocation.latitude && sourceLocation.longitude == destinationLocation.longitude ) {
            let alert = UIAlertController(title: "Error", message: "Locations should be different", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    

    
    
    @IBAction func buttonDone(_ sender: UIBarButtonItem) {
        
        button.isEnabled = false
        destinationName = destinationLabel.text!
        sourceName = sourceLabel.text!
        
        let Request = MKLocalSearchRequest()

        Request.naturalLanguageQuery = sourceName
        let activeSearchSource = MKLocalSearch(request: Request)
        activeSearchSource.start(completionHandler: searchHandlerSource)
        
        Request.naturalLanguageQuery = destinationName
        let activeSearchDestination = MKLocalSearch(request: Request)
        activeSearchDestination.start(completionHandler: searchHandlerDestination)
    }
    
    
    
    func locationNotFound() -> (){
        let alert = UIAlertController(title: "Error", message: "Location not found ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func searchHandlerSource(response: MKLocalSearchResponse?, error: Error?){
        UIApplication.shared.endIgnoringInteractionEvents()
        if response == nil
        {
            button.isEnabled = true
            //Ерор якщо адрес не найдено
            print("error")
            error1 = true
            // ерор винесений в окрему функцію locationNotFaound
            self.locationNotFound()
            return
        }

        let latitude = response?.boundingRegion.center.latitude
        let longitude = response?.boundingRegion.center.longitude

        sourceLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
        print("sourceLocation", sourceLocation)
        error1 = false
        ifNoError()
    }
    
    func searchHandlerDestination(response: MKLocalSearchResponse?, error: Error?){
        UIApplication.shared.endIgnoringInteractionEvents()
        if response == nil
        {
            button.isEnabled = true
            //Ерор якщо адрес не найдено
            print("error")
            error2 = true
            // ерор винесений в окрему функцію locationNotFaound
            self.locationNotFound()
            return
        }
        
        let latitude = response?.boundingRegion.center.latitude
        let longitude = response?.boundingRegion.center.longitude
        destinationLocation = CLLocationCoordinate2DMake(latitude!, longitude!)
        print("desinationLocation", destinationLocation)
        error2 = false
        ifNoError()
    }
    
    @IBOutlet weak var segmentControllerSortFlag: UISegmentedControl!
    @IBOutlet weak var segmentControllerTransportType: UISegmentedControl!
    
    func ifNoError() {
        
        if !error1 && !error2 {
            
            if isSameLocations(){
                return
            }
            var index : Int!
            
            index = segmentControllerTransportType.selectedSegmentIndex
            transportType = segmentControllerTransportType.titleForSegment(at: index)
            
            index = segmentControllerSortFlag.selectedSegmentIndex
            sortingType = segmentControllerSortFlag.titleForSegment(at: index)
            button.isEnabled = true
            performSegue(withIdentifier: "unWindToFirst", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        error1 = true
        error2 = true
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
