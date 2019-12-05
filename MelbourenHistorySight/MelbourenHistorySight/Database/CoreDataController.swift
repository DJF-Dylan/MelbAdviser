//
//  CoreDataController.swift
//  FIT5140A1
//
//  Created by Lynn on 2/9/19.
//  Copyright © 2019 JunfanDang. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    let DEFAULT_SIGHT_NAME = "Historical sights"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    // Results
    var allSightFetchedResultsController: NSFetchedResultsController<Sight>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "HistorySight")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
        
        // If there are no sight in the database assume that the app is running
        // for the first time. Create the default sight and initial sight.
        if fetchAllSight().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addSight(name: String, desc: String, longitude: Double, latitude: Double,image: String,icon: String) -> Sight {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into:
            persistantContainer.viewContext) as! Sight
        sight.name = name
        sight.desc = desc
        sight.longitude = longitude
        sight.latitude = latitude
        sight.image = image
        sight.icon = icon
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return sight
    }
    
    func deleteSight(sight: Sight) {
        persistantContainer.viewContext.delete(sight)
        // This less efficient than batching changes and saving once at end.
        saveContext()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.sight || listener.listenerType == ListenerType.all {
            listener.onSightListChange(change: .update, sight: fetchAllSight())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    func fetchAllSight() -> [Sight] {
        if allSightFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSightFetchedResultsController = NSFetchedResultsController<Sight>(fetchRequest:
                fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil,
                              cacheName: nil)
            allSightFetchedResultsController?.delegate = self
            do {
                try allSightFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sight = [Sight]()
        if allSightFetchedResultsController?.fetchedObjects != nil {
            sight = (allSightFetchedResultsController?.fetchedObjects)!
        }
        
        return sight
    }
    
    
    // MARK: - Fetched Results Conttroller Delegate
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allSightFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.sight || listener.listenerType == ListenerType.all {
                    listener.onSightListChange(change: .update, sight: fetchAllSight())
                }
            }
        }
    }
    // MARK: - Default entries
    func createDefaultEntries() {
        let _ = addSight(name: "Flinders Street Station", desc: "Stand beneath the clocks of Melbourne's iconic railway station, as tourists and Melburnians have done for generations. Take a train for outer-Melbourne explorations, join a tour to learn more about the history of the grand building, or go underneath the station to see the changing exhibitions that line Campbell Arcade.", longitude: 144.9674052, latitude: -37.8175485,image: "",icon: "Flinders Street Station")
        let _ = addSight(name: "St Paul's Cathedral", desc: "Leave the bustling Flinders Street Station intersection behind and enter the peaceful place of worship that's been at the heart of city life since the mid 1800s. Join a tour and admire the magnificent organ, the Persian Tile and the Five Pointed Star of the historic St Paul's Cathedral.", longitude: 144.96761, latitude: -37.81706,image: "",icon: "St Paul's Cathedral")
        let _ = addSight(name: "Nicholas Building", desc: "Explore floor after floor of studios, galleries and curiosities in this heritage-listed creative hub. Shop for stunning textiles at Kimono House, found objects at Harold and Maude and vintage haberdashery at l'uccello. Trawl racks of vintage fashion at Retrostar or make an appointment for high-end millinery at Louise McDonald. Get behind the scenes and schedule your visit with one of the regular Open Studio days to see craftspeople at work in the historic studios. On the ground floor, browse the latest designs at Kuwaii and Obus in art deco Cathedral Arcade. Outside, stand back and admire the grandeur of the Renaissance palazzo-style architecture.", longitude: 144.9667, latitude: -37.81676,image: "",icon: "Nicholas Building")
        let _ = addSight(name: "Manchester Unity Building", desc: "The Manchester Unity Building is one of Melbourne's most iconic Art Deco landmarks. It was built in 1932 for the Manchester Unity Independent Order of Odd Fellows (IOOF), a friendly society providing sickness and funeral insurance. Melbourne architect Marcus Barlow took inspiration from the 1927 Chicago Tribune Building. His design incorporated a striking New Gothic style façade of faience tiles with ground-floor arcade and mezzanine shops, café and rooftop garden. Step into the arcade for a glimpse of the marble interior, beautiful friezes and restored lift – or book a tour for a peek upstairs.", longitude: 144.9664, latitude: -37.81529,image: "",icon: "Manchester Unity Building")
        let _ = addSight(name: "Athenaeum Theatre", desc: "Book your place in history and catch a show in this heritage-listed building housing the Athenaeum Theatre, the Last Laugh at the Comedy Club and the Athenaeum Library. Take a seat for live theatre and music at the Athenaeum Theatre, or climb the grand staircase to the Last Laugh for stand-up comedy on weekends.", longitude: 144.96726, latitude: -37.81483,image: "",icon: "Athenaeum Theatre")
        let _ = addSight(name: "The Scots' Church", desc: "Look up to admire the 120-foot spire of the historic Scots' Church, once the highest point of the city skyline. Nestled between modern buildings on Russell and Collins streets, the decorated Gothic architecture and stonework is an impressive sight, as is the interior's timber panelling and stained glass. Trivia buffs, take note: the church was built by David Mitchell, father of Dame Nellie Melba (once a church chorister).", longitude: 144.96904, latitude: -37.81469,image: "",icon: "The Scots' Church")
        let _ = addSight(name: "St Michael's Uniting Church", desc: "St Michael's is a unique church in the heart of the city. It is not only unique for its relevant, contemporary preaching, but for its unusual architecture.", longitude: 144.96983, latitude: -37.814454,image: "",icon: "St Michael's Uniting Church")
        let _ = addSight(name: "Parliament of Victoria", desc: "Victoria's Parliament House - one of Australia's oldest and most architecturally distinguished public buildings. The Parliament of Victoria welcomes you to share in our history and heritage. Sit in the chambers where Victoria's laws are made, take in the majesty of Queen's Hall, and see where Australia's first Federal Parliament conducted proceedings for 26 years." , longitude: 144.9732506, latitude: 37.8116284,image: "",icon: "Parliament of Victoria")
        let _ = addSight(name: "Chinese Museum", desc: "Located in the heart of Melbourne’s Chinatown, the Chinese Museum (Museum of Chinese Australian History)’s five floors showcase the heritage and culture of Australia’s Chinese community. ", longitude: 144.9691694, latitude: -37.8107583,image: "",icon: "Chinese Museum")
        let _ = addSight(name: "Her Majesty's Theatre", desc: "Her Majesty's Theatre, one of Melbourne's most iconic venues for live performance, has been entertaining Australia since 1886.", longitude: 144.969746, latitude: -37.8104807,image: "",icon: "Her Majesty's Theatre")
        let _ = addSight(name: "Old Melbourne Gaol", desc: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol.Shrouded in secrets, wander the same cells and halls as some of history’s most notorious criminals, from Ned Kelly to Squizzy Taylor, and discover the stories that never left. Hosting day and night tours, exclusive events and kids activities throughout school holidays and an immersive lock-up experience in the infamous City Watch House, the Gaol remains Melbourne’s most spell-binding journey into its past.", longitude: 144.965018, latitude: -37.807514,image: "",icon: "Old Melbourne Gaol")
        let _ = addSight(name: "Trades Hall", desc: "Established in 1859 as a meeting hall and a place to educate workers and their families - Trades Hall is still home to trade unions and political events - but has grown to embrace a diverse cultural focus. It's now a regular venue for theatre, art exhibitions, Melbourne International Comedy Festival and Melbourne Fringe Festival.", longitude: 144.966225, latitude: -37.806686,image: "",icon: "Trades Hall")
        let _ = addSight(name: "Royal Exhibition Building", desc: "North of the city centre, the majestic Royal Exhibition Building is surrounded by Carlton Gardens.The building is one of the world's oldest remaining exhibition pavilions and was originally built for the Great Exhibition of 1880. Later it housed the first Commonwealth Parliament from 1901, and was the first building in Australia to achieve a World Heritage listing in 2004.", longitude: 144.97693, latitude: -37.80469,image: "",icon: "Royal Exhibition Building")
        let _ = addSight(name: "Fire Services Museum of Victoria", desc: "The Fire Services Museum of Victoria is an organisation dedicated to the preservation and showcasing of fire-fighting memorabilia from Victoria, Australia and overseas.", longitude: 144.975444, latitude: -37.808906,image: "",icon: "Fire Services Museum of Victoria")
        let _ = addSight(name: "Melbourne Museum", desc: "The Melbourne Museum left its old home in the State Library Building in 1997, and into a building located in Carlton Gardens that was designed by Denton Corker Marshall. The new Melbourne Museum reopened on 21 October 2000.", longitude: 144.9717675, latitude: -37.8031931,image: "",icon: "Melbourne Museum")
    }
}

