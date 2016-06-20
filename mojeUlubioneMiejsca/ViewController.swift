//
//  ViewController.swift
//  mojeUlubioneMiejsca
//
//  Created by Kamil Wójcik on 19.06.2016.
//  Copyright © 2016 Kamil Wójcik. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!
    @IBOutlet weak var mapa: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if aktywneMiejsce == -1 { //jeżeli nie wybrał żadnego miejsca to autoryzacja i aktualziaowanie
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }else{ //jeżeli wybrał miejsce to współrzedne tego miejsca i pokaż na mapie
            let szerokośćGeogr = NSString(string: miejsca[aktywneMiejsce]["szerokośćGeogr"]!).doubleValue
            let długośćGeogr = NSString(string: miejsca[aktywneMiejsce]["długośćGeogr"]!).doubleValue
            //nsstring i doublevalue żeby zamienić stringi na double bo taki jest typ stopni

            let szerokośćDelta: CLLocationDegrees = 0.01
            let długośćDelta: CLLocationDegrees = 0.01
            let coordinate = CLLocationCoordinate2D(latitude: szerokośćGeogr, longitude: długośćGeogr)
            let span:MKCoordinateSpan = MKCoordinateSpanMake(szerokośćDelta, długośćDelta)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            mapa.setRegion(region, animated: true)
            
            //pinezka
            let pinezka = MKPointAnnotation()
            pinezka.coordinate = coordinate
            pinezka.title = miejsca[aktywneMiejsce]["nazwa"]
            self.mapa.addAnnotation(pinezka)
        }
        
        
        
        
        let długieNaciśnięcie = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.akcja(_:)))
        długieNaciśnięcie.minimumPressDuration = 1.0
        mapa.addGestureRecognizer(długieNaciśnięcie)
        
        
    }
    
    func akcja(gestureRecognizer: UIGestureRecognizer){
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began{ //kiedy długo się naciśnie zostanie tylko raz wywołane
            
            let dotknięcie = gestureRecognizer.locationInView(self.mapa)
            let noweWspółrzędne = self.mapa.convertPoint(dotknięcie, toCoordinateFromView: self.mapa)
            
            let lokalizacja = CLLocation(latitude: noweWspółrzędne.latitude, longitude: noweWspółrzędne.longitude)
            CLGeocoder().reverseGeocodeLocation(lokalizacja, completionHandler: { (placemarks, error: NSError?) in
                
                var title = ""
                
                if error != nil{
                    print(error)
                }else{
                    if let p = placemarks?[0]{
                        var miasto = ""
                        var ulica = ""
                        
                        if p.locality != nil{
                            miasto = p.locality!
                        }
                        if p.thoroughfare != nil{
                            ulica = p.thoroughfare!
                        }
                        title = "\(ulica), \(miasto)"
                    }
                }
                
                if title == ""{
                    title = "Dodano \(NSDate())"
                }
                
                miejsca.append(["nazwa":title, "szerokośćGeogr": "\(noweWspółrzędne.latitude)", "długośćGeogr": "\(noweWspółrzędne.longitude)"])
                
                let pinezka = MKPointAnnotation()
                pinezka.coordinate = noweWspółrzędne
                pinezka.title = title
                self.mapa.addAnnotation(pinezka)
            })
        }
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let pozycjaUżytkownika: CLLocation = locations[0]
        let szerokośćGeogr = pozycjaUżytkownika.coordinate.latitude
        let długośćGeogr = pozycjaUżytkownika.coordinate.longitude
        let szerokośćDelta: CLLocationDegrees = 0.01
        let długośćDelta: CLLocationDegrees = 0.01
        let coordinate = CLLocationCoordinate2D(latitude: szerokośćGeogr, longitude: długośćGeogr)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(szerokośćDelta, długośćDelta)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        mapa.setRegion(region, animated: true)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "noweMiejsce"{
            aktywneMiejsce = -1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

