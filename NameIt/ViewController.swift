//
//  ViewController.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITextFieldDelegate {

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
    
    //Rename function
    var currentSelectedRenameTextfield:UITextField?
    var lastSelectedRenameTextfield:UITextField?
    var currentSelectedRenameButton:UIButton?
    var lastSelectedRenameButton:UIButton?
    var renameDatabaseDicData:NSMutableDictionary=[:]
    var lastEnteredUpdatedImageName:String=""
    var deletingDBEntries: NSMutableArray = []
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetch all entries from local dataBase
        renameDatabaseDicData=AppDelegate().fetchRenameEntries().mutableCopy() as! NSMutableDictionary
        let tempDeleteEntryArray:NSArray = renameDatabaseDicData.allKeys as NSArray
        deletingDBEntries = tempDeleteEntryArray.mutableCopy() as! NSMutableArray
        
        //Reload gallery image when come in foreground from background state
        NotificationCenter.default.addObserver(self, selector:#selector(applicationWillEnterForeground(_:)), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
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
        searchBarObject.isHidden=true
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
        rightButton?.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0)
        rightButton?.addTarget(self, action: #selector(rightBarButtonAction), for: UIControlEvents.touchUpInside)
        
        let rightBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: rightButton!)
        self.navigationItem.rightBarButtonItem=rightBarButton
        
        //Navigation left bar buttons
        framing=CGRect(x: 0, y: 0, width: 20, height: 20)
        leftButton=UIButton.init(frame: framing)
        leftButton?.setImage(UIImage.init(named: "share_White"), for: UIControlState.normal)
        leftButton?.imageEdgeInsets = UIEdgeInsetsMake(0.0, -5.0, 0.0, 5.0)
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
//        let assetRepresent:ALAssetRepresentation=asset!.defaultRepresentation()
        let thumbnailImageRef:CGImage=asset!.aspectRatioThumbnail().takeUnretainedValue()
        let thumbnail:UIImage=UIImage.init(cgImage: thumbnailImageRef)
        cell?.cameraRollImageView.image=thumbnail
        
        let imageName:String=tempDictData?.object(forKey: "FileName") as! String
        cell?.photoName.text=imageName.components(separatedBy: ".").first?.capitalized
        
        cell?.editButton.tag=indexPath.row
        cell?.editButton.addTarget(self, action: #selector(editSelectedPhotoName(_:)), for: UIControlEvents.touchUpInside)
        
        //Show and hide image selection according to right bar button(select and cencel)
        if isSelectable {
            
            cell?.editButton.isHidden=true
            cell?.selectUnselectImageView.isHidden=false
            //Manage image selection
            if (selectUnselectImageArray.contains(indexPath.row)) {
                
                cell?.selectUnselectImageView.image=UIImage.init(named: "select")
            }
            else {
                
                cell?.selectUnselectImageView.image=UIImage()
            }
        }
        else {
            
            cell?.editButton.isHidden=false
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
                cell.selectUnselectImageView.image=UIImage()
            }
            else {
                
                selectUnselectImageArray.add(indexPath.row)
                cell.selectUnselectImageView.image=UIImage.init(named: "select")
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
            
            let imageName:String=tempDictData?.object(forKey: "FileName") as! String
            photoPreviewViewObj?.selectedPhotoName=imageName.components(separatedBy: ".").first?.capitalized
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

                if !(UserDefaultManager().getValue(key: "NameItPhotoAccessAlreadyCheck") is NSNull) {
                    //Exist
                    self.showPhotoAccessAlertMessage(title: "\"NameIt\" Would Like ot Access Your Photos", message: "Allow NameIt to access Gallery in Settings", cancel: "Cancel", ok: "Allow")
                }
                else {
                    //Not exist
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
                
                if ((self.renameDatabaseDicData.object(forKey: assetRepresent.filename().components(separatedBy: ".").first as Any)) != nil) {
                    
                    var tempString:String=self.renameDatabaseDicData.object(forKey: assetRepresent.filename().components(separatedBy: ".").first as Any) as! String
                    tempString.append(".\(assetRepresent.filename().components(separatedBy: ".").last!)")
                    self.cameraRollAssets.add(["FileName":tempString,
                                               "Asset":result])
                }
                else {
                    
                    self.cameraRollAssets.add(["FileName":assetRepresent.filename(),
                                               "Asset":result])
                }
                
                if self.deletingDBEntries.contains(assetRepresent.filename().components(separatedBy: ".").first!) {
                    self.deletingDBEntries.remove(assetRepresent.filename().components(separatedBy: ".").first!)
                }
            }
        }
        
        let onlyPhotosFilter:ALAssetsFilter=ALAssetsFilter.allPhotos()
        self.assetsGroup?.setAssetsFilter(onlyPhotosFilter)
        //        self.assetsGroup?.enumerateAssets(assetsEnumerationBlock) //Show in asscending order
        self.assetsGroup?.enumerateAssets(options: .reverse, using: assetsEnumerationBlock)
        
        if self.cameraRollAssets.count>0 {
            
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                for imageName in self.deletingDBEntries {
                
                    
                }
                DispatchQueue.main.async {
                    // Run UI Updates
                }
            }
            
            searchBarObject.isHidden=false
            rightButton?.isEnabled=true;
            photoAccessDeniedLabel.text="Allow NameIt to access Gallery in Settings"
            cameraRollCollectionView.isHidden=false;
        }
        else {
        
            searchBarObject.isHidden=true
            rightButton?.isEnabled=false;
            photoAccessDeniedLabel.text="No captured photos are found"
            cameraRollCollectionView.isHidden=true;
        }
        
        self.cameraRollCollectionView.reloadData()
    }
    // MARK: - end
    
    // MARK: - IBAction
    @IBAction func editSelectedPhotoName(_ sender: UIButton) {
    
        editImageNameRecursiveMethod(seletedImageTag: sender.tag)
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
    
    // MARK: - UISearchBar delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        isSearch=false
        searchBarObject.text=""
        photoAccessDeniedLabel.isHidden=true
        searchBarObject.resignFirstResponder()
        cameraRollCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBarObject.resignFirstResponder()
        cameraRollCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0{
            
            isSearch=false
            photoAccessDeniedLabel.isHidden=true
            cameraRollCollectionView.reloadData()
        }
        else {
        
            isSearch=true
            photoAccessDeniedLabel.isHidden=true
            let photoNamePredicate = NSPredicate(format: "FileName contains[cd] %@", searchText)
            let tempArray:NSArray=cameraRollAssets.filtered(using: photoNamePredicate) as NSArray
            searchedCameraRollAssets = tempArray.mutableCopy() as! NSMutableArray
            print(searchedCameraRollAssets.count)
            if searchedCameraRollAssets.count > 0 {
                
                photoAccessDeniedLabel.isHidden=true
            }
            else {
            
                photoAccessDeniedLabel.isHidden=false
                photoAccessDeniedLabel.text="No search image found"
            }
            cameraRollCollectionView.reloadData()
        }
    }
    // MARK: - end
    
    // MARK: - Image rename handling
    func editImageNameRecursiveMethod(seletedImageTag:Int) {
        
        var tempDictData:NSDictionary?
        if isSearch {
            
            tempDictData=searchedCameraRollAssets[seletedImageTag] as? NSDictionary
        }
        else {
            tempDictData=cameraRollAssets[seletedImageTag] as? NSDictionary
        }
        
        let fileName:NSString = tempDictData?.object(forKey: "FileName") as! NSString
        
        let alert = UIAlertController(title: "", message: "Please enter new image name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let saveAction = UIAlertAction(title:"Save", style: .default, handler: { (action) -> Void in
            
            if let alertTextField = alert.textFields?.first, alertTextField.text != nil {
                
                if alertTextField.text?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != fileName
                    .components(separatedBy: ".").first!.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                    
                    var tempString:String=(alertTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    tempString = tempString + "." + fileName.components(separatedBy: ".").last!
                    
                    //First check entered name is already exist or not
                    if !self.isImageNameAlreadyExist(searchText: tempString) {
                        
                        self.editFilenameHandlingLocalAndDB(seletedImageTag: seletedImageTag, updtedText: alertTextField.text!, updtedTextWithExtension: tempString, selectedDictData: tempDictData!)
                        self.cameraRollCollectionView.reloadData()
                    }
                    else {
                        
                        alert.dismiss(animated: false, completion: nil)
                        self.showImageNameAlreadyExistAlert(title: "Alert", message: "This updated image name is already exist.", tempString: tempString, seletedImageTag: seletedImageTag)
                    }
                }
            }
        })
        alert.addAction(saveAction)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter image name"
            
            if self.lastEnteredUpdatedImageName == "" {
                textField.text=fileName
                    .components(separatedBy: ".").first?.capitalized
            }
            else {
                textField.text=self.lastEnteredUpdatedImageName
                    .components(separatedBy: ".").first?.capitalized
            }
            self.lastEnteredUpdatedImageName=""
            textField.delegate=self
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = (textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count)! > 0
            }
        })
        present(alert, animated: true, completion: nil)
    }
    
    func editFilenameHandlingLocalAndDB(seletedImageTag:Int, updtedText:String, updtedTextWithExtension:String, selectedDictData:NSDictionary) {
        
        var tempDictData1:NSDictionary?
        if self.isSearch {
            
            tempDictData1=self.searchedCameraRollAssets[seletedImageTag] as? NSDictionary
        }
        else {
            tempDictData1=self.cameraRollAssets[seletedImageTag] as? NSDictionary
        }
        
        let asset:ALAsset?=tempDictData1?.object(forKey: "Asset") as? ALAsset
        let assetRepresent:ALAssetRepresentation=asset!.defaultRepresentation()
        
        AppDelegate().insertUpdateRenamedText(imageName: assetRepresent.filename()
            .components(separatedBy: ".").first!.lowercased(), rename: (updtedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()))
        self.renameDatabaseDicData.setValue((updtedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)), forKey: assetRepresent.filename().components(separatedBy: ".").first!)
        let tempDeleteEntryArray:NSArray = renameDatabaseDicData.allKeys as NSArray
        deletingDBEntries = tempDeleteEntryArray.mutableCopy() as! NSMutableArray
        
        let index:Int=self.cameraRollAssets.index(of: selectedDictData as Any)
        let tempDictData:NSDictionary=self.cameraRollAssets.object(at: index) as! NSDictionary
        let tempMutableData:NSMutableDictionary=tempDictData.mutableCopy() as! NSMutableDictionary
        
        tempMutableData.setValue(updtedTextWithExtension, forKey: "FileName")
        self.cameraRollAssets.replaceObject(at: index, with: tempMutableData)
        if self.isSearch {
            
            self.searchedCameraRollAssets.replaceObject(at: seletedImageTag, with: tempMutableData)
        }
    }
    
    func isImageNameAlreadyExist(searchText:String) -> Bool {
        
        let tempString=searchText.components(separatedBy: ".").first! + "."
        let photoNamePredicate = NSPredicate(format: "FileName BEGINSWITH %@", tempString)
        let tempFilteredArray:NSMutableArray=cameraRollAssets.filtered(using: photoNamePredicate) as! NSMutableArray
        print(tempFilteredArray.count)
        
        if tempFilteredArray.count > 0 {
            
            return true
        }
        return false
    }
    
    //Textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        if string.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }
        
        let textLimit=30
        let str = (textField.text! + string)
        if str.characters.count <= textLimit {
            return true
        }
        textField.text = str.substring(to: str.index(str.startIndex, offsetBy: textLimit))
        return false
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
    
    func showImageNameAlreadyExistAlert(title:String, message messageText:String, tempString:String, seletedImageTag:Int) {
        
        let alertViewController = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            self.lastEnteredUpdatedImageName=tempString
            alertViewController.dismiss(animated: false, completion: nil)
            self.editImageNameRecursiveMethod(seletedImageTag: seletedImageTag)
        }
        alertViewController.addAction(okAction)
        self.navigationController?.present(alertViewController, animated: false, completion: nil)
    }
    // MARK: - end

    // MARK: - Notification observer method
    func applicationWillEnterForeground(_ notification: NSNotification) {
        
        viewInitialization()
    }
    // MARK: - end
    
}

