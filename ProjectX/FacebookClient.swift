//
//  FacebookClient.swift
//  ProjectX
//
//  Created by Jonathan Chou on 3/16/16.
//  Copyright © 2016 Jonathan Chou. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class FacebookClient {
    
    func login(controller: UIViewController, completionHandler: (authID: String) -> Void) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["public_profile","email", "user_friends"], fromViewController: controller,handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                FirebaseClient.Constants.BASE_REF.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            // save user's authID onto the phone
                            let prefs = NSUserDefaults.standardUserDefaults()
                            prefs.setValue(authData.uid, forKey: "authID")
                            
                            // update user data on firebase
                            let user = User(name: authData.providerData["displayName"] as! String)
                            let userRef = FirebaseClient.Constants.USER_REF.childByAppendingPath(authData.uid)
                            
                            userRef.updateChildValues(["name": user.name, "userid": authData.uid])
                            
                            completionHandler(authID: authData.uid)
                        }
                })
            }
        })
    }
    
    func searchForFriendsList(completionHandler: (result: [Friend], picture: UIImage?, error: NSError?) ->  Void) {

        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name, picture.type(large)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            var profileImage: UIImage?
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                // returns friend array
                //print(result)
                //print(result["picture"])
                var newFriends = [Friend]()
                for friend in result["data"] as! NSArray {
                    if let friendPicture = friend["picture"]! {
                        if let pictureData = friendPicture["data"]! {
                            let pictureURLString = pictureData["url"] as! String
                            // might have to make url into nsurl here?
                            let pictureURL = NSURL(string: pictureURLString)

                            
                            if let image = NSData(contentsOfURL: pictureURL!) {
                                profileImage = UIImage(data: image)!
                            }
                        }
                    }
                    let friend = Friend(name: friend["name"] as! String, image: profileImage)
                    newFriends.append(friend)
                }
                completionHandler(result: newFriends, picture: profileImage, error: error)
            }
        })
        
    }
    
    class func sharedInstance() -> FacebookClient {
        struct Singleton {
            static var sharedInstance = FacebookClient()
        }
        return Singleton.sharedInstance
    }
}