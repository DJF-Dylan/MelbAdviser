//
//  SightDetailViewController.swift
//  MelbourenHistorySight
//
//  Created by Lynn on 5/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//

import UIKit
import MapKit

class SightDetailViewController: UIViewController,DatabaseListener {

    @IBOutlet weak var sightName: UILabel!
    @IBOutlet weak var sightImage: UIImageView!
    @IBOutlet weak var SightLocation: UILabel!
    @IBOutlet weak var SightDescription: UILabel!
    
    var sight: Sight?
    
    var incomeSightName: String?
    
    weak var databaseController: DatabaseProtocol?
    var sightList: [Sight] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        //self.navigationController?.isNavigationBarHidden = false
        
    }
    
    //load image from local storage
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        
        return image
    }
    func displayDetail(){
        for newSight in sightList {
            if newSight.name == incomeSightName! {
                sight = newSight
            }
        }
        //load animal detail to display
        sightName.text = sight?.name
        SightDescription.text = sight?.desc
        
        //transfer the lat and long to the fridendly location
        let location = CLLocation(latitude: (sight?.latitude)!, longitude: (sight?.longitude)!)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                
                //print(firstLocation!.name, firstLocation!.locality, firstLocation?.administrativeArea, firstLocation!.postalCode)
                if firstLocation != nil{
                self.SightLocation.text = "\((firstLocation!.name)!), \((firstLocation!.locality)!), \((firstLocation!.administrativeArea)!), \((firstLocation!.postalCode)!)"
                }else{
                    let lat = self.sight?.latitude
                    let long = self.sight?.longitude
                    self.SightLocation.text = "latitude: \(String(describing: lat)) longitude: \(String(describing: long))"
                }
            
                //completionHandler(firstLocation)
            } else {
                //completionHandler(nil)
            }
        })
        
        //load the picture to the image view
        do {
            if (sight?.image != "") {
                //print(filteredAnimalList[indexPath.row].name)
                try sightImage!.image = loadImageData(fileName: (sight?.image!)!)
                
            } else {
                try sightImage!.image = UIImage(named: sight!.name!)
            }
        } catch let error {
            print("Could not load image: \(error)")
        }
        
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
        sightList = sight
        displayDetail()
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
