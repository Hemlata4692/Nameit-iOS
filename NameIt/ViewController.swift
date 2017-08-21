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

    @IBOutlet var searchBarBackView: UIView!
    @IBOutlet var searchBarObject: UISearchBar!
    @IBOutlet var searchCancelButton: UIButton!
    @IBOutlet var photoAccessDeniedLabel: UILabel!
    @IBOutlet var cameraRollCollectionView: UICollectionView!
    //Local variable declaration
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
    var renameDatabaseDicData:NSMutableDictionary?
    var lastEnteredUpdatedImageName:String=""
    var deletingDBEntries: NSMutableArray = []
    var scrollAtIndex:Int=0
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create document directory folder
        createImagesFolder()
        self.navigationController?.isNavigationBarHidden=false
        UIApplication.shared.isStatusBarHidden=false
        //Fetch entries from local database
        loadVeiwImageEdited()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Reload gallery image when come in foreground from background state
        NotificationCenter.default.addObserver(self, selector:#selector(applicationWillEnterForeground(_:)), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        cameraRollCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - Scroll collection view at selected index
    func scrolledCollectionAtIndexPath() {
        cameraRollCollectionView.scrollToItem(at: IndexPath(row: scrollAtIndex, section: 0), at: .centeredVertically, animated: false)
    }
    // MARK: - end
    
    // MARK: - View customization
    //Load view when image is edited
    func loadVeiwImageEdited() {
        renameDatabaseDicData=[:]
        //Fetch all entries from local dataBase
        renameDatabaseDicData=AppDelegate().fetchRenameEntries().mutableCopy() as? NSMutableDictionary
        self.navigationItem.title="Gallery"
        let tempDeleteEntryArray:NSArray = renameDatabaseDicData!.allKeys as NSArray
        deletingDBEntries = tempDeleteEntryArray.mutableCopy() as! NSMutableArray
        viewInitialization()
    }
    
    func viewInitialization() {
        //Initialized variables
        searchBarBackView.isHidden=true
        cameraRollAssets = []
        searchedCameraRollAssets = []
        groupArray = []
        cameraRollCollectionView.reloadData()
        searchBarObject.text=""
        isSearch=false
        searchBarObject.translatesAutoresizingMaskIntoConstraints=true
        searchBarObject.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        photoAccessDeniedLabel.text=ConstantCode().allowNamePicString
        photoAccessDeniedLabel.isHidden=true;
        isSelectable = true
        //Add navigation bar buttons
        addBarButtons()
        //Customize right button according to image selection
        viewCustomization()
        //Remove all shared images from documentDirectory
        clearAllFilesFromTempDirectory()
        //Fetch group and then fetch image assets
        //Show indicator
        AppDelegate().showIndicator(uiView: self.view)
        self.perform( #selector(getAssest), with: nil, afterDelay: 0.01)
    }
    
    func viewCustomization() {
        //Remove all selected images whenever click at rightBarButton(select and cancel)
        selectUnselectImageArray.removeAllObjects()
        if isSelectable {
            isSelectable=false;
            leftButton?.isHidden=true
            rightButton?.setTitle(ConstantCode().selectString, for: UIControlState.normal)
            cameraRollCollectionView.reloadData()
        }
        else {
            isSelectable=true;
            rightButton?.setTitle(ConstantCode().cancelString, for: UIControlState.normal)
            cameraRollCollectionView.reloadData()
        }
    }
    
    func addBarButtons() {
        //Navigation right bar buttons
        var framing:CGRect=CGRect(x: 0, y: 0, width: 60, height: 30)
        rightButton=UIButton.init(frame: framing)
        rightButton?.isHidden=true
        rightButton?.setTitleColor(UIColor.white, for: UIControlState.normal)
        rightButton?.setTitle("", for: UIControlState.normal)
        rightButton?.titleLabel!.font =  UIFont().montserratLightWithSize(size: 17)
        rightButton?.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, -8.0)
        rightButton?.addTarget(self, action: #selector(rightBarButtonAction), for: UIControlEvents.touchUpInside)
        //Add rightBar button
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
    
    // Make a cell for each cell index path
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
            if (selectUnselectImageArray.contains(tempDictData as Any)) {
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
            var tempDictData:NSDictionary?
            if isSearch {
                tempDictData=searchedCameraRollAssets[indexPath.row] as? NSDictionary
            }
            else {
                tempDictData=cameraRollAssets[indexPath.row] as? NSDictionary
            }
            if (selectUnselectImageArray.contains(tempDictData as Any)) {
                selectUnselectImageArray.remove(tempDictData as Any)
                cell.selectUnselectImageView.image=UIImage()
            }
            else {
                selectUnselectImageArray.add(tempDictData as Any)
                cell.selectUnselectImageView.image=UIImage.init(named: "select")
            }
            //Manage enable and disable share button(Left bar button)
            if selectUnselectImageArray.count>0 {
                leftButton?.isHidden=false
            }
            else {
                leftButton?.isHidden=true
            }
        }
        else {
            //Remove observer when view is not present
            NotificationCenter.default.removeObserver(self)
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
            photoPreviewViewObj?.selectedPhotoName=imageName
            photoPreviewViewObj?.cameraRollAssets=(cameraRollAssets.mutableCopy() as! NSMutableArray)
            photoPreviewViewObj?.selectedDictData=tempDictData;
            photoPreviewViewObj?.selectedImageIndex=indexPath.row
            photoPreviewViewObj?.dashboardViewObject=self
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
                    //Stop indicator
                    AppDelegate().stopIndicator(uiView: self.view)
                    self.searchBarBackView.isHidden=true
                    self.rightButton?.isHidden=true;
                    self.photoAccessDeniedLabel.isHidden=false
                    self.photoAccessDeniedLabel.text=ConstantCode().noPicFoundString
                    self.cameraRollCollectionView.isHidden=true;
                }
            } else {
            }
        }
        let groupFailureBlock : ALAssetsLibraryAccessFailureBlock = {
            (err:Error!) in
            self.photoAccessDeniedLabel.isHidden=true;
            //Stop indicator
            AppDelegate().stopIndicator(uiView: self.view)
            let code = (err as NSError).code
            switch code {
            case ALAssetsLibraryAccessUserDeniedError, ALAssetsLibraryAccessGloballyDeniedError:
                self.rightButton?.isHidden=true;
                self.photoAccessDeniedLabel.text=ConstantCode().allowNamePicString
                self.photoAccessDeniedLabel.isHidden=false;
                if !(UserDefaultManager().getValue(key: "NameItPhotoAccessAlreadyCheck") is NSNull) {
                    //Exist
                    self.showPhotoAccessAlertMessage(title: ConstantCode().allowNamePicAlertTitleString, message: ConstantCode().allowNamePicString, cancel: ConstantCode().cancelString, ok: ConstantCode().allowString)
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
                if ((self.renameDatabaseDicData?.object(forKey: assetRepresent.filename().components(separatedBy: ".").first?.lowercased() as Any)) != nil) {
                    var tempString:String=self.renameDatabaseDicData!.object(forKey: assetRepresent.filename().components(separatedBy: ".").first?.lowercased() as Any) as! String
                    tempString.append(".\(assetRepresent.filename().components(separatedBy: ".").last!)")
                    self.cameraRollAssets.add(["FileName":tempString.lowercased(),
                                               "Asset":result])
                }
                else {
                    self.cameraRollAssets.add(["FileName":assetRepresent.filename().lowercased(),
                                               "Asset":result])
                }
                if self.deletingDBEntries.contains(assetRepresent.filename().components(separatedBy: ".").first!.lowercased()) {
                    self.deletingDBEntries.remove(assetRepresent.filename().components(separatedBy: ".").first!.lowercased())
                }
            }
        }
        
        let onlyPhotosFilter:ALAssetsFilter=ALAssetsFilter.allPhotos()
        self.assetsGroup?.setAssetsFilter(onlyPhotosFilter)
        self.assetsGroup?.enumerateAssets(options: .reverse, using: assetsEnumerationBlock)
        //Stop indicator
        AppDelegate().stopIndicator(uiView: self.view)
        if self.cameraRollAssets.count>0 {
            if self.deletingDBEntries.count > 0 {
                deleteEntry()
            }
            searchBarBackView.isHidden=false
            rightButton?.isHidden=false;
            photoAccessDeniedLabel.text=ConstantCode().allowNamePicString
            cameraRollCollectionView.isHidden=false;
        }
        else {
            searchBarBackView.isHidden=true
            rightButton?.isHidden=true;
            self.photoAccessDeniedLabel.isHidden=false
            photoAccessDeniedLabel.text=ConstantCode().noPicFoundString
            cameraRollCollectionView.isHidden=true;
        }
        self.cameraRollCollectionView.reloadData()
        cameraRollCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func deleteEntry() {
        DispatchQueue.global(qos: .background).async {
            // Background Thread
            if self.deletingDBEntries.count > 0 {
                if AppDelegate().deleteEntries(imageName: self.deletingDBEntries.object(at: 0) as! String) {
                    self.renameDatabaseDicData?.removeObject(forKey: self.deletingDBEntries.object(at: 0))
                    self.deletingDBEntries.removeObject(at: 0)
                }
            }
            DispatchQueue.main.async {
                // Run UI Updates
                if self.deletingDBEntries.count > 0 {
                    self.deleteEntry()
                }
            }
        }
    }
    // MARK: - end
    
    // MARK: - IBAction
    @IBAction func editSelectedPhotoName(_ sender: UIButton) {
        editImageNameRecursiveMethod(seletedImageTag: sender.tag)
    }
    
    func rightBarButtonAction() {
        searchBarObject.resignFirstResponder()
        viewCustomization()
    }
    
    func leftBarButtonAction() {
        searchBarObject.resignFirstResponder()
        //Remove all shared images from documentDirectory
        clearAllFilesFromTempDirectory()
        var selectedImageArrayToShare:Array<NSURL> = [NSURL]()
        //Add selected image
        for tempDictData in selectUnselectImageArray {
            let tempString:String = (tempDictData as AnyObject).object(forKey: "FileName") as! String
            //Save selected images in documentDirectory and fetch image path then append this image path in selectedImageArrayToShare
            selectedImageArrayToShare.append(saveActivityControllerImage(tempAsset: (tempDictData as AnyObject).object(forKey: "Asset") as! ALAsset, fileName: tempString.capitalized))
        }
        //Present UIActivityViewController to share images
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: selectedImageArrayToShare as [Any], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func searchCancel(_ sender: UIButton) {
        isSearch=false
        searchBarObject.text=""
        photoAccessDeniedLabel.isHidden=true
        searchedCameraRollAssets.removeAllObjects()
        searchBarObject.resignFirstResponder()
        cameraRollCollectionView.reloadData()
        unEditedSearchBarAnimation()
    }
    // MARK: - end
    
    // MARK: - Save selected image in DocumentDirectory and return path of images
    func saveActivityControllerImage(tempAsset:ALAsset, fileName imageName:String) -> NSURL {
        let tempAssetRepresent:ALAssetRepresentation=tempAsset.defaultRepresentation()
        let tempFullImage:UIImage=UIImage.init(cgImage: tempAssetRepresent.fullScreenImage().takeUnretainedValue())
        var name:String=imageName.capitalized
        print(name.components(separatedBy: ".").last as Any)
        if name.components(separatedBy: ".").last!.lowercased() != "png" {
            name = name.replacingOccurrences(of: ".\(name.components(separatedBy: ".").last!)", with: ".jpg")
        }
        else {
            name = name.replacingOccurrences(of: ".\(name.components(separatedBy: ".").last!)", with: ".png")
        }
        let urlString : NSURL = getDocumentDirectoryPath(fileName: name)
        print("Image path : \(urlString)")
        if !FileManager.default.fileExists(atPath: urlString.absoluteString!) {
            do {
                var isSaved : Bool = false
                print(urlString.pathExtension as Any)
                if urlString.pathExtension?.lowercased() == "png" {
                    isSaved = ((try  UIImagePNGRepresentation(tempFullImage)?.write(to: urlString as URL, options: Data.WritingOptions.atomic)) != nil)
                }
                else {
                    isSaved = ((try  UIImageJPEGRepresentation(tempFullImage, 1.0)?.write(to: urlString as URL, options: Data.WritingOptions.atomic)) != nil)
                }
                if (isSaved) {
                    return urlString
                    
                } else {
                    return NSURL.fileURL(withPath: "Blank") as NSURL
                }
            } catch {
                return NSURL.fileURL(withPath: "Blank") as NSURL
            }
        }
        return urlString
    }
    // MARK: - end
    
    // MARK: - UISearchBar delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        editedSearchBarAnimation()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
    
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
            if searchedCameraRollAssets.count > 0 {
                photoAccessDeniedLabel.isHidden=true
            }
            else {
                photoAccessDeniedLabel.isHidden=false
                photoAccessDeniedLabel.text=ConstantCode().noSearchPicFoundString
            }
            cameraRollCollectionView.reloadData()
        }
    }
    // MARK: - end
    
    // MARK: - UISearchbar animations
    func unEditedSearchBarAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.searchBarObject.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44)
        }) { (success) in
        }
    }
    
    func editedSearchBarAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBarObject.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width-70, height: 44)
        }) { (success) in
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
        let alert = UIAlertController(title: "", message: ConstantCode().renameAlertString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ConstantCode().cancelString, style: .cancel, handler: nil))
        let saveAction = UIAlertAction(title:ConstantCode().saveString, style: .default, handler: { (action) -> Void in
            if let alertTextField = alert.textFields?.first, alertTextField.text != nil {
                if alertTextField.text?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != fileName
                    .components(separatedBy: ".").first!.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                    var tempString:String=(alertTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    tempString = tempString + "." + fileName.components(separatedBy: ".").last!
                    //Check for dot '.' character
                    let charset = CharacterSet(charactersIn: "./")
                    if alertTextField.text?.rangeOfCharacter(from: charset) != nil {
                        alert.dismiss(animated: false, completion: nil)
                        self.showImageNameAlreadyExistAlert(title: ConstantCode().alertString, message: ConstantCode().notAllowedCharString, tempString: alertTextField.text!, seletedImageTag: seletedImageTag)
                    }
                    //Check entered name is already exist or not
                    else if !self.isImageNameAlreadyExist(searchText: tempString) {
                        self.editFilenameHandlingLocalAndDB(seletedImageTag: seletedImageTag, updatedText: alertTextField.text!, updtedTextWithExtension: tempString, selectedDictData: tempDictData!)
                        self.cameraRollCollectionView.reloadData()
                    }
                    else {
                        alert.dismiss(animated: false, completion: nil)
                        self.showImageNameAlreadyExistAlert(title: ConstantCode().alertString, message: ConstantCode().imgAlreadyString, tempString: alertTextField.text!, seletedImageTag: seletedImageTag)
                    }
                }
            }
        })
        alert.addAction(saveAction)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter image name"
            textField.keyboardType=UIKeyboardType.default
            textField.autocapitalizationType=UITextAutocapitalizationType.words
            textField.autocorrectionType=UITextAutocorrectionType.no
            if self.lastEnteredUpdatedImageName == "" {
                textField.text=fileName
                    .components(separatedBy: ".").first?.capitalized
            }
            else {
                textField.text=self.lastEnteredUpdatedImageName
            }
            self.lastEnteredUpdatedImageName=""
            textField.delegate=self
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                saveAction.isEnabled = (textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count)! > 0
            }
        })
        present(alert, animated: true, completion: nil)
    }
    
    func editFilenameHandlingLocalAndDB(seletedImageTag:Int, updatedText:String, updtedTextWithExtension:String, selectedDictData:NSDictionary) {
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
            .components(separatedBy: ".").first!.lowercased(), rename: (updatedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()))
        self.renameDatabaseDicData?.setValue((updatedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()), forKey: assetRepresent.filename().components(separatedBy: ".").first!.lowercased())
        let tempDeleteEntryArray:NSArray = renameDatabaseDicData!.allKeys as NSArray
        deletingDBEntries = tempDeleteEntryArray.mutableCopy() as! NSMutableArray
        //Update edit file name in cameraRollAssets and searchedCameraRollAssets
        let index:Int=self.cameraRollAssets.index(of: selectedDictData as Any)
        let tempDictData:NSDictionary=self.cameraRollAssets.object(at: index) as! NSDictionary
        let tempMutableData:NSMutableDictionary=tempDictData.mutableCopy() as! NSMutableDictionary
        tempMutableData.setValue(updtedTextWithExtension.lowercased(), forKey: "FileName")
        self.cameraRollAssets.replaceObject(at: index, with: tempMutableData)
        if self.isSearch {
            self.searchedCameraRollAssets.replaceObject(at: seletedImageTag, with: tempMutableData)
        }
    }
    
    func isImageNameAlreadyExist(searchText:String) -> Bool {
        let tempString=searchText.components(separatedBy: ".").first! + "."
        let photoNamePredicate = NSPredicate(format: "FileName BEGINSWITH %@", tempString.lowercased())
        let tempFilteredArray:NSMutableArray=cameraRollAssets.filtered(using: photoNamePredicate) as! NSMutableArray
        if tempFilteredArray.count > 0 {
            return true
        }
        return false
    }
    // MARK: - end
    
    //Textfield delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        let okAction = UIAlertAction(title: ConstantCode().okString, style: .default) { (action) -> Void in
            self.lastEnteredUpdatedImageName=tempString
            alertViewController.dismiss(animated: false, completion: nil)
            self.editImageNameRecursiveMethod(seletedImageTag: seletedImageTag)
        }
        alertViewController.addAction(okAction)
        self.navigationController?.present(alertViewController, animated: false, completion: nil)
    }
    // MARK: - end
    
    // MARK: - DocumentDirectory handling
    //Create NameIt folder
    func createImagesFolder() {
        //Path to documents directoryRanosys
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            let imagesDirectoryPath = documentDirectoryPath.appending("/NameIt")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: imagesDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: imagesDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("Error creating images folder in documents dir: \(error)")
                }
            }
        }
    }
    
    //Clear all image from NameIt folder before adding new images
    func clearAllFilesFromTempDirectory(){
        let fileManager = FileManager.default
        let documentsUrl =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsPath:NSString = documentsUrl.object(at: 0) as! NSString
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentsPath.appending("/NameIt"))")
            print("all files in cache: \(fileNames)")
            for fileName in fileNames {
                let filePathName = "\(documentsPath.appending("/NameIt"))/\(fileName)"
                try fileManager.removeItem(atPath: filePathName)
            }
            let files = try fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
            print("all files in cache after deleting images: \(files)")
        }
        catch {
        }
    }
    
    //Get documentDirectory path
    func getDocumentDirectoryPath(fileName:String) -> NSURL {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuementDir:NSString = paths.object(at: 0) as! NSString
        return NSURL.fileURL(withPath: docuementDir.appendingPathComponent("NameIt/\(fileName)")) as NSURL
    }
    // MARK: - end

    // MARK: - Notification observer method
    func applicationWillEnterForeground(_ notification: NSNotification) {
        let tempDeleteEntryArray:NSArray = renameDatabaseDicData!.allKeys as NSArray
        deletingDBEntries = tempDeleteEntryArray.mutableCopy() as! NSMutableArray
        //View initialized method called
        viewInitialization()
    }
    // MARK: - end
}

