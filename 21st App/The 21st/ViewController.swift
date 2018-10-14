//
//  ViewController.swift
//  The 21st
//
//  Created by Travis RASE on 5/22/18.
//  Copyright © 2018 The 21st. All rights reserved.
//

// light blue: 0x21C6DF
// dark blue: 0x104F79

import UIKit
import Alamofire
import SwiftyJSON
import SafariServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var twentyFirstLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var catchPhrase: UITextField!

    var notifications : [[Notification]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize outlet delegates
        catchPhrase.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderWidth = 1.5;
        tableView.layer.borderColor = UIColor.white.cgColor

        //catch phrase hairline rule
        catchPhrase.borderStyle = .none
        catchPhrase.isUserInteractionEnabled = false

        //Add observer to update content when application enters foreground
        NotificationCenter.default.addObserver(self, selector:#selector(gatherNotifications), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        //update notifciation table. Potentially redundant
        gatherNotifications()
    }

    //refresh button action
    @IBAction func refreshButton(_ sender: Any) {
        gatherNotifications()
    }
    @objc func gatherNotifications() {
        var localNotifications : [Notification] = []
        //here we make our API request and pull new notifications into the tableview
        var headers = HTTPHeaders()
        headers["secretKey"] =
        headers["Content-Type"] = "application/json"

        let user =
        let password =
        let credentialData =
        let base64Credentials =
        headers["Authorization"] =

        Alamofire.request("https://wgold21.pythonanywhere.com/notification/", encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    for index in 0...(json.count - 1){
                        let msg = json[String(index)]
                        localNotifications.append(Notification(notificationID: msg["id"].int ?? 00,
                                                               notificationDate: msg["date"].string ?? "nil",
                                                               message: msg["message"].string ?? "nil",
                                                               sourceLink: msg["sourceLink"].string ?? "nil",
                                                               userID: msg["userID"].string ?? "nil",
                                                               posted: msg["isPosted"].bool ?? false))
                    }

                    self.groupNotificationsByDate(notificationArray: localNotifications)
                    self.tableView.reloadData()
                case .failure(let error):
                    //show alert
                    let message : String = "Could not load content. Please check your internet connection."
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)

                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                        case .cancel:
                            print("cancel")
                        case .destructive:
                            print("destructive")
                        }}))
                    self.present(alert, animated: true, completion: nil)
                    print(error)
            }
        }
    }

    func groupNotificationsByDate(notificationArray : [Notification]){
        var localNotifications : [[Notification]] = []
        var notifcationDateGrouping : [Notification] = []
        var lastDate : String = notificationArray[0].notificationDate!

        for notification in notificationArray{
            if notification.notificationDate != lastDate{
                localNotifications.append(notifcationDateGrouping)
                notifcationDateGrouping = []
                notifcationDateGrouping.append(notification)
                lastDate = notification.notificationDate!
            }
            else{
                notifcationDateGrouping.append(notification)
            }
        }
        localNotifications.append(notifcationDateGrouping)

        notifications = localNotifications
    }

    func sourceLinkPopup(sourceLink: String?? = "http://www.codingexplorer.com/creating-and-modifying-nsurl-in-swift/"){
        let message : String = sourceLink!!
        let alert = UIAlertController(title: "Source Link", message: message, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "View Story", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                let url = URL(string: sourceLink as! String)
                let svc = SFSafariViewController(url: url!)
                self.present(svc, animated: true, completion: nil)

            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")

            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")

            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")

            }}))
        self.present(alert, animated: true, completion: nil)

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let isoDate : String = notifications[section][0].notificationDate!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let date = dateFormatter.date(from:isoDate)!
        dateFormatter.dateFormat = "MM.dd.yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    //Format Each Cell Header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(rgb: 0x21C6DF)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.textAlignment = NSTextAlignment.center
        header.textLabel?.font = UIFont.systemFont(ofSize: 14)
        header.layer.borderColor = UIColor.white.cgColor
        header.layer.borderWidth = 1
    }

    //Format Each Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create cell
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "myCell")
        //set cell characteristics
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = ("\n" + notifications[indexPath.section][indexPath.row].message! + "\n");
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.adjustsFontSizeToFitWidth=false
        cell.textLabel?.numberOfLines=0
        //cell.textLabel?.font = UIFont(name: "Neue Helvetica", size: 16)
        //cell.textLabel?.font = UIFont(name: "Freight Sans", size: 16)
        cell.textLabel?.font = UIFont(name: "Times New Roman", size: 16)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        sourceLinkPopup(sourceLink: notifications[indexPath[0]][indexPath[1]].sourceLink)
    }

    deinit {
        //deinit observer to update notifications when app comes to foreground
        NotificationCenter.default.removeObserver(self)
    }
}
//convert color hex to UIColor
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
