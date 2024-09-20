//
//  AppDelegate.swift
//  VLEE
//
//  Created by Basleal on 2/4/21.
//
git init
git add AppDelegate.swift

git remote add origin https://github.com/NegusBas/Vlee.git

git push -u origin master

import UIKit
import IQKeyboardManagerSwift
import ObjectMapper
import AWSCore
import Firebase
import FirebaseMessaging
import AppTrackingTransparency


var DEVICE_TOKEN = ""
var AppInstance:AppDelegate!
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
//    static let shared:AppDelegate = AppDelegate()
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        IQKeyboardManager.shared.enable = true
        
        if UserDefaults.standard.value(forKey: Constants.KEYS.USERINFO) != nil
        {
            let newData = UserDefaults.standard.object(forKey: Constants.KEYS.USERINFO) as? Data
            var newDict: [AnyHashable: Any]? = nil
            if let aData = newData {
                newDict = NSKeyedUnarchiver.unarchiveObject(with: aData) as? [AnyHashable: Any]
                LoginModuleModel = Mapper<LoginModel>().map(JSONObject: newDict)!
                
               
            }
           }
        
        
        
        self.initializeS3()
        
        return true
    }

        
    func initializeS3() {
        let poolId = "***** your poolId *****"
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .APSouth1, //other regionType according to your location.
            identityPoolId: poolId
        )
        let configuration = AWSServiceConfiguration(region: .APSouth1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    
    
    func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    // Now that we are authorized we can get the IDFA
                   // print(ASIdentifierManager.shared().advertisingIdentifier)
                    if FirebaseApp.app() == nil {
                       FirebaseApp.configure()
                    }
                   
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        requestPermission()
    }
    

}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
        DEVICE_TOKEN = fcmToken ?? ""
    }
}




