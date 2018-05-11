import UIKit
import CoreML
import Vision
import ImageIO
import os.log

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    /*
     This value is passed by `ViewController` in `processImage(_ image: UIImage)`
     */
    var food: Food?
    var caloriesOfFood = ["pizza": 300.0, "apple_pie": 200.0]
    
    @IBAction func takePicture(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker, animated: true)
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("1")
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        classificationLabel.text = "Analyzing Image…" 
        
        guard let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else { fatalError("No image from image picker") }
        processImage(uiImage)
    }
    
    func processImage(_ image: UIImage) {
        let model = Food101()
        let size = CGSize(width: 299, height: 299)
        
        guard let buffer = image.resize(to: size)?.pixelBuffer() else {
            fatalError("Scaling or converting to pixel buffer failed!")
        }
        
        guard let result = try? model.prediction(image: buffer) else {
            fatalError("Prediction failed!")
        }
        
        let confidence = result.foodConfidence["\(result.classLabel)"]! * 100.0
        let converted = String(format: "%.2f", confidence)
        
        imageView.image = image
        classificationLabel.text = "\(result.classLabel) - \(converted) %"
        
        let caloriesPerUnit = 100.0
        food = Food(type: result.classLabel, calories: caloriesPerUnit)
    }
    
    //MARK: - Navigation
    
    // Do a little preparation before navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "measureSize" {
            if (food == nil) {
                let alert = UIAlertController(title: "Alert", message: "No photo chosen.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            } else if caloriesOfFood.keys.contains((food?.type)!) {
                os_log("Food is set", log: OSLog.default, type: .debug)
                return true
            } else {
                let notInDBAlert = UIAlertController(title: "Alert", message: "The information has not been set for this type!", preferredStyle: .alert)
                notInDBAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(notInDBAlert, animated: true, completion: nil)
                return false
            }
        }
        // by default, transition
        return true
    }
    
    @IBAction func measureSize(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "measureSize", sender: food)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "measureSize" {
            let nextScene = segue.destination as! GameViewController
            nextScene.food = food
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

