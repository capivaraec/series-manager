//
//  SeriesListTableViewController.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 21/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit
import RxSwift

class SeriesListTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    var watchedShows = [WatchedShow]()
    var filteredShows = [WatchedShow]()
    var filtered = true
    private let cellIdentifier = "calendarCell"
    private let bag = DisposeBag()
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.addTarget(self, action: #selector(loadWatchedShows), for: .valueChanged)
        loadWatchedShows(useCache: true)
        
        setupSearch()
    }
    
    private func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.definesPresentationContext = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.contentOffset = CGPoint(x: 0, y: tableView.tableHeaderView?.frame.height ?? 0)
    }

    @objc
    private func loadWatchedShows(useCache: Bool = false) {
        RestAPI.getAllShows(useCache: useCache).observeOn(MainScheduler.instance)
        .subscribe(
            onNext: {
                self.watchedShows = $0
                
                if self.filtered {
                    self.filterShows()
                }
                
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
        return filtered ? filteredShows.count : watchedShows.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let show = filtered ? filteredShows[indexPath.row] : watchedShows[indexPath.row]
        return show.nextEpisode == nil ? 44 : 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? CalendarTableViewCell
            ?? UINib(nibName: "CalendarTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CalendarTableViewCell
        let watchedShow = filtered ? filteredShows[indexPath.row] : watchedShows[indexPath.row]

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
        let watchedShow = filtered ? filteredShows[indexPath.row] : watchedShows[indexPath.row]
        performSegue(withIdentifier: "showSegue", sender: watchedShow)
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    private func filterShows() {
        filteredShows = watchedShows.filter { return $0.nextEpisode != nil }
    }

    @IBAction func filterTouched(_ sender: Any) {
        filtered = !filtered
        if filtered {
            filterShows()
        }
        
        tableView.reloadData()
    }
}
