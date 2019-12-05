//
//  NewLocationController.swift
//  MelbourenHistorySight
//
//  Created by Lynn on 4/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class NewLocationController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate  {

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    weak var databaseController: DatabaseProtocol?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        managedObjectContext = appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        currentLocation = location.coordinate
    }
    
    @IBOutlet weak var latitudeTextField: UITextField!

    @IBOutlet weak var longitudeTextField: UITextField!
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation {
            latitudeTextField.text = "\(currentLocation.latitude)"
            longitudeTextField.text = "\(currentLocation.longitude)"
        }
        else {
            let alertController = UIAlertController(title: "Location Not Found", message: "The location has not yet been determined.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var chooseIcon: UISegmentedControl!
    
    @IBAction func saveLocation(_ sender: Any) {
        
    
        
        if nameTextField.text != "" && descriptionTextField.text != "" && longitudeTextField.text != "" && latitudeTextField.text != ""{
            
            guard let image = imageView.image else {
                displayMessage("Cannot save until a photo has been taken!", "Error")
                return
            }
            
            let date = UInt(Date().timeIntervalSince1970)
            var data = Data()
            data = image.jpegData(compressionQuality: 0.8)!
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            
            if let pathComponent = url.appendingPathComponent("\(date)") {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                fileManager.createFile(atPath: filePath, contents: data,attributes: nil)
                do {
                    let name:String = nameTextField.text!
                    let desc:String = descriptionTextField.text!
                    let long = Double(longitudeTextField.text!)
                    let lat = Double(latitudeTextField.text!)
                    let icon:String = chooseIcon.titleForSegment(at:chooseIcon.selectedSegmentIndex)!
                    
                    let location = LocationAnnotation(newTitle: nameTextField.text!, newSubtitle:descriptionTextField.text!, lat: Double(latitudeTextField.text!)!, long: Double(longitudeTextField.text!)!)
                    let _ = databaseController!.addSight(name: name, desc: desc, longitude: long!, latitude: lat!, image: "\(date)", icon: icon)
                    try self.managedObjectContext?.save()
                    navigationController?.popViewController(animated: true)
                } catch {
                    displayMessage("Could not save to database", "Error")
                }
            }         
        }
        var errorMsg = "Please ensure all fields are filled:\n"
        
        if nameTextField.text == "" {
            errorMsg += "- Must provide a name\n"
        }
        if descriptionTextField.text == "" {
            errorMsg += "- Must provide description"
        }
        if latitudeTextField.text == "" {
            errorMsg += "- Must provide a correct position"
        }
        if longitudeTextField.text == "" {
            errorMsg += "- Must provide position"
        }
        
        displayMessage(title: "Not all fields filled", message: errorMsg)
    }
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler:
            nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the image", "Error")
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
