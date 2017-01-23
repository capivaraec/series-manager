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

    var calendars = [Calendar]()
    private let cellIdentifier = "calendarCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCalendars()
    }

    private func loadCalendars() {
        RestAPI.getCalendars { (calendars) in
            if calendars != nil {
                self.calendars = calendars!
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CalendarTableViewCell
            ?? UINib(nibName: "CalendarTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CalendarTableViewCell
        let calendar = calendars[indexPath.row]

        cell.lblTitle.text = calendar.show.title
        cell.lblEpisode.text = String(format: "S%02dE%02d - %@", calendar.episode.season, calendar.episode.number, calendar.episode.title)
        cell.lblDate.text = Util.formatDate(calendar.firstAired)
        cell.lblWatched.text = "calcular porcentagem"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
