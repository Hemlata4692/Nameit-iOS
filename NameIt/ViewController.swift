//
//  ViewController.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet var photoAccessDeniedLabel: UILabel!
    @IBOutlet var cameraRollCollectionView: UICollectionView!
    
    var isSelectable:Bool = true
    var rightButton:UIButton?
    var leftButton:UIButton?
    var selectUnselectImageArray:NSMutableArray = []
    
    var cameraRollAssets: NSMutableArray = []
    var groupArray: NSMutableArray = []
    let assetLibrary : ALAssetsLibrary = ALAssetsLibrary()
    
    var assetsGroup:ALAssetsGroup?
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title="Photos"
        cameraRollAssets.removeAllObjects()
        groupArray.removeAllObjects()
        cameraRollCollectionView.reloadData()
        viewInitialization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - View customization
    func viewInitialization() {
        
        photoAccessDeniedLabel.text="Allow NameIt to access Gallery in Settings"
        photoAccessDeniedLabel.isHidden=true;
        isSelectable = true
        
        //Add navigation bar buttons
        addBarButtons()
        
        //Customize right button according to image selection
        viewCustomization()
        
        //Fetch group and then fetch image assets
        getAssest()
    }
    
    func viewCustomization() {
        
        //Remove all selected images whenever click at rightBarButton(select and cancel)
        selectUnselectImageArray.removeAllObjects()
        if isSelectable {
            
            isSelectable=false;
            leftButton?.isEnabled=false
            rightButton?.setTitle("Select", for: UIControlState.normal)
            cameraRollCollectionView.reloadData()
        }
        else {
        
            isSelectable=true;
            rightButton?.setTitle("Cancel", for: UIControlState.normal)
            cameraRollCollectionView.reloadData()
        }
    }
    
    func addBarButtons() {
        
        //Navigation right bar buttons
        var framing:CGRect=CGRect(x: 0, y: 0, width: 60, height: 30)
        rightButton=UIButton.init(frame: framing)
        rightButton?.isEnabled=false
        rightButton?.setTitleColor(UIColor.white, for: UIControlState.normal)
        rightButton?.setTitle("", for: UIControlState.normal)
        rightButton?.titleLabel!.font =  UIFont.systemFont(ofSize: 17)
        rightButton?.titleEdgeInsets = UIEdgeInsetsMake(0.0, 4.0, 0.0, -4.0)
        rightButton?.addTarget(self, action: #selector(rightBarButtonAction), for: UIControlEvents.touchUpInside)
        
        let rightBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: rightButton!)
        self.navigationItem.rightBarButtonItem=rightBarButton
        
        //Navigation left bar buttons
        framing=CGRect(x: 0, y: 0, width: 30, height: 30)
        leftButton=UIButton.init(frame: framing)
        leftButton?.setImage(UIImage.init(named: "shareIcon"), for: UIControlState.normal)
        leftButton?.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 4.0)
        leftButton?.addTarget(self, action: #selector(leftBarButtonAction), for: UIControlEvents.touchUpInside)
        
        let leftBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: leftButton!)
        self.navigationItem.leftBarButtonItem=leftBarButton
    }
    // MARK: - end
    
    // MARK: - CollectionView Delegate, Datasource and DelegateFlowLayout
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cameraRollAssets.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Get a reference to our storyboard cell
        let cell:PhotoGridCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as? PhotoGridCollectionViewCell
        
        // Load the asset for this cell
        let asset:ALAsset=cameraRollAssets[indexPath.row] as! ALAsset
        let assetRepresent:ALAssetRepresentation=asset.defaultRepresentation()
        let thumbnailImageRef:CGImage=asset.aspectRatioThumbnail().takeUnretainedValue()
        let thumbnail:UIImage=UIImage.init(cgImage: thumbnailImageRef)
        cell?.cameraRollImageView.image=thumbnail
        cell?.photoName.text=assetRepresent.filename().components(separatedBy: ".").first?.capitalized
//        cell?.photoName.text=assetRepresent.filename()
        
        //Show and hide image selection according to right bar button(select and cencel)
        if isSelectable {
            
            cell?.selectUnselectImageView.isHidden=false
            //Manage image selection
            if (selectUnselectImageArray.contains(indexPath.row)) {
                
                cell?.selectUnselectImageView.image=UIImage.init(named: "check")
            }
            else {
                
                cell?.selectUnselectImageView.image=UIImage.init(named: "uncheck")
            }
        }
        else {
            
            cell?.selectUnselectImageView.isHidden=true
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSelectable {
            
            //Manage image selectiong
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoGridCollectionViewCell
            if (selectUnselectImageArray.contains(indexPath.row)) {
                
                selectUnselectImageArray.remove(indexPath.row)
                cell.selectUnselectImageView.image=UIImage.init(named: "uncheck")
            }
            else {
                
                selectUnselectImageArray.add(indexPath.row)
                cell.selectUnselectImageView.image=UIImage.init(named: "check")
            }
            
            //Manage enable and disable share button(Left bar button)
            if selectUnselectImageArray.count>0 {
                leftButton?.isEnabled=true
            }
            else {
            
                leftButton?.isEnabled=false
            }
        }
        else {
            
            //Navigate to photoGrid screen in edit mode
            let photoPreviewViewObj = self.storyboard?.instantiateViewController(withIdentifier: "PtotoPreviewViewController") as? PtotoPreviewViewController
            photoPreviewViewObj?.selectedPhotoAsset=cameraRollAssets[indexPath.row] as? ALAsset
            
            self.navigationController?.pushViewController(photoPreviewViewObj!, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 3.0
        return CGSize(width: picDimension-5, height: picDimension+30)
    }
    // MARK: - end
    
    // MARK: - Fetch ALAssetLibrary camera roll group and image assets
    func getAssest() {
        
        let groupBlock : ALAssetsLibraryGroupsEnumerationResultsBlock = {
            
            (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>!) in
            
            let onlyPhotosFilter:ALAssetsFilter?=ALAssetsFilter.allPhotos()
            
            //Set true in userDefault to check first time access popUp
            UserDefaultManager().setValue(value: true as AnyObject, keyText: "NameItPhotoAccessAlreadyCheck")
            if (group) != nil {
                
                group.setAssetsFilter(onlyPhotosFilter!)
                if group.numberOfAssets()>0 {
                    
                    self.assetsGroup=group
                    self.getImagesFromAssets()
                }
                else {
                    
                }
            } else {
            }
        }
        let groupFailureBlock : ALAssetsLibraryAccessFailureBlock = {
            (err:Error!) in
//            print(err.localizedDescription)
            self.photoAccessDeniedLabel.isHidden=true;
            let code = (err as NSError).code
            switch code {
            case ALAssetsLibraryAccessUserDeniedError, ALAssetsLibraryAccessGloballyDeniedError:
                
                self.rightButton?.isEnabled=false;
                self.photoAccessDeniedLabel.text="Allow NameIt to access Gallery in Settings"
                self.photoAccessDeniedLabel.isHidden=false;
                if (UserDefaultManager().getValue(key: "NameItPhotoAccessAlreadyCheck") != nil) {
                    
                    self.showPhotoAccessAlertMessage(title: "\"NameIt\" Would Like ot Access Your Photos", message: "Allow NameIt to access Gallery in Settings", cancel: "Cancel", ok: "Allow")
                }
                else {
                    //Set true in userDefault to check first time access popUp
                    UserDefaultManager().setValue(value: true as AnyObject, keyText: "NameItPhotoAccessAlreadyCheck")
                }
                break
            default:
                print("unknown")
            }
        }
        
        assetLibrary.enumerateGroups(withTypes: ALAssetsGroupType(ALAssetsGroupSavedPhotos), using: groupBlock, failureBlock: groupFailureBlock)
    }
    
    func getImagesFromAssets() {
        
        let assetsEnumerationBlock : ALAssetsGroupEnumerationResultsBlock = {
            (result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>!) in
            if (result) != nil {
                self.cameraRollAssets.add(result)
            }
        }
        
        let onlyPhotosFilter:ALAssetsFilter=ALAssetsFilter.allPhotos()
        self.assetsGroup?.setAssetsFilter(onlyPhotosFilter)
        //        self.assetsGroup?.enumerateAssets(assetsEnumerationBlock) //Show in asscending order
        self.assetsGroup?.enumerateAssets(options: .reverse, using: assetsEnumerationBlock)
//        print(self.cameraRollAssets.count)
        if self.cameraRollAssets.count>0 {
            
            rightButton?.isEnabled=true;
            photoAccessDeniedLabel.text="Allow NameIt to access Gallery in Settings"
            cameraRollCollectionView.isHidden=false;
        }
        else {
        
            rightButton?.isEnabled=false;
            photoAccessDeniedLabel.text="No captured photos are found"
            cameraRollCollectionView.isHidden=true;
        }
        self.cameraRollCollectionView.reloadData()
    }
    // MARK: - end
    
    // MARK: - BarButton actions
    func rightBarButtonAction() {
        
        viewCustomization()
    }
    
    func leftBarButtonAction() {
        
//        var selectedImageArrayToShare:Array<NSData> = [NSData]()
        var selectedImageArrayToShare:Array<UIImage> = [UIImage]()
        //Add selected image
        for index in selectUnselectImageArray {

            let tempAsset:ALAsset=(cameraRollAssets[index as! Int] as? ALAsset)!
            let tempAssetRepresent:ALAssetRepresentation=tempAsset.defaultRepresentation()
            let tempFullImageRef:CGImage=tempAssetRepresent.fullScreenImage().takeUnretainedValue()
            let tempFullImage:UIImage=UIImage.init(cgImage: tempFullImageRef)
            //NSData *compressedImage = UIImageJPEGRepresentation(self.resultImage, 0.8 );
//            let cI:NSData=UIImageJPEGRepresentation(tempFullImage, 0.8)! as NSData
//            let cI:NSData=UIImagePNGRepresentation(tempFullImage)! as NSData
//            selectedImageArrayToShare.append(cI)
            selectedImageArrayToShare.append(tempFullImage)
        }
        
        //Present UIActivityViewController to share images
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: selectedImageArrayToShare as [Any], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
        //Method for completion of image send or cancel
//        activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
//            activityViewController.dismiss(animated: true, completion: nil)
//        }
    }
    // MARK: - end
    
    // MARK: - Show photo access popUp
    func showPhotoAccessAlertMessage(title:String, message messageText:String, cancel cancelText:String, ok okText:String) {
        
        let alertViewController = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okText, style: .default) { (action) -> Void in
            
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) {
                UIApplication.shared.openURL(settingsURL as URL)
            }
        }
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel) { (action) -> Void in
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        
        present(alertViewController, animated: true, completion: nil)
    }
    // MARK: - end
}

