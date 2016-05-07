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
}

class StudentsTableViewController: UITableViewController {

    struct Constants{
        static let Title = "On the Map"
        static let CellReuseIdentifier = "Student Cell"
        static let InformationPostSegue = "InformationPost Segue"
    }
    
    var students = [StudentInformation]()
    var loadingData = false
    var moreStudents = true

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.Title
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self, action: #selector(StudentsTableProtocol.dropPin))
        indexStudents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return students.count
    }
    
    func indexStudents(){
        if loadingData == false && moreStudents == true{
            loadingData = true
            ParseClient.sharedInstance().index(100, skip: students.count, order: "-updatedAt"){(tempstudents,error) in
                if tempstudents != nil{
                    print("Got back students with length \(tempstudents!.count)")
                    
                    for student in tempstudents!{
                        self.students.append(student)
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
        if indexPath.row == students.count-1 {
            indexStudents()
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellReuseIdentifier, forIndexPath: indexPath) as! StudentTableViewCell
        cell.student = students[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students[indexPath.row]
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: student.mediaURL)!)
    }
    
    func dropPin(){
        performSegueWithIdentifier(Constants.InformationPostSegue, sender: nil)
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
