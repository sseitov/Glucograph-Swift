//
//  AppDelegate.swift
//  Glucograph
//
//  Created by Сергей Сейтов on 10.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit
import SVProgressHUD
//import WatchConnectivity

func IS_PAD() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    var watchSession:WCSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let comps = Calendar.current.dateComponents([.month, .year], from: Date())
        let date = Calendar.current.date(from: comps)
        changePeriod(.monthDate, date: date)
        changePeriod(.all)
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.mainColor())
        SVProgressHUD.setForegroundColor(UIColor.white)
        
        UIApplication.shared.statusBarStyle = .lightContent
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont.condensedFont()], for: .normal)
        SVProgressHUD.setFont(UIFont.condensedFont())
 /*
        // connect iWatch
        if WCSession.isSupported() {
            watchSession = WCSession.default()
            watchSession!.delegate = self
            watchSession!.activate()
        }
 */
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SyncManager.shared.upload()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SyncManager.shared.sync()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}

// MARK: - WCSession delegate
/*
extension AppDelegate : WCSessionDelegate {
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext \(applicationContext)")
    }
        
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {

        if let command = message["command"] as? String {
            if command == "status" {
                replyHandler(self.trackerStatus())
            } else if command == "start" {
                LocationManager.shared.startInBackground()
                replyHandler(["result": LocationManager.shared.isRunning()])
            } else if command == "stop" {
                LocationManager.shared.stop()
                replyHandler(["result": LocationManager.shared.isRunning()])
            } else if command == "clear" {
                LocationManager.shared.clearTrack()
                replyHandler([:])
            }
        }
 
    }
 
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("sessionReachabilityDidChange")
    }
}
*/
