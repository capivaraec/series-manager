//
//  SeriesListTableViewController.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 21/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit
import Locksmith
import ObjectMapper

class SeriesListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let dict = Locksmith.loadDataForUserAccount(userAccount: "SeriesManagerAccount")!
        let accessToken = dict["access_token"] as! String
            // Specify the URL string that we'll get the profile info from.
            let targetURLString = "https://api.trakt.tv/calendars/my/shows"


            // Initialize a mutable URL request object.
            var request = URLRequest(url: URL(string: targetURLString)!)

            // Indicate that this is a GET request.
            request.httpMethod = "GET"

            // Add the access token as an HTTP header field.
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("f36eefe52b427fd2ed0fb2605fa3f938e2685c49785ddb00c4a2701c375bc2bc", forHTTPHeaderField: "trakt-api-key")


            // Initialize a NSURLSession object.
            let session = URLSession(configuration: URLSessionConfiguration.default)

            // Make the request.
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                let statusCode = (response as! HTTPURLResponse).statusCode

                if statusCode == 200 {
                    // Convert the received JSON data into a dictionary.
                    let mapper = Mapper<Calendar>()
                    let calendars = mapper.mapArray(JSONString: String(data: data!, encoding: .utf8)!)!
                    print("foi")
                }
            }

            task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
