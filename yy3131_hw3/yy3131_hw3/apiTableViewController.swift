//
//  ViewController.swift
//  yy3131-hw2
//
//  Created by 叶瑜 on 2/15/23.
//

import UIKit
import Foundation

class MyCustomCell: UITableViewCell {
    
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var condition: UIImageView!
    @IBOutlet weak var city: UILabel!
}

class apiTableViewController: UITableViewController {

    @IBOutlet weak var editButton: UIButton!

    // MARK: - Weather
    struct Weather: Codable {
        let location: Location
        let current: Current
    }

    // MARK: - Current
    struct Current: Codable {
        let lastUpdatedEpoch: Int
        let lastUpdated: String
        let tempC: Double
        let tempF, isDay: Double
        let condition: Condition
        let windMph: Double
        let windKph, windDegree: Double
        let windDir: String
        let pressureMB: Double
        let pressureIn: Double
        let precipMm, precipIn, humidity, cloud: Double
        let feelslikeC: Double
        let feelslikeF: Double
        let visKM, visMiles, uv: Double
        let gustMph, gustKph: Double

        enum CodingKeys: String, CodingKey {
            case lastUpdatedEpoch = "last_updated_epoch"
            case lastUpdated = "last_updated"
            case tempC = "temp_c"
            case tempF = "temp_f"
            case isDay = "is_day"
            case condition
            case windMph = "wind_mph"
            case windKph = "wind_kph"
            case windDegree = "wind_degree"
            case windDir = "wind_dir"
            case pressureMB = "pressure_mb"
            case pressureIn = "pressure_in"
            case precipMm = "precip_mm"
            case precipIn = "precip_in"
            case humidity, cloud
            case feelslikeC = "feelslike_c"
            case feelslikeF = "feelslike_f"
            case visKM = "vis_km"
            case visMiles = "vis_miles"
            case uv
            case gustMph = "gust_mph"
            case gustKph = "gust_kph"
        }
    }

    // MARK: - Condition
    struct Condition: Codable {
        let text, icon: String
        let code: Int
    }

    // MARK: - Location
    struct Location: Codable {
        let name, region, country: String
        let lat, lon: Double
        let tzID: String
        let localtimeEpoch: Int
        let localtime: String

        enum CodingKeys: String, CodingKey {
            case name, region, country, lat, lon
            case tzID = "tz_id"
            case localtimeEpoch = "localtime_epoch"
            case localtime
        }
    }
    
    var queries = ["Shanghai", "NEW%20YORK%20CITY", "Tokyo", "Mumbai", "Taipei", "Los%20Angeles", "Seattle", "Beijing", "Hong%20Kong", "Paris"]
    var ans: [Weather] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        getAllData()
    }
    
    @objc func buttonClicked(sender:UIButton!){
        if self.tableView.isEditing {
            self.tableView.isEditing = false
            editButton.setTitle("Edit", for: .normal)
        } else {
            self.tableView.isEditing = true
            editButton.setTitle("Done", for: .normal)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ans.count
    }
    
    func getImage(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath) as! MyCustomCell
        
        // Configure the cell...
        cell.city!.text = ans[indexPath.row].location.name
        cell.temp!.text = "\(ans[indexPath.row].current.tempF)°F"
        let url = URL(string: "https:" + ans[indexPath.row].current.condition.icon)!
        getImage(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                cell.condition!.image = UIImage(data: data)
            }
        }
        return cell
    }
    
    func getAllData() {
        for q in queries {
            
            let headers = [
                "X-RapidAPI-Key": "3c9f577dd4msh15152806a55c177p144277jsn1f49fd254f3a",
                "X-RapidAPI-Host": "weatherapi-com.p.rapidapi.com"
            ]
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://weatherapi-com.p.rapidapi.com/current.json?q="+q)! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                
                guard error == nil else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) {
                        let alert = UIAlertController(title: "Error - ", message: "\(String(describing: error))", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    return
                }
                guard let jsonData = data else {
                    print("No data")
                    return
                }
                do {
                    let weather = try JSONDecoder().decode(Weather.self, from: jsonData)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    self.ans.append(weather)
                } catch {
                    print("JSON Decode error: \(error)")
                }
            })
            dataTask.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! DetailViewController
        let myRow = tableView!.indexPathForSelectedRow

        destVC.location = ans[myRow?.row as! Int].location.name
        destVC.temperature = "\(ans[myRow?.row as! Int].current.tempF)°F"
        destVC.windmph = "Wind Speed: \(ans[myRow?.row as! Int].current.windMph) MPH"
        destVC.humidity = "Humidity: \(ans[myRow?.row as! Int].current.humidity)"
        destVC.feelsLikeF = "Feels like: \(ans[myRow?.row as! Int].current.feelslikeF)°F"
        destVC.uv = "UV: \(ans[myRow?.row as! Int].current.uv)"
        destVC.entireLocation = "\(ans[myRow?.row as! Int].location.name), \(ans[myRow?.row as! Int].location.region), \(ans[myRow?.row as! Int].location.country)"
        let url = URL(string: "https:" + ans[myRow?.row as! Int].current.condition.icon)!
        getImage(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                destVC.img.image = UIImage(data: data)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ans.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let movedCity = self.cities[sourceIndexPath.row]
//        let movedTemp = self.temp[sourceIndexPath.row]
//        let movedCondition = self.condition[sourceIndexPath.row]
//        cities.remove(at: sourceIndexPath.row)
//        cities.insert(movedCity, at: destinationIndexPath.row)
//
//        temp.remove(at: sourceIndexPath.row)
//        temp.insert(movedTemp, at: destinationIndexPath.row)
//
//        condition.remove(at: sourceIndexPath.row)
//        condition.insert(movedCondition, at:destinationIndexPath.row)
        let moved = self.ans[sourceIndexPath.row]
        ans.remove(at: sourceIndexPath.row)
        ans.insert(moved, at: destinationIndexPath.row)
    }
}
