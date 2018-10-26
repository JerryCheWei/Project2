//
//  AppDelegate.swift
//  Project2
//
//  Created by chang-che-wei on 2018/8/9.
//  Copyright © 2018年 chang-che-wei. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        // google signIn
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        //離線後也可監聽
        Database.database().isPersistenceEnabled = true
        Auth.auth().addStateDidChangeListener { (auth, _) in
            //  判斷是否登錄中
            let successLogin = "successLogin"
            if Auth.auth().currentUser != nil {
                // User is signed in.
                self.window?.rootViewController?.performSegue(withIdentifier: successLogin, sender: nil)
            }
        }
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let err = error {
            print("Google signIn Error -> \(err)")
            return
        }
        else {
            guard let authentication = user.authentication else { return }
            // 註冊至 Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)

            Auth.auth().signInAndRetrieveData(with: credential) { (_ authResult, error) in
                if let error = error {
                    print("google sign in error -> \(error)")
                    return
                }
                else {
                    let successLogin = "successLogin"
                    // Perform any operations on signed in user here.
                    guard
                        let userId = user.userID,               // For client-side use only!
                        let idToken = user.authentication.idToken, // Safe to send to the server
                        let fullName = user.profile.name,
                        let givenName = user.profile.givenName,
                        let familyName = user.profile.familyName,
                        let email = user.profile.email
                        else {
                            return
                    }
                    self.saveUserInformation(userName: fullName, email: email)

                    print(userId, idToken, fullName, givenName, familyName, email)
                    self.window?.rootViewController?.performSegue(withIdentifier: successLogin, sender: nil)
                }
            }
        }

    }

    func saveUserInformation(userName: String, email: String) {
        guard let user = Auth.auth().currentUser
            else {
                return
        }
        let usersRef = Database.database().reference().child("users").child(user.uid)
        usersRef.setValue(
            ["userName": userName,
             "email": email
            ])
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Project2")
        container.loadPersistentStores(completionHandler: { (_ storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                 /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
