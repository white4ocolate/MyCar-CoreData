import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let store = restore(forkey: "store") else {
            getDataFromFile()
            return
        }
    }

    private func getDataFromFile() {
        guard let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist"),
              let dataArray = NSArray(contentsOfFile: pathToFile) else {return}
        
        for dictionary in dataArray {
            guard let entity = NSEntityDescription.entity(forEntityName: "Car", in: context),
                  let car = NSManagedObject(entity: entity, insertInto: context) as? Car else {return}
            let carDictionary = dictionary as! [String : AnyObject]
            car.rating = carDictionary["rating"] as! Double
            car.myChoice = carDictionary["myChoice"] as! Bool
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            
            guard let imageName = carDictionary["imageName"],
                  let image = UIImage(named: imageName as! String),
                  let imageData = image.pngData() else {return}
            car.imageData = imageData
            
            if let colorDictionary = carDictionary["tintColor"] as? [String : Float] {
                car.tintColor = getColor(colorDictionary: colorDictionary)
            }
        }
        store("data in CoreData allready", forKey: "store")
    }
    
    private func getColor(colorDictionary: [String : Float]) -> UIColor {
        guard let red = colorDictionary["red"],
              let green = colorDictionary["green"],
              let blue = colorDictionary["blue"] else {return UIColor()}
        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1.0)
    }
    
    private func store(_ value: Any?, forKey: String) {
        userDefaults.set(value, forKey: forKey)
    }
    
    private func restore(forkey key: String) -> Any? {
        userDefaults.object(forKey: key)
    }
    
}
