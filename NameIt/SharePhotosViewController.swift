//
//  SharePhotosViewController.swift
//  NameIt
//
//  Created by Ranosys on 05/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class SharePhotosViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var sharePhotoCollectionView: UICollectionView!
    var cameraRollAssets: NSMutableArray = []
    let imageToShare: NSMutableArray = []
    
    var selectedImageIndex:Int=0
    var selectUnselectImageArray:NSMutableArray = []
    var activityViewController : UIActivityViewController?
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title="Photos"
        self.navigationItem.hidesBackButton=true
        selectUnselectImageArray.add(selectedImageIndex)
        sharePhotoCollectionView.reloadData()
        
        // Load the asset for this cell
        let asset:ALAsset=cameraRollAssets[selectedImageIndex] as! ALAsset
        //        let assetRepresent:ALAssetRepresentation=asset.defaultRepresentation()
        let thumbnailImageRef:CGImage=asset.aspectRatioThumbnail().takeUnretainedValue()
        let thumbnail:UIImage=UIImage.init(cgImage: thumbnailImageRef)
//        cell?.cameraRollImageView.image=thumbnail
        
//        let image = UIImage(named: "Image")
        
        // set up activity view controller
        imageToShare.add(thumbnail)
       
        activityViewController = UIActivityViewController(activityItems: imageToShare as! [Any], applicationActivities: nil)
//        activityViewController?.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
//        activityViewController?.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController!, animated: true, completion: nil)
//        self.pres
//        [self addChildViewController: newViewController];
//        [self.view addSubview: newViewController.view];
//        self.addChildViewController(activityViewController!)
//        self.view.addSubview((activityViewController?.view)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - CollectionView Delegate, Datasource and DelegateFlowLayout
    // Tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cameraRollAssets.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell:SharePhotoGridCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as? SharePhotoGridCollectionViewCell
        //        cell?.layer.shouldRasterize = true;
        //        cell?.layer.rasterizationScale = UIScreen.main.scale;
        
        // Load the asset for this cell
        let asset:ALAsset=cameraRollAssets[indexPath.row] as! ALAsset
//        let assetRepresent:ALAssetRepresentation=asset.defaultRepresentation()
        let thumbnailImageRef:CGImage=asset.aspectRatioThumbnail().takeUnretainedValue()
        let thumbnail:UIImage=UIImage.init(cgImage: thumbnailImageRef)
        cell?.cameraRollImageView.image=thumbnail
//        print(assetRepresent.filename())
        
        if (selectUnselectImageArray.contains(indexPath.row)) {
            
            cell?.checkUncheckImageView.image=UIImage.init(named: "check")
        }
        else {
            
            cell?.checkUncheckImageView.image=UIImage.init(named: "uncheck")
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SharePhotoGridCollectionViewCell
        
        if (selectUnselectImageArray.contains(indexPath.row)) {
            
            selectUnselectImageArray.remove(indexPath.row)
            cell.checkUncheckImageView.image=UIImage.init(named: "uncheck")
        }
        else {
            
            selectUnselectImageArray.add(indexPath.row)
            cell.checkUncheckImageView.image=UIImage.init(named: "check")
            // Load the asset for this cell
            let asset:ALAsset=cameraRollAssets[selectedImageIndex] as! ALAsset
            //        let assetRepresent:ALAssetRepresentation=asset.defaultRepresentation()
            let thumbnailImageRef:CGImage=asset.aspectRatioThumbnail().takeUnretainedValue()
            let thumbnail:UIImage=UIImage.init(cgImage: thumbnailImageRef)
            //        cell?.cameraRollImageView.image=thumbnail
            
            //        let image = UIImage(named: "Image")
            
            // set up activity view controller
            imageToShare.add(thumbnail)
            
            activityViewController = UIActivityViewController(activityItems: imageToShare as! [Any], applicationActivities: nil)
        }
    }

    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let picDimension = self.view.frame.size.width / 3.0
//        return CGSize(width: picDimension-5, height: picDimension+28)
//    }
    // MARK: - end
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
