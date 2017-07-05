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
        photoAccessDeniedLabel.isHidden=true;
        //Fetch group and then fetch image assets
        getAssest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    //MARK: - CollectionView Delegate, Datasource and DelegateFlowLayout
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cameraRollAssets.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell:PhotoGridCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as? PhotoGridCollectionViewCell
//        cell?.layer.shouldRasterize = true;
//        cell?.layer.rasterizationScale = UIScreen.main.scale;
        
        // Load the asset for this cell
        let asset:ALAsset=cameraRollAssets[indexPath.row] as! ALAsset
        let assetRepresent:ALAssetRepresentation=asset.defaultRepresentation()
        let thumbnailImageRef:CGImage=asset.aspectRatioThumbnail().takeUnretainedValue()
        let thumbnail:UIImage=UIImage.init(cgImage: thumbnailImageRef)
        cell?.cameraRollImageView.image=thumbnail
        print(assetRepresent.filename())
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Navigate to photoGrid screen
        let photoPreviewViewObj = self.storyboard?.instantiateViewController(withIdentifier: "PtotoPreviewViewController") as? PtotoPreviewViewController
        photoPreviewViewObj?.cameraRollAssets=cameraRollAssets.mutableCopy() as! NSMutableArray
        photoPreviewViewObj?.selectedPhotoAsset=cameraRollAssets[indexPath.row] as? ALAsset
        photoPreviewViewObj?.selectedImageIndex=indexPath.row
        
        self.navigationController?.pushViewController(photoPreviewViewObj!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 3.0
        return CGSize(width: picDimension-5, height: picDimension+28)
    }
    // MARK: - end
    
    //MARK: - Fetch ALAssetLibrary camera roll group and image assets
    func getAssest() {
        
        let groupBlock : ALAssetsLibraryGroupsEnumerationResultsBlock = {
            
            (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>!) in
            
            let onlyPhotosFilter:ALAssetsFilter?=ALAssetsFilter.allPhotos()
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
            print(err.localizedDescription)
            self.photoAccessDeniedLabel.isHidden=true;
            let code = (err as NSError).code
            switch code {
            case ALAssetsLibraryAccessUserDeniedError, ALAssetsLibraryAccessGloballyDeniedError:
                self.photoAccessDeniedLabel.isHidden=false;
                self.showPhotoAccessAlertMessage(title: "\"NameIt\" Would Like ot Access Your Photos", message: "You must allow photos access in Settings.", cancel: "Cancel", ok: "Allow")
                
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
        print(self.cameraRollAssets.count)
        if self.cameraRollAssets.count>0 {
            
             cameraRollCollectionView.isHidden=false;
        }
        else {
        
             cameraRollCollectionView.isHidden=true;
        }
        self.cameraRollCollectionView.reloadData()
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

