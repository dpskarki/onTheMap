//
//  ViewController.swift
//  OnTheMap
//
//  Created by Dipesh karki on 14/01/2016.
//  Copyright © 2016 Dipesh karki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loginButton(sender: UIButton) {
        
        let email = emailAddress.text!
        let pass = password.text!
        
        //all fields are required
        guard (email.isEmpty == false && pass.isEmpty == false) else {
            errorMessage("All fields are required")
            return
        }
        
        //remove whitespace
        let trimEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //configuring the request
        let url = "https://www.udacity.com/api/session"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(trimEmail)\", \"password\": \"\(pass)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        //Make the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (data, response, error)  in
            
            guard (error == nil) else {
                print("There is something wrong")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print(response.statusCode)
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            
            guard (data == data) else {
                print("No data was found")
                return
            }
        
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            //parse the data and saving session Id to app Delegate
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                
                if let session = json["session"] as? [String: AnyObject] {
                    if let sessionId = session["id"] as? String {
                        let object = UIApplication.sharedApplication().delegate
                        let appDelegate = object as! AppDelegate
                        appDelegate.sessionId = sessionId
                        self.completeLogin()
                    }
                }
            }
                
            catch {
                print("error serializing JSON: \(error)")
            }
   
            
        }
        task.resume()

    }
    
    
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        })

    }
    
    func errorMessage(errorMessage: String) {
        let alert = UIAlertController(title: "Something Went Wrong", message: errorMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil )
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    

}

