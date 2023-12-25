import UIKit
import CoreData

class ViewController: UIViewController {
    
    var context: NSManagedObjectContext!
    let userDefaults = UserDefaults.standard
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            updateSegmentedControl()
        }
    }
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        updateSegmentedControl()
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let store = restore(forkey: "store") else {
            getDataFromFile()
            return
        }
        
    }
    
    private func updateSegmentedControl() {
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        let mark = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do{
            let results = try context.fetch(fetchRequest)
            let car = results.first
            print(results)
            insertDataFrom(selectedCar: car!)
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func insertDataFrom(selectedCar car: Car) {
        carImageView.image = UIImage(data: car.imageData!)
        markLabel.text = car.mark
        modelLabel.text = car.model
        myChoiceImageView.isHidden = !car.myChoice
        ratingLabel.text = "Rating: \(car.rating)/10"
        numberOfTripsLabel.text = "Number of trips: \(car.timesDriven)"
        lastTimeStartedLabel.text = "Last time started: \(dateFormatter.string(from: car.lastStarted!))"
        segmentedControl.tintColor = car.tintColor as! UIColor
    }
    
    private func getDataFromFile() {
        // is it first launch - checking if the CoreData is empty
        
        /*
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0
        do {
            records = try context.count(for: fetchRequest)
            print("Is Data already?")
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        guard records == 0 else {return}
        */
        
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
