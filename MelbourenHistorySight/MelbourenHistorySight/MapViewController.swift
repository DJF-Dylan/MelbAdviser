//
//  MapViewController.swift
//  MelbourenHistorySight
//
//  Created by Lynn on 4/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//

import UIKit
import MapKit



class MapViewController: UIViewController,DatabaseListener,MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var mapViewController: MapViewController?
    var sightList = [Sight]()
    var locationList = [LocationAnnotation]()
    weak var databaseController: DatabaseProtocol?
    var selectedSightName: String?
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //locationManager?.delegate = self
        addAnnotations()
        
        let initialLocation = CLLocation(latitude: -37.8175485, longitude: 144.9674052)
        centerMapOnLocation(location: initialLocation)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Do any additional setup after loading the view.
        setGeofence()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "A History Sight is nearby", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /*func locationManager(_ manager: CLLocationManager, didExitRegion region:
        CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "A History Sight is nearby", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }*/
    func locationAnnotationAdded(annotation: LocationAnnotation) {
        
        locationList.append(annotation)
        mapViewController?.mapView.addAnnotation(annotation)
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func focusOn(annotation: LocationAnnotation){
        //mapView.selectAnnotation(annotation, animated: true)     
        //let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,longitudinalMeters: 1000)
        //mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        //mapView.centerCoordinate = annotation.coordinate
        mapView.setCenter(CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), animated: true)
    }
    
    
    
    // MARK: - Annotation data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType = ListenerType.sight
    
    func onSightListChange(change: DatabaseChange, sight: [Sight]) {
        removeAnnotations()
        sightList = sight
        self.viewDidLoad()
    }
    
    //add remove annotation
    func removeAnnotationFromMap(annotation: MKAnnotation) {
        self.mapView.removeAnnotation(annotation)
    }
    
    func removeAnnotations() {
        self.mapView.removeAnnotations(mapView.annotations)
    }
    
    func addAnnotations() {
        if sightList.count != 0{
            for index in (1...sightList.count){
                var location = LocationAnnotation(sight: sightList[index-1])
                var annotationList = [LocationAnnotation]()
                annotationList.append(location)
                locationList = annotationList
                mapView.addAnnotation(location)
            }
        }
    }
    func setGeofence(){
        if sightList.count != 0{
            for index in (1...sightList.count){
                var coordinate = CLLocationCoordinate2D(latitude: sightList[index-1].latitude, longitude: sightList[index-1].longitude)
                var geoLocation = CLCircularRegion(center: coordinate, radius: 500,identifier: sightList[index-1].name!)
                geoLocation.notifyOnEntry = true
                locationManager.delegate = self
                locationManager.requestAlwaysAuthorization()
                locationManager.startMonitoring(for: geoLocation)
            }
        }
    }
    //custom the annotation for all the sign on the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reUseId = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reUseId)
        
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reUseId)
        //print(" --- \(annotationView)")
        annotationView?.annotation = annotation
        
        var icon: UIImage?
        annotationView?.canShowCallout = true
        
        //get annotation's subtitle original image dont have this and new image have the image path in this var
        let imagePath = annotation.title as! String
        //print(imagePath)
        
        if UIImage(named: imagePath) == nil {
            let pathForOriginal = "default icon"
            icon = convertImage(image: UIImage(named: pathForOriginal)!, scaledToSize: CGSize(width: 30.0, height: 30.0))
        } else {
            icon = convertImage(image: UIImage(named: imagePath)!, scaledToSize: CGSize(width: 30.0, height: 30.0))
        }
        UIGraphicsEndImageContext()
        
        //set the custom icon to the annotation view image
        annotationView?.image = icon
        
        //show informatin icon on the right side
        let rightButton: AnyObject! = UIButton(type: UIButton.ButtonType.detailDisclosure)
        annotationView?.rightCalloutAccessoryView = rightButton as? UIView
        
        return annotationView
    }
    
    //crop the image to a certain size
    func convertImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        //redraw the image
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let afterImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return afterImage
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //print(view.annotation?.title)
            selectedSightName = (view.annotation?.title)!
            performSegue(withIdentifier: "sightDetailSegue", sender: selectedSightName)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sightDetailSegue" {
            
            let controller = segue.destination as! SightDetailViewController
            controller.incomeSightName = selectedSightName
            
        }else if segue.identifier == "tableViewSegue"{
            let destination = segue.destination as! LocationTableViewController
            destination.mapViewController = self
        }
    }
    
    
}

