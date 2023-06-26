//
//  SceneDelegate.swift
//  Location
//
//  Created by Iwy2th on 18/04/2023.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    let tabController = window!.rootViewController as! UITabBarController
    if let tabviewControllers = tabController.viewControllers {
      // First tab
      var navController = tabviewControllers[0] as! UINavigationController
      let controller1 = navController.viewControllers.first as! CurrenLocationViewController
      controller1.managedObjectContext = managedObjectContext
      // Second tab
      navController = tabviewControllers[1] as! UINavigationController
      let controller2 = navController.viewControllers.first as! LocationsViewController
      controller2.managerObjectContext = managedObjectContext
      // Third tab
      navController = tabviewControllers[2] as! UINavigationController
      let controller3 = navController.viewControllers.first as! MapViewController
      controller3.managedObjectContext = managedObjectContext
    }
    listenForFatalCoreDataNotification()
    //   guard let _ = (scene as? UIWindowScene) else { return }
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
  }

  func sceneWillResignActive(_ scene: UIScene) {
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    saveContext()
  }

  // MARK: - Core Data stack
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Location")
    container.loadPersistentStores(completionHandler: { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  lazy var managedObjectContext = persistentContainer.viewContext
  // MARK: - Core Data Saving support

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  // MARK: - Helper methods
  func listenForFatalCoreDataNotification() {
    // 1
    NotificationCenter.default.addObserver(forName: dataSaveFailedNotification, object: nil, queue: OperationQueue.main) { _ in
    // 2
      let message = """
                    There war a fatal error in the app and it cannot continue.
                    Press OK to terminate the app.
                    Sorry for the inconvenience.
                    """
    // 3
      let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: .alert)
    // 4
      let action = UIAlertAction(title: "OK", style: .default) {
        _ in
        let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data")
        exception.raise()
      }
      alert.addAction(action)
    // 5
      let tabController = self.window?.rootViewController!.tabBarController!.present(alert, animated: true, completion: nil)
    }
  }
}

