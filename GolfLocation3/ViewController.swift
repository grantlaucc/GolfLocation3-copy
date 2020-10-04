//
//  ViewController.swift
//  GolfLocation3
//
//  Created by Grant Lau on 2020-08-25.
//  Copyright © 2020 Grant Lau. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class Global {
    var clubSelection = String()
}

let global = Global()

class Shot{
    var location: CLLocation
    var club: String
    var hole: Int
    var shot: Int
    var distance: CLLocationDistance
    var distance2pin: CLLocationDistance
    var proximity: CLLocationDistance
    
    init(location: CLLocation, club: String, hole: Int, shot: Int, distance: CLLocationDistance, distance2pin: CLLocationDistance, proximity: CLLocationDistance){
        self.location = location
        self.club = club
        self.hole = hole
        self.shot = shot
        self.distance = distance
        self.distance2pin = distance2pin
        self.proximity = proximity
    }
}

class ClubBreakdown{
    var club: String
    var clubAverageDistance: Double
    var clubAverageDistance2Pin: Double
    var clubAverageProximity: Double
    
    init (club: String, clubAverageDistance: Double, clubAverageDistance2Pin: Double, clubAverageProximity: Double){
        self.club = club
        self.clubAverageDistance = clubAverageDistance
        self.clubAverageDistance2Pin = clubAverageDistance2Pin
        self.clubAverageProximity = clubAverageProximity
        
    }
}

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HoleandShotLabel.text = String(hole) + "." + String(shotsCurrentHole+1)
        // Do any additional setup after loading the view.
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
    }
    
    func centerViewOnUserLocation(){
        if let location = manager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(region, animated: true)
    }
    
    var shotsCurrentHole = 0
    var hole = 1
    var allShots = [Shot]()
    var scorecard = [Int]()
    var allShotsIndex = [0]
    var DistToPinDict = [Int:[CLLocationDistance]]()
    var ProxToPinDict = [Int:[CLLocationDistance]]()
    
    
    
    @IBOutlet weak var clubPicker: UIPickerView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let clubs = ["D", "3W", "H", "4i", "5i", "6i", "7i", "8i", "9i", "P", "G", "S", "L", "Putter", "Penalty", "flag"]
    
    func numberOfComponents(in pickerView: UIPickerView)->Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return clubs[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return clubs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        global.clubSelection = clubs[row]
    }
    
    
    @IBAction func recordLocation(_ sender: UIButton) {
        if hole>18{
            return
        }
        guard let currentLocation = manager.location else {
            return
        }
        if shotsCurrentHole>=1{
            allShots[allShots.count-1].distance = distance(from: allShots[allShots.count-1].location.coordinate, to: currentLocation.coordinate)
            
        }
        shotsCurrentHole+=1
        allShots.append(Shot(location: currentLocation, club: global.clubSelection, hole: hole, shot: shotsCurrentHole, distance: Double.nan, distance2pin: Double.nan, proximity: Double.nan))
        print(allShots.count)
        print(global.clubSelection)
        print(allShots[allShots.count-1].distance)
        HoleandShotLabel.text = String(hole) + "." + String(shotsCurrentHole+1)
    }
    
    
    @IBAction func nextHole(_ sender: UIButton) {
        if hole>18{
            return
        }
        if hole==18{
            convertToCoreData(allShots: allShots)
            HoleandShotLabel.text = "Done"
        }
        
        hole+=1
        if allShotsIndex.count == 1{
            allShotsIndex.append(shotsCurrentHole-1)
        }
        else{
            allShotsIndex.append(allShotsIndex[allShotsIndex.count - 1]+shotsCurrentHole)
        }
        if shotsCurrentHole<2{
            shotsCurrentHole=0
            scorecard.append(0)
            if hole<19{
                HoleandShotLabel.text = String(hole) + "." + String(shotsCurrentHole+1)
            }
            return
        }
        scorecard.append(shotsCurrentHole-1)
        
        for i in allShotsIndex[allShotsIndex.count - 1]-(shotsCurrentHole-1)...allShotsIndex[allShotsIndex.count - 1]-1{
            allShots[i].distance2pin = distance(from: allShots[i].location.coordinate, to: allShots[allShotsIndex[allShotsIndex.count - 1]].location.coordinate)
        }
        
        for i in allShotsIndex[allShotsIndex.count - 1]-(shotsCurrentHole-1)...allShotsIndex[allShotsIndex.count - 1]-1{
            //print(i)
            allShots[i].proximity = distance(from: allShots[i+1].location.coordinate, to: allShots[allShotsIndex[allShotsIndex.count - 1]].location.coordinate)
        }
        
        shotsCurrentHole=0
        if hole<19{
            HoleandShotLabel.text = String(hole) + "." + String(shotsCurrentHole+1)
        }
        
        //print(shotsCurrentHole)
        print(scorecard)
        //print(allShotsIndex)
        //analysis(allShots: allShots, allShotsIndex: allShotsIndex)
    }
    
    func convertToCoreData(allShots: [Shot]){
        for shot in allShots{
            let newShot = CLShot(context: self.context)
            newShot.clDate = NSDate() as Date
            newShot.clClub = shot.club
            newShot.clHole = Int64(shot.hole)
            newShot.clShot = Int64(shot.shot)
            newShot.clDistance = shot.distance
            newShot.clDistance2pin = shot.distance2pin
            newShot.clProximity = shot.proximity
            
            do {
                try self.context.save()
            }
            catch{
                
            }
        }
    }
    
    var items:[CLShot]?
    func fetchCoreData(){
        do{
            self.items = try context.fetch(CLShot.fetchRequest())
        }
        catch{
            
        }
    }
    
    
    
    
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return (from.distance(from: to)*1.0936)
    }
    
    func calculateMean(array: [CLLocationDistance]) -> Double {
        
        // Calculate sum ot items with reduce function
        let sum = array.reduce(0, { a, b in
            return a + b
        })
        
        let mean = Double(sum) / Double(array.count)
        return Double(mean)
    }
    
    
    
    
    // Testing Club Breakdown
   func allClubsBreakdown(allShots: [Shot])->[ClubBreakdown]{
        fetchCoreData()
        
        var myBag = [ClubBreakdown]()
        for club in clubs{
            if club == "flag" || club == "Penalty" {
                break
            }
            var DistanceWithGivenClub = [CLLocationDistance]()
            if allShots.count<1{
                return myBag
            }
            for i in 0...(allShots.count-1){
                if allShots[i].club == club && i+1 < allShots.count{
                    DistanceWithGivenClub.append(distance(from: allShots[i].location.coordinate, to: allShots[i+1].location.coordinate))
                }
            }
            for item in self.items!{
                if item.clClub == club{
                    DistanceWithGivenClub.append(item.clDistance)
                }
            }
            let meanDistance = (calculateMean(array: DistanceWithGivenClub))
            
            
            var ProxWithGivenClub = [CLLocationDistance]()
            var Dist2HoleWithGivenClub = [CLLocationDistance]()
            for shot in allShots{
                if shot.club == club && shot.proximity >= distance(from: shot.location.coordinate, to: shot.location.coordinate){
                    ProxWithGivenClub.append(shot.proximity)
                    Dist2HoleWithGivenClub.append(shot.distance2pin)
                }
            }
            
            for item in self.items!{
                if item.clClub == club{
                    print(item.clClub)
                    print(item.clDistance)
                    ProxWithGivenClub.append(item.clProximity)
                    Dist2HoleWithGivenClub.append(item.clDistance2pin)
                }
            }
            
            let meanProximity = (calculateMean(array: ProxWithGivenClub))
            let meanDist2Hole = (calculateMean(array: Dist2HoleWithGivenClub))
            
            myBag.append(ClubBreakdown(club: club, clubAverageDistance: meanDistance, clubAverageDistance2Pin: meanDist2Hole, clubAverageProximity: meanProximity))
        }
        return myBag
    }
    

    
    
    // End of Club Breakdown Testing
    
    
    
    
    

    
    var clubDistances = [String:Double]()
    var clubProximities = [String:Double]()
    var clubDistances2Pin = [String:Double]()
    
    var myBag = [ClubBreakdown]()
    
    @IBAction func ClubDataView(_ sender: UIButton) {
        self.myBag = allClubsBreakdown(allShots: allShots)
        performSegue(withIdentifier: "ClubDataSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ClubDataSegue"{
            let vc = segue.destination as! ClubDataViewController
            vc.finalmyBag = self.myBag
        }
        if segue.identifier == "RoundDataSegue"{
            let vc = segue.destination as! RoundDataViewController
            vc.finalScorecard = self.viewScorecard
            vc.finalAllShots = self.viewAllShots
        }
    }
    
    var viewScorecard = [Int]()
    var viewAllShots = [Shot]()
    @IBAction func RoundData(_ sender: Any) {
        self.viewScorecard = scorecard
        self.viewAllShots = allShots
        performSegue(withIdentifier: "RoundDataSegue", sender: self)
    }
        
    @IBOutlet weak var HoleandShotLabel: UILabel!
    
    @IBAction func deleteLastShot(_ sender: Any) {
        if shotsCurrentHole>0{
            allShots.popLast()
            shotsCurrentHole-=1
            HoleandShotLabel.text = String(hole) + "." + String(shotsCurrentHole+1)
        }
    }
    
    @IBAction func clearCoreData(_ sender: Any) {
        for item in self.items!{
            self.context.delete(item)
            do{
                try self.context.save()
            }
            catch{
                
            }
        }
    }
    
    
}


