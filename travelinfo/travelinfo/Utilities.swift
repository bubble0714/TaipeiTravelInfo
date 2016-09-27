//
//  Utilities.swift
//  travelinfo
//
//  Created by Milly on 9/27/16.
//  Copyright © 2016 Milly. All rights reserved.
//

import UIKit

extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = characters.index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
}

extension UIViewController {
    
    var activityIndicatorTag: Int { return 999999 }
    
    func startActivityIndicator(style: UIActivityIndicatorViewStyle = .gray,
                                location: CGPoint? = nil) {
        
        //Set the position - defaults to `center` if no`location`
        
        //argument is provided
        
        let loc = location ?? self.view.center
        
        //Ensure the UI is updated from the main thread
        
        //in case this method is called from a closure
        
        DispatchQueue.main.async(execute: {
            
            //Create the activity indicator
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
            //Add the tag so we can find the view in order to remove it later
            
            activityIndicator.tag = self.activityIndicatorTag
            activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
            
            //Set the location
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            //Start animating and add the view
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        })
    }
    
    func stopActivityIndicator() {
        
        //Ensure the UI is updated from the main thread!
        
        DispatchQueue.main.async(execute: {
            //Find the `UIActivityIndicatorView` and remove it from the view
            
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        })
    }
    
    func isIndicatorShow() -> Bool {
        var isShow = false
        
        if let activityIndicator = self.view.subviews.filter(
            { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
            if(activityIndicator.isAnimating){
                isShow = true
            }else{
                isShow = false
            }
        }
        
        return isShow
    }

}
