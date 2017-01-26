//
//  EpisodeTableViewController.swift
//  SeriesManager
//
//  Created by Mauricio Balena Mazzocco on 26/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit
import RxSwift

class EpisodeTableViewController: UITableViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEpisodeNumber: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnWatched: UIButton!
    @IBOutlet weak var lblOverview: UILabel!
    
    var watchedShow: WatchedShow!
    var currentEpisode: Episode!
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentEpisode = watchedShow.nextEpisode
        setupUI()
    }
    
    private func setupUI() {
        title = watchedShow.show.title
        
        lblTitle.text = currentEpisode.title
        lblEpisodeNumber.text = "\(currentEpisode.season!)ª temporada, episódio \(currentEpisode.number!)"
        lblDate.text = Util.formatDate(currentEpisode.firstAired)
        lblOverview.text = currentEpisode.overview
        
        tableView.tableFooterView = UIView()
    }
    
    private func loadEpisode(number: Int) {
        RestAPI.getEpisode(showId: watchedShow.show.ids.slug, season: currentEpisode.season, number: number).observeOn(MainScheduler.instance)
            .subscribe( onNext: { episode in
                self.currentEpisode = episode
                self.setupUI()
            }
            ).addDisposableTo(bag)
    }

    @IBAction func btnPreviousTouched(_ sender: Any) {
        let number = currentEpisode.number - 1
        
        loadEpisode(number: number)
    }
    
    @IBAction func btnNextTouched(_ sender: Any) {
        let number = currentEpisode.number + 1
        
        loadEpisode(number: number)
    }
    
    @IBAction func btnWatchedTouched(_ sender: Any) {
    }

}
