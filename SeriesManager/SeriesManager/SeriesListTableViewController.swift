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

    var watchedShows = [WatchedShow]()
    private let cellIdentifier = "showCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCalendars()
    }

    private func loadCalendars() {
        RestAPI.getWatchedShows { (shows) in
            if shows != nil {
                self.watchedShows = shows!
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchedShows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        let watchedShow = watchedShows[indexPath.row]

        cell.textLabel?.text = watchedShow.show.title

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
