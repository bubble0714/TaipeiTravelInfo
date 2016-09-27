//
//  File.swift
//  travelinfo
//
//  Created by Milly on 9/23/16.
//  Copyright © 2016 Milly. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "travelinfo")
    container.loadPersistentStores { storeDescription, error in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    return container
}()

class RESTManager: NSObject, URLSessionDelegate {

    static let sharedInstance = RESTManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let MAX_QUERY_DATA_TIMEOUT: TimeInterval = 30
    let ENTITY_NAME: String = "TravelPlace"
    let FILTER_KEY_TYPE: String = "type"
    var travelInfo = [TravelPlaceData]()
    var travelPlaceResults: [TravelPlace] = []
    
    struct TravelPlaceData{
        var placeType: String
        var placeTitle: String
        var introduction: String
        var fileName: String
        
        init(place_type: String, place_title: String, introduction:String, file_name: String){
            self.placeType = place_type
            self.placeTitle = place_title
            self.introduction = introduction
            self.fileName = file_name
        }
    }
    
    
    // *******************************************
    //               GET http data
    // *******************************************
    func getData(url: String, callback: @escaping ([TravelPlace], String?) -> Void) {
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = MAX_QUERY_DATA_TIMEOUT
        urlconfig.timeoutIntervalForResource = MAX_QUERY_DATA_TIMEOUT
        let session = URLSession(configuration: urlconfig)
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest){
            (data, response, error) -> Void in
            if error != nil {
                print("error: \(error.debugDescription)")
                
            } else {
                if let _data = data {
                    
                    let json: JSON = JSON(data: _data as Data)
                    
                    if let total_count: Int = json["result"]["results"].count {
                        if(total_count > 0){
                            var cat2_str:String = ""
                            var stitle_str:String = ""
                            var xbody_str:String = ""
                            var file_str:String = ""
                            
                            for i in 0...total_count - 1{
                                cat2_str = ""
                                stitle_str = ""
                                xbody_str = ""
                                file_str = ""
                                
                                if let cat2:String = json["result"]["results"][i]["CAT2"].stringValue {
                                    cat2_str = cat2
                                }else{
                                    print("CAT2: null")
                                }
                                
                                if let stitle = json["result"]["results"][i]["stitle"].string {
                                    stitle_str = stitle
                                }else{
                                    print("stitle: null")
                                }
                                
                                if let xbody = json["result"]["results"][i]["xbody"].string {
                                    xbody_str = xbody
                                }else{
                                    print("xbody: null")
                                }
                                
                                if let file = json["result"]["results"][i]["file"].string {
                                    file_str = file
                                }else{
                                    print("file: null")
                                }
                               
                                self.saveRow(index: Int32(i), cat2: cat2_str, stitle: stitle_str, xbody: xbody_str, file: file_str)
                            }
                            
                        }
                        
                        self.fetchAllData(){(all_data) -> Void in
                            callback(all_data,nil)
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    
    func saveRow(index: Int32, cat2: String, stitle: String, xbody: String, file: String){
        
        let travelPlace = NSEntityDescription.insertNewObject(forEntityName: ENTITY_NAME, into: context) as! TravelPlace
        travelPlace.id = index
        travelPlace.type = cat2
        travelPlace.placename = stitle
        travelPlace.introduction = xbody
        travelPlace.filename = file
        
        do{
            try context.save()
        }catch{
            fatalError("\(error)")
        }
    }
    

    func fetchAllData(callback: @escaping ([TravelPlace]) -> Void){
        
        let request: NSFetchRequest<TravelPlace> = TravelPlace.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: FILTER_KEY_TYPE, ascending: false)]
        
        let asyncRequest = NSAsynchronousFetchRequest<TravelPlace>(fetchRequest: request) { result in
            let results = result.finalResult ?? []
            
            // Then you can use your properties.
            
            for location in results {
                print("ID: \(location.id) | place name: \(location.placename)")
            }
            
            callback(results)
        }
        
        
        try! persistentContainer.viewContext.execute(asyncRequest)
    }
    
    func fetchTypeBySelection(selection_type:String, callback: @escaping ([TravelPlace]) -> Void){
        let request: NSFetchRequest<TravelPlace> = NSFetchRequest()
        if let entityDescription:NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_NAME, in: context){
            request.entity = entityDescription
        }
        
        let predicate = NSPredicate(format: "type == %@", selection_type)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        
        let asyncRequest = NSAsynchronousFetchRequest<TravelPlace>(fetchRequest: request) { result in
            let results = result.finalResult ?? []
            
            // Then you can use your properties.
            callback(results)
        }
        
        try! persistentContainer.viewContext.execute(asyncRequest)
    }
    
    func fetchPlaceType(callback: @escaping ([String]) -> Void){
        var typeList:[String] = []
        let request: NSFetchRequest<TravelPlace> = NSFetchRequest()
        if let entityDescription:NSEntityDescription = NSEntityDescription.entity(forEntityName: "TravelPlace", in: context){
            request.entity = entityDescription
        }
        request.returnsObjectsAsFaults = false
        request.propertiesToGroupBy = [FILTER_KEY_TYPE]
        request.propertiesToFetch = [FILTER_KEY_TYPE]
        request.resultType = .dictionaryResultType
        request.sortDescriptors = [NSSortDescriptor(key: FILTER_KEY_TYPE, ascending: true)]
        
        let asyncRequest = NSAsynchronousFetchRequest<TravelPlace>(fetchRequest: request) { result in
            self.travelPlaceResults = result.finalResult ?? [] as [TravelPlace]
            
            let results = self.travelPlaceResults as NSArray
            
            for (_, value) in results.enumerated(){
                //print("type: \(index + 1): \(value)")
                
                let transform = "Any-Hex/Java"
                let input = String(describing: value).lowercased()
                let convertedString = input.mutableCopy() as! NSMutableString
                
                CFStringTransform(convertedString, nil, transform as NSString, true)
                if let startIndex = input.indexDistance(of: "="){
                    let str = convertedString.substring(with: NSMakeRange(startIndex + 3, 4))
                    typeList.append(str as String)
                }
            }
            
            callback(typeList)
        }

        try! persistentContainer.viewContext.execute(asyncRequest)
    }
   
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
}
