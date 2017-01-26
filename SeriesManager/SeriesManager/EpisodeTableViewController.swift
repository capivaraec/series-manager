//
//  EpisodeTableViewController.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 26/01/17.
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
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    
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
        
        if currentEpisode.number == 1 {
            btnPrevious.isEnabled = false
        }
        lblTitle.text = currentEpisode.title
        lblEpisodeNumber.text = "\(currentEpisode.season!)ª temporada, episódio \(currentEpisode.number!)"
        lblDate.text = Util.formatDate(currentEpisode.firstAired)
        lblOverview.text = currentEpisode.overview
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    private func loadEpisode(number: Int) {
        RestAPI.getEpisode(showId: watchedShow.show.ids.slug, season: currentEpisode.season, number: number).observeOn(MainScheduler.instance)
            .subscribe(onNext: { episode in
                if episode.title != nil {
                    self.currentEpisode = episode
                } else {
                    self.btnNext.isEnabled = false
                }
                
                self.setupUI()
            }).addDisposableTo(bag)
    }

    @IBAction func btnPreviousTouched(_ sender: Any) {
        btnNext.isEnabled = true
        let number = currentEpisode.number - 1
        
        loadEpisode(number: number)
    }
    
    @IBAction func btnNextTouched(_ sender: Any) {
        btnPrevious.isEnabled = true
        let number = currentEpisode.number + 1
        
        loadEpisode(number: number)
    }
    
    @IBAction func btnWatchedTouched(_ sender: Any) {
        RestAPI.watchEpisode(currentEpisode).observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.btnNextTouched(self)
            }).addDisposableTo(bag)
    }

}
