//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by Nicholas Park on 5/7/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit

@objc protocol StudentsTableProtocol{
    func dropPin()
    func refreshStudents()
    func logout()
}

class StudentsTableViewController: UITableViewController {

    struct Constants{
        static let Title = "On the Map"
        static let CellReuseIdentifier = "Student Cell"
        static let InformationPostSegue = "InformationPost Segue"
        static let AlertTitle = "Error"
        static let AlertButtonTitle = "OK"
    }
    
    var loadingData = false
    var moreStudents = true

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Title
        
        let pinButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: #selector(StudentsTableProtocol.dropPin))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(StudentsTableProtocol.refreshStudents))
        navigationItem.setRightBarButtonItems([pinButton,refreshButton], animated: true)
        let logoutButtonTitle = UdacityClient.Constants.LogoutTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: logoutButtonTitle, style: .Plain, target: self, action: #selector(StudentsTableProtocol.logout))
        
        //If there aren't any students, pull some from the server
        if ParseDB.sharedInstance.students.count < 1 {
            indexStudents()
        }else{
            //There are already some students (probably from the MapViewController's Index)
            //Just load them into the table
            tableView.reloadData()
        }
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ParseDB.sharedInstance.students.count
    }
    
    func indexStudents(){
        if loadingData == false && moreStudents == true{
            loadingData = true
            ParseClient.sharedInstance.index(100, skip: ParseDB.sharedInstance.students.count, order: "-updatedAt"){(tempstudents,error) in
                if error != nil{
                    self.simpleError(error!.localizedDescription)
                    return
                }
                if tempstudents != nil{
                    print("Got back students with length \(tempstudents!.count)")
                    
                    for student in tempstudents!{
                        ParseDB.sharedInstance.students.append(student)
                    }
                    if tempstudents!.count < 100{
                        self.moreStudents = false
                    }
                    performOnMain(){
                        self.tableView.reloadData()
                    }
                    
                }else{
                    performOnMain(){
                        print(error)
                    }
                }
                self.loadingData = false
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == ParseDB.sharedInstance.students.count-1 {
            indexStudents()
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellReuseIdentifier, forIndexPath: indexPath) as! StudentTableViewCell
        cell.student = ParseDB.sharedInstance.students[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = ParseDB.sharedInstance.students[indexPath.row]
        let app = UIApplication.sharedApplication()

        let url = NSURL(string: student.mediaURL)
        if url != nil && app.canOpenURL(url!) {
            app.openURL(url!)
        }else{
            //Can't open the url so notify the user
            let alert = UIAlertController(title: Constants.AlertTitle, message: "Not a valid url", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: Constants.AlertButtonTitle, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    //Drop pins on the map
    
    func dropPin(){
        performSegueWithIdentifier(Constants.InformationPostSegue, sender: nil)
    }
    
    //Gets the student back from student information
    
    @IBAction func unwindToStudentsTable(sender: UIStoryboardSegue){
        if let sourceViewController = sender.sourceViewController as? PreviewPostViewController{
            let student = sourceViewController.studentInformation
            print("The student is \(student?.firstName)")
        }
    }
    
    //Refresh Students
    // Clears out information first and resets variables
    func refreshStudents(){
        //Remove the students first
        ParseDB.sharedInstance.students = [StudentInformation]()
        tableView.reloadData()
        loadingData = false
        moreStudents = true
        indexStudents()
    }
    
    // MARK: Logout
    
    func logout(){
        navigationItem.leftBarButtonItem?.title = UdacityClient.Constants.LoadingLabel
        UdacityClient.sharedInstance.logout(){(loggedOut,error) in
            if error != nil{
                self.simpleError(error!)
                return
            }
            if loggedOut{
                performOnMain(){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }else{
                performOnMain(){
                    self.navigationItem.leftBarButtonItem?.enabled = true
                    self.navigationItem.leftBarButtonItem?.title = UdacityClient.Constants.LogoutTitle
                    let alert = UIAlertController(title: Constants.AlertTitle, message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: Constants.AlertButtonTitle, style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
