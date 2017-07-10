//
//  ViewController.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet var searchBarObject: UISearchBar!
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
    
    var isSearch:Bool=false
    var searchedCameraRollAssets: NSMutableArray = []
    
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title="Gallery"
        viewInitialization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - View customization
    func viewInitialization() {
        
        //Initialized variables
        isSearch=false
        cameraRollAssets = []
        searchedCameraRollAssets = []
        groupArray = []
        cameraRollCollectionView.reloadData()
        searchBarObject.text=""
        
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
        rightButton?.titleEdgeInsets = UIEdgeInsetsMake(0.0, 12.0, 0.0, -12.0)
        rightButton?.addTarget(self, action: #selector(rightBarButtonAction), for: UIControlEvents.touchUpInside)
        
        let rightBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: rightButton!)
        self.navigationItem.rightBarButtonItem=rightBarButton
        
        //Navigation left bar buttons
        framing=CGRect(x: 0, y: 0, width: 30, height: 30)
        leftButton=UIButton.init(frame: framing)
        leftButton?.setImage(UIImage.init(named: "shareIcon"), for: UIControlState.normal)
        leftButton?.imageEdgeInsets = UIEdgeInsetsMake(0.0, -12.0, 0.0, 12.0)
        leftButton?.addTarget(self, action: #selector(leftBarButtonAction), for: UIControlEvents.touchUpInside)
        
        let leftBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: leftButton!)
        self.navigationItem.leftBarButtonItem=leftBarButton
    }
    // MARK: - end
    
    // MARK: - CollectionView Delegate, Datasource and DelegateFlowLayout
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isSearch {
            return searchedCameraRollAssets.count
        }
        return cameraRollAssets.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Get a reference to our storyboard cell
        let cell:PhotoGridCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as? PhotoGridCollectionViewCell
        
        // Load the asset for this cell
        
        var tempDictData:NSDictionary?
        if isSearch {
            
            tempDictData=searchedCameraRollAssets[indexPath.row] as? NSDictionary
        }
        else {
            tempDictData=cameraRollAssets[indexPath.row] as? NSDictionary
        }
        
        let asset:ALAsset?=tempDictData?.object(forKey: "Asset") as? ALAsset
        let assetRepresent:ALAssetRepresentation=asset!.defaultRepresentation()
        let thumbnailImageRef:CGImage=asset!.aspectRatioThumbnail().takeUnretainedValue()
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
        
        searchBarObject.resignFirstResponder()
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
            
            var tempDictData:NSDictionary?
            if isSearch {
                
                tempDictData=searchedCameraRollAssets[indexPath.row] as? NSDictionary
            }
            else {
                tempDictData=cameraRollAssets[indexPath.row] as? NSDictionary
            }
            
            photoPreviewViewObj?.selectedPhotoAsset=tempDictData?.object(forKey: "Asset") as? ALAsset
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
                
                let assetRepresent:ALAssetRepresentation=result!.defaultRepresentation()
                
                self.cameraRollAssets.add(["FileName":assetRepresent.filename(),
                                           "Asset":result
                                           ])
//                self.cameraRollAssets.add(result)
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
        
        searchBarObject.resignFirstResponder()
        viewCustomization()
    }
    
    func leftBarButtonAction() {
        
        searchBarObject.resignFirstResponder()
//        var selectedImageArrayToShare:Array<NSData> = [NSData]()
        var selectedImageArrayToShare:Array<UIImage> = [UIImage]()
        //Add selected image
        for index in selectUnselectImageArray {

//            var tempAsset:ALAsset?
//            if isSearch {
//                tempAsset=(searchedCameraRollAssets[index as! Int] as? ALAsset)!
//            }
//            else {
//                tempAsset=(cameraRollAssets[index as! Int] as? ALAsset)!
//            }
            
            var tempDictData:NSDictionary?
            if isSearch {
                
                tempDictData=searchedCameraRollAssets[index as! Int] as? NSDictionary
            }
            else {
                tempDictData=cameraRollAssets[index as! Int] as? NSDictionary
            }
            
            let tempAsset:ALAsset?=tempDictData?.object(forKey: "Asset") as? ALAsset
            
            
            let tempAssetRepresent:ALAssetRepresentation=tempAsset!.defaultRepresentation()
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
    
    // MARK: - UISearchBar delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        isSearch=false
        searchBarObject.resignFirstResponder()
        cameraRollCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBarObject.resignFirstResponder()
        cameraRollCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
//        if caption?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count != 0 {
        print(searchBar.text! + " " + searchText)
        
        if searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0{
            
            isSearch=false
            cameraRollCollectionView.reloadData()
        }
        else {
        
            isSearch=true
            let photoNamePredicate = NSPredicate(format: "FileName contains[cd] %@", searchText)
//            let subPredicates = NSArray.init(array: [photoNamePredicate])
            searchedCameraRollAssets=cameraRollAssets.filtered(using: photoNamePredicate) as! NSMutableArray
            print(searchedCameraRollAssets.count)
            cameraRollCollectionView.reloadData()
            
        }
//        filtered = data.filter({ (text) -> Bool in
//            let tmp: NSString = text
//            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
//            return range.location != NSNotFound
//        })
//        if(filtered.count == 0){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
//        self.tableView.reloadData()
        
    }
    // MARK: - end
}

