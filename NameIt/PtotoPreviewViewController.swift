//
//  PtotoPreviewViewController.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class PtotoPreviewViewController: GlobalBackViewController, UIScrollViewDelegate {
    
    @IBOutlet var airbrushButton: UIButton!
    @IBOutlet var addTextButton: UIButton!
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var photoPreviewImageView: UIImageView!
    @IBOutlet var scrollViewObject: UIScrollView!
    
    var selectedPhotoAsset:ALAsset?
    var selectedPhoto:UIImage?
    
    var degree:Int=0
    
    var selectedImageSize:CGSize?
    var isRotateSelected:Bool = false
    var isAddTextSelected:Bool = false
    var isImageEdited:Bool = false
    
//    var beforeEditImage:UIImage?
//    var afterEditImage:UIImage?
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewIntialization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - UIView initialized
    func viewIntialization() {
        
        self.scrollViewObject.maximumZoomScale = 3.0
        self.scrollViewObject.minimumZoomScale = 1.0

        //Load full image and image name from selectedImageAsset
        let assetRepresent:ALAssetRepresentation=selectedPhotoAsset!.defaultRepresentation()
        let fullImageRef:CGImage=assetRepresent.fullScreenImage().takeUnretainedValue()
        let fullImage:UIImage=UIImage.init(cgImage: fullImageRef)
        selectedPhoto=fullImage
//        beforeEditImage=fullImage
        
        //Set navigation title
        self.navigationItem.title=assetRepresent.filename().components(separatedBy: ".").first?.capitalized
        selectedImageSize = selectedPhoto?.size
        photoPreviewImageView.image=selectedPhoto
        
        //Change photoPreviewImageView according to selected image size ratio
        changeImageRatio()
    }
    
    // MARK: - Image scalling
    //Set UIImageView size according to image size ratio
    func changeImageRatio() {
        
        let ratio = (selectedImageSize?.width)!/(selectedImageSize?.height)!
        let selectedImageWidth:CGFloat=(selectedImageSize?.width)!
        let selectedImageHeight:CGFloat=(selectedImageSize?.height)!
        var selectedImageX:CGFloat = 0.0
        var selectedImageY:CGFloat = 0.0
        if ratio>1 {
            
            selectedImageSize?.width=self.view.bounds.size.width
            selectedImageSize?.height = (selectedImageHeight/selectedImageWidth) * (selectedImageSize?.width)!
            selectedImageY = CGFloat(((UIScreen.main.bounds.size.height-(64.0+44.0))/2.0) - ((selectedImageSize?.height)!/2.0))
        }
        else if ratio==1 {
            
            selectedImageSize?.width=self.view.bounds.size.width
            selectedImageSize?.height=self.view.bounds.size.width
            selectedImageY = CGFloat(((UIScreen.main.bounds.size.height-(64.0+44.0))/2.0) - ((selectedImageSize?.height)!/2.0))
        }
        else {
            
            selectedImageSize?.height=UIScreen.main.bounds.size.height-(64+44)
            selectedImageSize?.width = (selectedImageWidth/selectedImageHeight) * (selectedImageSize?.height)!
            selectedImageX = CGFloat((UIScreen.main.bounds.size.width/2.0) - ((selectedImageSize?.width)!/2.0))
        }
        
        print(selectedImageSize!)
        photoPreviewImageView.translatesAutoresizingMaskIntoConstraints=true;
        photoPreviewImageView.frame=CGRect(x: selectedImageX, y: selectedImageY, width: (selectedImageSize?.width)!, height: (selectedImageSize?.height)!)
        self.scrollViewObject.contentSize=CGSize(width: photoPreviewImageView.frame.size.width, height: photoPreviewImageView.frame.size.height)
    }
    
    //ScrollView delegates
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoPreviewImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        centerScrollViewContents()
    }
    
    //After zoom in/out set image origin
    func  centerScrollViewContents() {
        
        let boundsSize:CGSize = self.scrollViewObject.bounds.size
        var contentsFrame:CGRect = self.photoPreviewImageView.frame
        if contentsFrame.size.width < boundsSize.width {
            
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        }
        else {
            contentsFrame.origin.x = 0.0;
        }
        
        if contentsFrame.size.height < boundsSize.height {
            
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        }
        else {
            contentsFrame.origin.y = 0.0
        }
        
        self.photoPreviewImageView.frame = contentsFrame;
    }
    // MARK: - end
    
    // MARK: - IBActions
    @IBAction func rotateImage(_ sender: UIButton) {
        
        if !isRotateSelected {
            
            isRotateSelected=true
            shareButton.isEnabled=false;
            airbrushButton.isEnabled=false;
            addTextButton.isEnabled=false;
            addBarButtonWithDone()
        }
        else {
            
            photoPreviewImageView.image = rotateImage(image:  photoPreviewImageView.image!, rotationDegree: 90)
            self.scrollViewObject.zoomScale=1.0
            selectedImageSize=photoPreviewImageView.image?.size
            changeImageRatio()
        }
    }
    
    @IBAction func shareImage(_ sender: UIButton) {
        
//        var selectedImageArrayToShare:Array<NSData> = [NSData]()
        var selectedImageArrayToShare:Array<UIImage> = [UIImage]()
        
        //NSData *compressedImage = UIImageJPEGRepresentation(self.resultImage, 0.8 );
        //            let cI:NSData=UIImageJPEGRepresentation(tempFullImage, 0.8)! as NSData
//        let cI:NSData=UIImagePNGRepresentation(tempFullImage)! as NSData
//        selectedImageArrayToShare.append(cI)
        selectedImageArrayToShare.append(photoPreviewImageView.image!)
        
        //Present UIActivityViewController to share images
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: selectedImageArrayToShare as [Any], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func addTextlabel(_ sender: UIButton) {
        
        if !isAddTextSelected {
            
            isAddTextSelected=true
            shareButton.isEnabled=false;
            airbrushButton.isEnabled=false;
            rotateButton.isEnabled=false;
            addBarButtonWithDone()
        }
        else {
            
//            photoPreviewImageView.image = rotateImage(image:  photoPreviewImageView.image!, rotationDegree: 90)
//            self.scrollViewObject.zoomScale=1.0
//            selectedImageSize=photoPreviewImageView.image?.size
//            changeImageRatio()
        }
    }
    
    @IBAction func addAirbrush(_ sender: UIButton) {
        
    }
    
    override func saveButtonAction() {
    
        if (isImageEdited) {
        
            //Adds the edited image to the user’s Camera Roll album
            UIImageWriteToSavedPhotosAlbum(photoPreviewImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func cancelButtonAction() {
    
        selectedImageSize = selectedPhoto?.size
        photoPreviewImageView.image=selectedPhoto
        
        //Common Method for cancel and done action
        commonMethodOfCancelDoneAction()
    }
    
    override func doneButtonAction() {
    
        isImageEdited=true
        selectedPhoto=photoPreviewImageView.image
        selectedImageSize = selectedPhoto?.size
        
        //Common Method for cancel and done action
        commonMethodOfCancelDoneAction()
    }
    // MARK: - end
    
    // MARK: - Image rotate at given degrees
    func rotateImage(image: UIImage!, rotationDegree: CGFloat) -> UIImage {
        
        // 180 degress = 540 degrees, that's why we calculate modulo
        var rotationDegree = rotationDegree
        rotationDegree = rotationDegree.truncatingRemainder(dividingBy: 360)
        
        // If degree is negative, then calculate positive
        if rotationDegree < 0.0 {
            rotationDegree = 360 + rotationDegree
        }
        
        // Get image size
        let size = image.size
        let width = size.width
        let height = size.height
        
        // Get degree which we will use for calculation
        var calcDegree = rotationDegree
        if calcDegree > 90 {
            calcDegree = 90 - calcDegree.truncatingRemainder(dividingBy: 90)
        }
        
        // Calculate new size
        let newWidth = width * CGFloat(cosf(Float(calcDegree * CGFloat(Double.pi / 180)))) + height * CGFloat(sinf(Float(calcDegree * CGFloat(Double.pi / 180))))
        let newHeight = width * CGFloat(sinf(Float(calcDegree * CGFloat(Double.pi / 180)))) + height * CGFloat(cosf(Float(calcDegree * CGFloat(Double.pi / 180))))
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        // Create context using new size, make it opaque, use screen scale
        UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.main.scale)
        
        // Get context variable
        let context = UIGraphicsGetCurrentContext()
        
        // Set fill color to white (or any other)
        // If no color needed, then set opaque to false when initialize context
        context!.setFillColor(UIColor.white.cgColor)
        context!.fill(CGRect(origin: .zero, size: newSize))
        
        // Rotate context and draw image
        context!.translateBy(x: newSize.width * 0.5, y: newSize.height * 0.5)
        context!.rotate(by: rotationDegree * CGFloat(Double.pi / 180));
        context!.translateBy(x: newSize.width * -0.5, y: newSize.height * -0.5)
        image.draw(at: CGPoint(x: (newSize.width - size.width) / 2.0, y: (newSize.height - size.height) / 2.0))
        
        // Get image from context
        let returnImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End graphics context
        UIGraphicsEndImageContext()
        
        return returnImage!
    }
    // MARK: - end
    
    // MARK: - Common Method for cancel and done action
    func commonMethodOfCancelDoneAction() {
        
        //Change photoPreviewImageView according to selected image size ratio
        changeImageRatio()
        
        isRotateSelected=false;
        isAddTextSelected=false;
        shareButton.isEnabled=true;
        airbrushButton.isEnabled=true;
        rotateButton.isEnabled=true;
        addTextButton.isEnabled=true;
        
        //Show back bar button and show save button if image is edited
        addBackBarButton()
        if isImageEdited {
            addSaveBarButton()
        }
    }
    // MARK: - end
    
    // MARK: - UIImagePickerController delegate
    //Selector should be called after the image has been written to the Camera Roll album
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error != nil {
            //We got back an error!
            let alertViewController = UIAlertController(title: "Alert", message: "Your altered image has not been saved to your photos.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                
            }
            alertViewController.addAction(okAction)
            
            present(alertViewController, animated: true, completion: nil)
        } else {
            
            let alertViewController = UIAlertController(title: "Alert", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                
                self.navigationController?.popViewController(animated: true)
            }
            alertViewController.addAction(okAction)
            
            present(alertViewController, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
