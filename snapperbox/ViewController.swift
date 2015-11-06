//
//  ViewController.swift
//  snapperbox
//
//  Created by Jagdeep Sispal on 05/11/2015.
//  Copyright © 2015 Jagdeep Sispal. All rights reserved.
//

import UIKit
import MobileCoreServices
import AudioToolbox
import SwiftyDropbox


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var linkAccountBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadStatusLabel: UILabel!

    let picker = UIImagePickerController()
    var newImageData = NSData()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Dropbox.authorizedClient == nil){
            Dropbox.authorizeFromController(self)
        }
        
        self.uploadStatusLabel.alpha = 0;

        picker.delegate = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func linkButtonPressed(sender: AnyObject) {
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        picker.modalPresentationStyle = .FullScreen
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    
    
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        newImageData = UIImageJPEGRepresentation(image, 0.8)!
        
        // Verify user is logged into Dropbox
        if let client = Dropbox.authorizedClient {
            
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
            
            // Upload a file
            client.filesUpload(path: "/snap.jpg", autorename:true, body: newImageData).response { response, error in
                if let metadata = response {
                    print("*** Upload file ****")
                    print("Uploaded file name: \(metadata.name)")
                    print("Uploaded file revision: \(metadata.rev)")
                    
                    self.uploadStatusLabel.alpha = 1.0;
                    self.uploadStatusLabel.text = "\(metadata.name) uploaded!"
                    
                    UIView.animateWithDuration(1.0, delay: 6.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                        self.uploadStatusLabel.alpha = 0
                    }, completion:nil)
                    
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                }
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
}

