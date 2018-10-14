//
//  postNotificationViewController.swift
//  The 21st
//
//  Created by Travis RASE on 8/8/18.
//  Copyright © 2018 The 21st. All rights reserved.
//
import Alamofire
import SwiftyJSON
import UIKit

class postNotificationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var notifcationMessage: UITextField!
    @IBOutlet weak var sourceLink: UITextField!
    @IBOutlet weak var yourName: UITextField!
    @IBOutlet weak var adminKey: UITextField!
    @IBOutlet weak var instructionalLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        notifcationMessage.delegate = self as? UITextFieldDelegate
        sourceLink.delegate = self as? UITextFieldDelegate
        yourName.delegate = self as? UITextFieldDelegate
        adminKey.delegate = self as? UITextFieldDelegate

        instructionalLabel.textColor = UIColor.white

        //hide admin key box by defualt
        adminKey.isHidden = true

        //Dismisses keyboard when tapped outside of keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        print(userPrivaliges.canPost)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func postNotification(message:String, sourceLink: String, userID: String, isPosted: String? = "False", adminKey: String? = "BadKey") {

        var headers = HTTPHeaders()
        let user = ""
        let password = ""
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])

        headers["Authorization"] = "Basic \(base64Credentials)"
        headers["Content-Type"] = "application/json"
        headers["isPosted"] = isPosted
        headers["adminKey"] = adminKey

        let parameters = [
            "message": message,
            "sourceLink":sourceLink,
            "userID": userID,
        ]

        Alamofire.request("https://wgold21.pythonanywhere.com/notification/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<600).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if(json == "Invalid admin key"){
                    self.instructionalLabel.text = "Invalid Admin Key"
                    self.instructionalLabel.textColor = UIColor.red
                }
                print(json)
                break;

            case .failure(let error):
                self.instructionalLabel.text = "Error occured while trying to post notification"
                self.instructionalLabel.textColor = UIColor.red
                print(error)
                break;

            }
        }
    }

    //When submit button is pressed
    @IBAction func buttonPressed(_ sender: UIButton) {
        let timeOutTime: Double = 3600

        //retrieve user input
        let message = notifcationMessage.text
        let sourceLink = self.sourceLink.text
        let userID = self.yourName.text
        let adminKey : String = self.adminKey.text!

        //check to make sure message was provided
        if ((message?.count)! < 1){
            instructionalLabel.text = "Please include a notification message"
            instructionalLabel.textColor = UIColor.red
            return
        }
        //check to make sure notification source link was provided
        if ((sourceLink?.count)! < 1){
            instructionalLabel.text = "Please include a source link"
            instructionalLabel.textColor = UIColor.red
            return
        }
        let alert = UIAlertController(title: "Are you sure you want to post", message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Post", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                if(adminKey.count < 1){
                    if(userPrivaliges.canPost){
                        self.postNotification(message: message!, sourceLink: sourceLink!, userID: userID!, isPosted: "False")
                        self.instructionalLabel.textColor = UIColor.white
                        self.instructionalLabel.text = "Thank You"
                        self.setToCanNotPost()
                        print("can post after posted?: " + String(userPrivaliges.canPost))
                        Timer.scheduledTimer(withTimeInterval: timeOutTime, repeats: false) {_ in
                            self.setToCanPost()
                        }
                        return
                    }
                    else{
                        self.instructionalLabel.text = "You may only suggest one notificaiton per hour"
                        self.instructionalLabel.textColor = UIColor.red
                        return
                    }

                }
                else{
                    self.postNotification(message: message!, sourceLink: sourceLink!, userID: userID!, isPosted: "True", adminKey: adminKey)
                    self.instructionalLabel.textColor = UIColor.white
                    self.instructionalLabel.text = "Thank You"

                }
            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")

            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style{
            case .default:
                //break out when cancel is pressed
                print("default cancel")
                return

            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")

            }}))
        self.present(alert, animated: true, completion: nil)

        //reset textboxes to defualt
        self.notifcationMessage.text = ""
        self.sourceLink.text = ""
        self.yourName.text = ""
        self.adminKey.text = ""

    }

    @IBAction func secretAdminReveal(_ sender: UIButton) {
        sender.adjustsImageWhenHighlighted = false
        if(adminKey.isHidden){
            adminKey.isHidden = false
        }else{
            adminKey.isHidden = true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        notifcationMessage.resignFirstResponder()
        sourceLink.resignFirstResponder()
        yourName.resignFirstResponder()
        adminKey.resignFirstResponder()
        return true
    }

    //dismisses keyboard for all UITextFields
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        notifcationMessage.resignFirstResponder()
        sourceLink.resignFirstResponder()
        yourName.resignFirstResponder()
        adminKey.resignFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength : Int = 150
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= maxLength
    }

    func setToCanPost(){
        userPrivaliges.canPost = true
    }
    func setToCanNotPost(){
        userPrivaliges.canPost = false
    }

}

// view controller might need to be postNotifcationViewController
extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

struct userPrivaliges {
    static var canPost:Bool = true
}
