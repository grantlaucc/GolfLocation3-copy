//
//  RoundDataViewController.swift
//  GolfLocation3
//
//  Created by Grant Lau on 2020-08-27.
//  Copyright © 2020 Grant Lau. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RoundDataViewController: UIViewController, MKMapViewDelegate {
    let manager = CLLocationManager()

    @IBOutlet weak var RoundDataLabel: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var finalScorecard = [Int]()
    var finalAllShots = [Shot]()
    

    var sliderVal = 1
    @IBAction func slider(_ sender: UISlider) {
        sliderLabel.text = String(Int(sender.value))
        sliderVal = Int(sender.value)
    }
    
    @IBAction func DoneButton(_ sender: UIButton) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        var testcoords = [CLLocationCoordinate2D]()
        for shot in finalAllShots{
            var shotString = ""
            let myAnnotation = MKPointAnnotation()
            if shot.hole == sliderVal{
                testcoords.append(shot.location.coordinate)
                myAnnotation.coordinate = shot.location.coordinate
                if shot.club != "flag"{
                    shotString = String(shot.shot) + ") " + shot.club + " | " + String((round(shot.distance*10))/10) + " | " + String((round(shot.distance2pin*10))/10) + " | " + String((round(shot.proximity*10))/10)
                }
                if shot.club == "flag"{
                    shotString = "flag"
                }
                myAnnotation.title = shotString
                mapView.addAnnotation(myAnnotation)
            }
        }
        let testline = MKPolyline(coordinates: testcoords, count: testcoords.count)
            //Add `MKPolyLine` as an overlay.
            mapView.addOverlay(testline)

            //adding annotations
            
            
            
            
            mapView.delegate = self
            centerViewOnHole(testcoords: testcoords)
            
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var scorecardString = ""
        for i in finalScorecard{
            scorecardString +=  String(i) + ", "
        }
        RoundDataLabel.text = scorecardString
        
        let total = finalScorecard.reduce(0, +)
        
        totalScore.text = String(total)
        


        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Return an `MKPolylineRenderer` for the `MKPolyline` in the `MKMapViewDelegate`s method
        if let polyline = overlay as? MKPolyline {
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .red
            testlineRenderer.lineWidth = 2.5
            return testlineRenderer
        }
        fatalError("Something wrong...")
        //return MKOverlayRenderer()
    }
    
    
    
    @IBAction func ReturntoViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func centerViewOnHole(testcoords: [CLLocationCoordinate2D]){
        if let location = manager.location?.coordinate{
            if testcoords.count > 0{
                let region = MKCoordinateRegion.init(center: testcoords[0], latitudinalMeters: 100, longitudinalMeters: 100)
                mapView.setRegion(region, animated: true)
            }
        }
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
