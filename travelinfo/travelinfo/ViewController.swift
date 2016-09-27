//
//  ViewController.swift
//  travelinfo
//
//  Created by Milly on 9/23/16.
//  Copyright © 2016 Milly. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UITableViewController {
    
    let INIT_TYPE = "所有類別"
    let manager: RESTManager = RESTManager()
    let TAIPEI_TRAVEL_INFO_URL: String = "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=36847f3f-deff-4183-a5bb-800737591de5"
    
    var results: [TravelPlace] = []
    var actionSheetController: UIAlertController?
    var searchTypeList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.topItem?.title = INIT_TYPE
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.startActivityIndicator(location:nil)
        
        self.manager.fetchAllData(){(all_data) -> Void in
            
            if(all_data.count > 0){
                print("data count: \(all_data.count)")
                self.results = all_data
                self.tableView.reloadData()
                self.stopActivityIndicator()
                self.loadPlaceType()
            }else{
                self.manager.getData(url: self.TAIPEI_TRAVEL_INFO_URL){(data, error) -> Void in
                    self.results = data
                    self.tableView.reloadData()
                    self.stopActivityIndicator()
                    self.loadPlaceType()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scroll2Top(){
        let when = DispatchTime.now() + 0
        DispatchQueue.main.asyncAfter(deadline: when){
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    func loadPlaceType(){
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            self.tableView.reloadData()
        }
        
        self.manager.fetchPlaceType(){(type_list_data) -> Void in
            self.searchTypeList = type_list_data
            self.searchTypeList.insert(self.INIT_TYPE, at: 0)
        }
    }
    
    @IBAction func searchByType(_ sender: AnyObject) {
        
        if(self.isIndicatorShow()){
          return
        }
        
        self.actionSheetController = UIAlertController(title: "景點分類", message: "請擇一類型或取消", preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        self.actionSheetController?.addAction(cancelAction)
        
        for i in 0...self.searchTypeList.count - 1{
            self.actionSheetController?.addAction(UIAlertAction(title: self.searchTypeList[i], style: .default, handler: { (action) -> Void in
                
                print("\(self.searchTypeList.index(of: action.title!))")

                self.results.removeAll()
                
                if(action.title == self.INIT_TYPE){
                    self.manager.fetchAllData(){(all_data) -> Void in
                        if(all_data.count > 0){
                            print("data count: \(all_data.count)")
                            self.results = all_data
                            self.tableView.reloadData()
                        }else{
                            self.manager.getData(url: self.TAIPEI_TRAVEL_INFO_URL){(data, error) -> Void in
                                self.results = data
                                self.tableView.reloadData()
                            }
                        }
                        
                        self.scroll2Top()
                    }
                }else{
                    self.manager.fetchTypeBySelection(selection_type:action.title!){(data) -> Void in
                        
                        self.results = data
                        self.tableView.reloadData()
                        self.scroll2Top()
                    }
                }
                self.navigationController?.navigationBar.topItem?.title = action.title
            }))
        }

        present(self.actionSheetController!, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        
        let list = results[indexPath.row]
        cell.cellTitle.text = list.placename
        cell.cellSubtitle.text = list.introduction
        
        let fullName = list.filename
        let fullNameArr = fullName?.components(separatedBy: "http://")

        for i in 0...(fullNameArr?.count)! - 1{
            if(fullNameArr?[i] != ""){
                let url = NSURL(string:("http://" + (fullNameArr?[i])!))
                
                self.manager.getDataFromUrl(url: url as! URL) { (data, response, error)  in
                    DispatchQueue.main.sync() { () -> Void in
                        guard let data = data, error == nil else { return }
                        print(response?.suggestedFilename ?? url?.lastPathComponent)
                        
                        cell.cellImage.image = UIImage(data:data as Data)
                    }
                }
                break
            }
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
}

