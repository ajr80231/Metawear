//
//  DeviceTableViewController.swift
//  Muscle Fatigue
//
//  Created by Antonio Rodriguez on 1/20/19.
//  Copyright © 2019 uga. All rights reserved.
//

import UIKit
import MetaWear
import MetaWearCpp
import MBProgressHUD
import BoltsSwift

class MainTableViewController: UITableViewController, ScanTableViewControllerDelegate {

    var devices: [MetaWear] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        updateList()
    }
    
    func updateList(){
        MetaWearScanner.shared.retrieveSavedMetaWearsAsync().continueOnSuccessWith(.mainThread){
            self.devices = $0
            self.tableView.reloadData()
        }
    }
    
    func scanTableViewController(_ controller: ScanTableViewController, didSelectDevice device: MetaWear) {
        navigationController?.popViewController(animated: true)
        self.updateList()
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return devices.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!

        if indexPath.row < devices.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "MetaWearCell", for: indexPath)
            
            let currentDevice = devices[indexPath.row]
            
            let deviceNameLabel = cell.viewWithTag(1) as! UILabel
            deviceNameLabel.text = "Device Name: " + currentDevice.name
            
            let deviceMacAddresLabel = cell.viewWithTag(2) as! UILabel
            deviceMacAddresLabel.text = "Mac: " + currentDevice.mac!
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "NoDeviceCell", for: indexPath)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < devices.count {
            performSegue(withIdentifier: "ViewDevice", sender: devices[indexPath.row])
        } else {
            performSegue(withIdentifier: "AddNewDevice", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.ƒ
        return indexPath.row < devices.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            devices[indexPath.row].eraseDevice()
            devices.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if let scanController = segue.destination as? ScanTableViewController {
            scanController.delegate = self
        }
    }
}
extension MetaWear {
    // Call once to setup a device

    // If you no longer need a device call this
    @discardableResult
    func eraseDevice() -> Task<MetaWear> {
        // Remove the on-disk state
        try? FileManager.default.removeItem(at: uniqueUrl)
        // Drop the device from the MetaWearScanner saved list
        forget()
        // Reset and clear all data from the device
        return connectAndSetup().continueOnSuccessWithTask {
            self.clearAndReset()
            return $0
        }
    }
}
