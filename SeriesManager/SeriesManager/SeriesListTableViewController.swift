//
//  SeriesListTableViewController.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 21/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit
import RxSwift

class SeriesListTableViewController: UITableViewController {

    var watchedShows = [WatchedShow]()
    private let cellIdentifier = "calendarCell"
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.addTarget(self, action: #selector(loadWatchedShows), for: .valueChanged)
        loadWatchedShows(useCache: true)
    }

    @objc
    private func loadWatchedShows(useCache: Bool = false) {
        RestAPI.getAllShows(useCache: useCache).observeOn(MainScheduler.instance)
        .subscribe(
            onNext: {
                self.watchedShows = $0
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
        },
            onError: { err in
                self.refreshControl?.endRefreshing()
        }).addDisposableTo(bag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchedShows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return watchedShows[indexPath.row].nextEpisode == nil ? 44 : 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CalendarTableViewCell
            ?? UINib(nibName: "CalendarTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CalendarTableViewCell
        let watchedShow = watchedShows[indexPath.row]

        cell.lblTitle.text = watchedShow.show.title
        
        if watchedShow.nextEpisode == nil {
            cell.lblDate.isHidden = true
            cell.lblEpisode.isHidden = true
            cell.lblProgress.text =  "100%"
        } else {
            cell.lblDate.isHidden = false
            cell.lblEpisode.isHidden = false
            cell.lblDate.text = Util.formatDate(watchedShow.nextEpisode.firstAired)
            cell.lblEpisode.text = String(format: "S%02dE%02d - %@", watchedShow.nextEpisode.season, watchedShow.nextEpisode.number, watchedShow.nextEpisode.title)
            cell.lblProgress.text =  "\(watchedShow.progress!)%"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
