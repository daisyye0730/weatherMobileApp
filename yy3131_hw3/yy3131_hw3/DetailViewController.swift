//
//  DetailViewController.swift
//  yy3131_hw3
//
//  Created by 叶瑜 on 2/16/23.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var condition: UIImageView!
    @IBOutlet weak var preciseLocation: UILabel!
    @IBOutlet weak var feelsLikeFah: UILabel!
    @IBOutlet weak var uvlight: UILabel!
    @IBOutlet weak var humid: UILabel!
    @IBOutlet weak var wind: UILabel!
    
    var location: String = ""
    var entireLocation: String = ""
    var temperature: String = ""
    var pic: UIImage?
    var windmph: String = ""
    var humidity: String = ""
    var feelsLikeF: String = ""
    var uv: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        city.text = location
        temp.text = temperature
        condition.image = pic
        preciseLocation.text = entireLocation
        feelsLikeFah.text = feelsLikeF
        uvlight.text = uv
        humid.text = humidity
        wind.text = windmph
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
