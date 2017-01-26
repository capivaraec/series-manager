//
//  ProfileTableViewController.swift
//  SeriesManager
//
//  Created by Mauricio Balena Mazzocco on 26/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit
import RxSwift
import SDWebImage
import AppController

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var memberSince: UILabel!
    @IBOutlet weak var seriesNumber: UILabel!
    @IBOutlet weak var watchedTime: UILabel!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        loadUserInformation()
    }
    
    private func loadUserInformation() {
        RestAPI.getUserInformation().observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { userSettings in
                    if let userSettings = userSettings {
                        self.userName.text = userSettings.name
                        self.memberSince.text = "Membro desde: \(Util.formatDate(userSettings.memberSince, dateStyle: .medium, timeStyle: .none))"
                        self.seriesNumber.text = "\(userSettings.watchedShows!) séries (\(userSettings.watchedEpisodes!) episódios)"
                        
                        let duration = Util.minutesToDaysHoursMinutes(userSettings.duration)
                        self.watchedTime.text = "\(duration.days) dias, \(duration.hours) horas e \(duration.minutes) minutos assistidos"
                        self.userAvatar.sd_setImage(with: URL(string:userSettings.avatarUrl)!)
                    }
            },
                onError: { err in
                    //TODO: fodeu
            }).addDisposableTo(bag)
    }
    
    private func logout() {
//        self.tabBarController?.showInfiniteProgress(fullScreen: true)
        RestAPI.revokeToken { (success) in
            if success {
                AppController.didLogout()
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            logout()
        }
    }
}
