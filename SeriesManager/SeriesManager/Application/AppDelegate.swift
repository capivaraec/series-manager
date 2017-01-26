//
//  AppDelegate.swift
//  SeriesManager
//
//  Created by Marcelo Bogdanovicz on 21/01/17.
//  Copyright © 2017 Capivara E.C. All rights reserved.
//

import UIKit
import AppController
import Locksmith

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let appController: AppController = {

        let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)

        let controller = AppController(loginInterfaceProvider: { mainStoryboard.instantiateInitialViewController()! },
                                       mainInterfaceProvider: { mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") })
        controller.isLoggedInBlock = {
            return Configuration.getAccessToken() != nil
        }

        controller.didLogoutBlock = {
            Configuration.revokeAuthorization()
            Configuration.deleteCache()
        }

        controller.didLoginBlock = {
        }
        return controller
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        appController.application(application, didFinishLaunchingWithOptions: launchOptions)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appController.rootViewController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

