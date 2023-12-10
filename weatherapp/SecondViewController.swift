//
//  SecondViewController.swift
//  weatherapp
//
//  Created by Chiree Sherpa on 2023-12-09.
//

import UIKit

class SecondViewController: UIViewController{
    @IBOutlet weak var tableViewCities: UITableView!
    
    var cities : [WeatherResponseWrapper] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewCities.dataSource = self
        tableViewCities.delegate = self
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

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = cities[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        let icon = UIImage(named: item.weather[0].icon)
        content.image = icon?.resizeImage(targetSize: CGSize(width: 80, height: 80))
        let farenhietTemperature = (item.main.temp * 9/5) + 32;
        let farenhietTempText = "\(String(format: "%.2f", farenhietTemperature))°F"
        content.secondaryText = String("\(item.main.temp)°C | \(farenhietTempText)")
        cell.contentConfiguration = content
        
        return cell
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }
}

