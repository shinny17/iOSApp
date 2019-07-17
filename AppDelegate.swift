//
//  AppDelegate.swift
//  BookProject
//


import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UITabBarControllerDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "BookCase")!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.setupTabbarcontroller(index: 0)
        
        return true
    }
    
    func setupTabbarcontroller(index:NSInteger)
    {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let tabBarcontroller = storyBoard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
        
        tabBarcontroller.delegate = self
        
        for navigation in tabBarcontroller.viewControllers!
        {
            let nav = navigation as! UINavigationController
            nav.navigationBar.barTintColor = UIColor.white
            nav.navigationBar.tintColor = UIColor.black
            
            let controller = nav.viewControllers[0]
            
            var strImg : String = ""
            var strTitle : String = ""
            
            if controller.isKind(of: SearchViewController.self)
            {
                strImg = "SearchTab"
                strTitle = "Search"
            }
            else if controller.isKind(of: ScanViewController.self)
            {
                strImg = "ScanTab"
                strTitle = "Scan"

            }
            else if controller.isKind(of: MyBookViewController.self){
                
                strImg = "MyBooksTab"
                strTitle = "MyBooks"

            }
            else if controller.isKind(of: HelpViewController.self){
                
                strImg = "Help"
                strTitle = "Help"
            }
           
            var image = UIImage.init(named: strImg)
            image = image?.withRenderingMode(.alwaysOriginal)
            
            navigation.tabBarItem.image = image
            navigation.tabBarItem.title = strTitle
            
            
        }
        
        tabBarcontroller.tabBar.tintColor = UIColor.black
        tabBarcontroller.selectedIndex = 0
        tabBarcontroller.tabBar.isTranslucent  = false
        
        self.window?.rootViewController = tabBarcontroller
        self.window?.makeKeyAndVisible()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let nav = viewController as! UINavigationController
        nav.popToRootViewController(animated: false)
        
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

