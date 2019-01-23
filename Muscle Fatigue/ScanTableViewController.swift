//
//  ScanTableViewController.swift
//  Muscle Fatigue
//
//  Created by Antonio Rodriguez on 1/20/19.
//  Copyright © 2019 uga. All rights reserved.
//

import UIKit
import MetaWear
import MBProgressHUD


protocol ScanTableViewControllerDelegate {
    func scanTableViewController(_ controller: ScanTableViewController, didSelectDevice device: MetaWear)
}

class ScanTableViewController: UITableViewController{
    
    var scannerModel: ScannerModel!
    var selected: [ScannerModelItem] = []
    var delegate: ScanTableViewControllerDelegate?
    var hud: MBProgressHUD?
    
    

    @IBOutlet weak var scanforDevice: UISwitch!
    
    @IBAction func bluetoothDiscover(_ sender: UISwitch) {
        if sender.isOn{
            scannerModel.isScanning = true
        }
        else{
            scannerModel.items.removeAll()
            scannerModel.isScanning = false
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scannerModel = ScannerModel(delegate: self)
        selected = []
        
        // enable bluetooth button switch
        scanforDevice.isOn = true
        scannerModel.isScanning = true
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scannerModel.isScanning = false
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannerModel.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewDeviceFound", for: indexPath)
        
        // Configure the cell...
        let cur = scannerModel.items[indexPath.row]
        
        // MAC Address has tag = 1
        let deviceMacAddresLabel = cell.viewWithTag(1) as! UILabel
        deviceMacAddresLabel.text = cur.device.mac ?? "Connect for MAC"
        
        
        
//        let connected = cell.viewWithTag(3) as! UILabel
//        if cur.device.isConnectedAndSetup {
//            connected.isHidden = false
//        } else {
//            connected.isHidden = true
//        }
        
        // Device Names has tag = 2
        let deviceName = cell.viewWithTag(2) as! UILabel
        deviceName.text = cur.device.name

//        let rssi = cell.viewWithTag(3) as! UILabel
//        let signal = cell.viewWithTag(4) as! UIImageView
//
//
//        if let movingAverage = cur.device.averageRSSI() {
//            rssi.isHidden = false
//            rssi.text = String(Int(movingAverage.rounded()))
//            if movingAverage < -80.0 {
//                signal.image = UIImage(named: "wifi_d1")
//            } else if movingAverage < -70.0 {
//                signal.image = UIImage(named: "wifi_d2")
//            } else if movingAverage < -60.0 {
//                signal.image = UIImage(named: "wifi_d3")
//            } else if movingAverage < -50.0 {
//                signal.image = UIImage(named: "wifi_d4")
//            } else if movingAverage < -40.0 {
//                signal.image = UIImage(named: "wifi_d5")
//            } else {
//                signal.image = UIImage(named: "wifi_d6")
//            }
//        } else {
//            signal.image = UIImage(named: "wifi_not_connected")
//            rssi.isHidden = true
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud?.label.text = "Attempting to Connect..."
        
        scannerModel.items[indexPath.row].toggleConnect()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Discovered Devices"
    }

}

extension ScanTableViewController: ScannerModelDelegate {
    func scannerModel(_ scannerModel: ScannerModel, didAddItemAt idx: Int) {
        tableView.insertRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
    }
    
    func scannerModel(_ scannerModel: ScannerModel, confirmBlinkingItem item: ScannerModelItem, callback: @escaping (Bool) -> Void) {
        hud?.hide(animated: true)
        hud = nil
        
        let alert = UIAlertController(title: "Confirm Device", message: "Do you see a blinking green LED on the Devices", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel) { _ in
            callback(false)
        })
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            callback(true)
            self.delegate?.scanTableViewController(self, didSelectDevice: item.device)
        })
        present(alert, animated: true, completion: nil)
    }
    
    func scannerModel(_ scannerModel: ScannerModel, errorDidOccur error: Error) {
        hud?.hide(animated: false)
        hud = nil
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
