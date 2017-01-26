//
//  EpisodeTableViewController.swift
//  SeriesManager
//
//  Created by Mauricio Balena Mazzocco on 26/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit

class EpisodeTableViewController: UITableViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEpisodeNumber: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnWatched: UIButton!
    @IBOutlet weak var lblOverview: UILabel!
    
    var watchedShow: WatchedShow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        title = watchedShow.show.title
        lblTitle.text = watchedShow.nextEpisode.title
        lblEpisodeNumber.text = "\(watchedShow.nextEpisode.season!)ª temporada, episódio \(watchedShow.nextEpisode.number!)"
        lblDate.text = Util.formatDate(watchedShow.nextEpisode.firstAired)
        lblOverview.text = watchedShow.nextEpisode.overview
        
        tableView.tableFooterView = UIView()
    }

    @IBAction func btnPreviousTouched(_ sender: Any) {
    }
    
    @IBAction func btnNextTouched(_ sender: Any) {
    }
    
    @IBAction func btnWatchedTouched(_ sender: Any) {
    }

}
