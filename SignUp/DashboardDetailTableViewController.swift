//
//  DashboardDetailTableViewController.swift
//  SignUp
//
//  Created by Pradul MT on 27/07/17.
//  Copyright © 2017 Pradul MT. All rights reserved.
//

import UIKit

class DashboardDetailTableViewController: UITableViewController {
    
    
    var updateSpinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        let x = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        view.hidesWhenStopped = true
        view.color = UIColor.blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupSpinner() {
        updateSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    var isUpdateOngoing = false {
        didSet {
            if isUpdateOngoing == true {
                updateSpinner.startAnimating()
            } else if isUpdateOngoing == false {
                print("Data At Detail Controller")
                for hub in self.hubs {
                    for board in hub.boards {
                        print(board.id, board.isSwitchBoardOnline, board.name!, board.switch1State, board.switch2State, board.switch3State, board.switch4State)
                    }
                }
                tableView?.reloadData()
                updateSpinner.stopAnimating()
            }
        }
    }
    
    private var observer: NSObjectProtocol?
    
    //MARK: Model
    
    // boards is an array of switchboards.
    ///var boards = [SwitchBoard]()
    
    // hubs is an array of hubs
    var hubs = [Hub]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        view.addSubview(updateSpinner)
        setupSpinner()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add radio listning station to let "DSNotificationDataUpdate".
        let stationName = NSNotification.Name("DSNotificationDataUpdate")
        self.observer = NotificationCenter.default.addObserver(forName: stationName, object: nil, queue: nil) { [weak self] (notification) in
            let info: Any? = notification.userInfo
            if let info = info{
                let data = info as! [String: Any]
                if data["Spin"] != nil {
                    if data["Spin"] as? Bool == true {
                        self?.isUpdateOngoing = true
                        // Disable User Interaction Here!
                    } else if data["Spin"] as? Bool == false {
                        self?.isUpdateOngoing = false
                    }
                } else if data["Hubs"] != nil {
                    let arrayOfHubs = data["Hubs"] as? [Hub]
                    if let hubs = arrayOfHubs {
                        self?.hubs = hubs
                        self?.tableView.reloadData()
                        self?.isUpdateOngoing = false
                        // Enable back the User Interaction!
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return hubs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hubs[section].boards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switchBoardCell", for: indexPath)

        let board = hubs[indexPath.section].boards[indexPath.row]
        
        if let x = cell as? SwitchBoardTableViewCell {
            x.switch1.tag = indexPath.section * 100 + indexPath.row
            x.switch2.tag = indexPath.section * 100 + indexPath.row
            x.switch3.tag = indexPath.section * 100 + indexPath.row
            x.switch4.tag = indexPath.section * 100 + indexPath.row
            x.node = board
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
