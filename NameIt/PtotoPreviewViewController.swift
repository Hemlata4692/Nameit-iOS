//
//  PtotoPreviewViewController.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class PtotoPreviewViewController: GlobalBackViewController, UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var airbrushButton: UIButton!
    @IBOutlet var addTextButton: UIButton!
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var activityControllerObject: UIActivityIndicatorView!
    
    @IBOutlet var photoBackView: UIView!
    @IBOutlet var photoPreviewImageView: UIImageView!
    @IBOutlet var scrollViewObject: UIScrollView!
    
    var selectedPhotoAsset:ALAsset?
    var selectedPhotoName:String?
    var selectedPhoto:UIImage?
    
    var degree:Int=0
    
    var selectedImageSize:CGSize?
    var isRotateSelected:Bool = false
    var isAddTextSelected:Bool = false
    var isImageEdited:Bool = false
    
    var caption:UITextView?
    var textViewToolbar:UIToolbar?
    var drag:UIPanGestureRecognizer?
    
    var isAirBrushDone:Bool=false
    
    //Select add textLabel color
    @IBOutlet var selectTextColorBackView: UIView!
    @IBOutlet var whiteColorButton: UIButton!
    @IBOutlet var blackColorButton: UIButton!
    var selectedColor:UIColor?
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewIntialization()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        activityControllerObject.isHidden=true;
        
        if isAirBrushDone {
            
            //Change after done action of airbrush
            selectedImageSize = selectedPhoto?.size
            photoPreviewImageView.image=selectedPhoto
            photoPreviewImageView.isUserInteractionEnabled=true
            
            //Change photoPreviewImageView according to selected image size ratio
            changeImageRatio()

            isImageEdited=true
            addSaveBarButton()
        }
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

        //Set gesture variable
        drag=UIPanGestureRecognizer.init(target: self, action: #selector(captionDrag(gestureRecognizer:)))
        drag?.delegate=self
        
        //Load full image and image name from selectedImageAsset
        let assetRepresent:ALAssetRepresentation=selectedPhotoAsset!.defaultRepresentation()
        let fullImageRef:CGImage=assetRepresent.fullScreenImage().takeUnretainedValue()
        let fullImage:UIImage=UIImage.init(cgImage: fullImageRef)
        selectedPhoto=fullImage
        
        //Set navigation title
        self.navigationItem.title=selectedPhotoName
        selectedImageSize = selectedPhoto?.size
        photoPreviewImageView.image=selectedPhoto
        photoPreviewImageView.isUserInteractionEnabled=true
        
        selectTextColorBackView.isHidden=true
//        whiteColorButton.layer.cornerRadius=13
//        whiteColorButton.layer.masksToBounds=true
//        blackColorButton.layer.cornerRadius=13
//        blackColorButton.layer.masksToBounds=true
//        whiteColorButton.layer.borderColor=UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0).cgColor
//        whiteColorButton.layer.borderWidth=2.0
        selectedColor=UIColor.black
        //Change photoPreviewImageView according to selected image size ratio
        changeImageRatio()
    }
    
    // MARK: - Image scalling
    //Set UIImageView size according to image size ratio
    func changeImageRatio() {
        
//        print(scrollViewObject.zoomScale)
        let ratio = (selectedImageSize?.width)!/(selectedImageSize?.height)!
        let selectedImageWidth:CGFloat=(selectedImageSize?.width)!
        let selectedImageHeight:CGFloat=(selectedImageSize?.height)!
        var selectedImageX:CGFloat = 0.0
        var selectedImageY:CGFloat = 0.0
        if ratio>1 {
            
            selectedImageSize?.width=self.view.bounds.size.width
            selectedImageSize?.height = (selectedImageHeight/selectedImageWidth) * (selectedImageSize?.width)!
            selectedImageY = CGFloat(((UIScreen.main.bounds.size.height-128.0)/2.0) - ((selectedImageSize?.height)!/2.0))
        }
        else if ratio==1 {
            
            selectedImageSize?.width=self.view.bounds.size.width
            selectedImageSize?.height=self.view.bounds.size.width
            selectedImageY = CGFloat(((UIScreen.main.bounds.size.height-128.0)/2.0) - ((selectedImageSize?.height)!/2.0))
        }
        else {
            
            selectedImageSize?.height=UIScreen.main.bounds.size.height-(64+64)
            selectedImageSize?.width = (selectedImageWidth/selectedImageHeight) * (selectedImageSize?.height)!
            selectedImageX = CGFloat((UIScreen.main.bounds.size.width/2.0) - ((selectedImageSize?.width)!/2.0))
        }
        
        photoPreviewImageView.translatesAutoresizingMaskIntoConstraints=true;
        photoPreviewImageView.frame=CGRect(x: selectedImageX, y: selectedImageY, width: (selectedImageSize?.width)!, height: (selectedImageSize?.height)!)
        self.scrollViewObject.contentSize=CGSize(width: 0, height: 0)
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
        
        if scrollViewObject.zoomScale==1.0 {
             self.scrollViewObject.contentSize=CGSize(width: 0, height: 0)
        }
    }
    // MARK: - end
    
    // MARK: - IBActions
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
    
    @IBAction func rotateImage(_ sender: UIButton) {
        
        if !isRotateSelected {
            
            isRotateSelected=true
            addTextButton.isEnabled=false;
            commonMethodOfRotateAddTextAction()
            changeImageRatio()
        }
        else {
            
            photoPreviewImageView.image = rotateImage(image:  photoPreviewImageView.image!, rotationDegree: 90)
            self.scrollViewObject.zoomScale=1.0
            selectedImageSize=photoPreviewImageView.image?.size
            changeImageRatio()
        }
    }
    
    @IBAction func addTextlabel(_ sender: UIButton) {
        
        if !isAddTextSelected {
            
            selectedColor=UIColor.black
            isAddTextSelected=true
            rotateButton.isEnabled=false;
            commonMethodOfRotateAddTextAction()
            photoPreviewImageView.translatesAutoresizingMaskIntoConstraints=true;
            photoPreviewImageView.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-(64.0+64.0))
            
            //            photoPreviewImageView.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-128)  //height=navigationBar_Height(64)+bottom_space(64)
            //            photoPreviewImageView.addGestureRecognizer(drag!)
            initCaption()
        }
        else {
            
            //            if ((caption?.sizeThatFits((caption?.frame.size)!).height)! > CGFloat(36.0)) {
            //
            //                caption?.frame = CGRect(x: 0, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2), width: UIScreen.main.bounds.size.width, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
            //            }
            //            else {
            //
            //                caption?.frame = CGRect(x: 0, y: (photoPreviewImageView.frame.size.height/2) - 15, width: UIScreen.main.bounds.size.width, height: 34)
            //            }
            caption?.becomeFirstResponder()
        }
    }
    
    @IBAction func addAirbrush(_ sender: UIButton) {
        
        isAirBrushDone=false
        //Navigate to photoGrid screen in edit mode
        let airBrushViewObj = self.storyboard?.instantiateViewController(withIdentifier: "AirBrushViewController") as? AirBrushViewController
        airBrushViewObj?.selectedPhoto=selectedPhoto
        airBrushViewObj?.screenTitle=self.navigationItem.title! as NSString
        airBrushViewObj?.photoPreviewObj=self
        self.navigationController?.pushViewController(airBrushViewObj!, animated: false)
    }
    
    override func saveButtonAction() {
    
        if (isImageEdited) {
        
            scrollViewObject.zoomScale=1.0
            //Show indicator
//            activityControllerObject.isHidden=false;
            AppDelegate().showIndicator(uiView: self.view)
            self.perform( #selector(saveEditedImage), with: nil, afterDelay: 0.01)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func cancelButtonAction() {
    
        selectedImageSize = selectedPhoto?.size
        photoPreviewImageView.image=selectedPhoto
//        selectTextColorBackView.isHidden=true
        if isAddTextSelected {
            
            caption?.removeGestureRecognizer(drag!)
            caption?.resignFirstResponder()
            caption?.removeFromSuperview()
            textViewToolbar?.removeFromSuperview()
            textViewToolbar=nil
            caption=nil
        }
        
        //Common method for cancel and done action
        commonMethodOfCancelDoneAction()
    }
    
    override func doneButtonAction() {
    
//         selectTextColorBackView.isHidden=true
        isImageEdited=true
        selectedPhoto=photoPreviewImageView.image
        selectedImageSize = selectedPhoto?.size
        
        if isAddTextSelected {
            
            caption?.layer.borderWidth=0.0
            caption?.removeGestureRecognizer(drag!)
            caption?.resignFirstResponder()
            if caption?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count != 0 {
            
                //Add text at selected image
                setCustomTextAtSelectedImage()
                selectedPhoto=photoPreviewImageView.image
                selectedImageSize = selectedPhoto?.size
            }
            caption?.removeFromSuperview()
            textViewToolbar?.removeFromSuperview()
            textViewToolbar=nil
            caption=nil
        }
        
        //Common method for cancel and done action
        commonMethodOfCancelDoneAction()
    }

    @IBAction func resignKeyboardWithTapGesture(_ sender: UITapGestureRecognizer) {
        
        if caption != nil {
            
            caption?.layer.borderWidth=0.0
            caption?.resignFirstResponder()
        }
    }
    
    @IBAction func selectBlackColor(_ sender: UIButton) {
        
        whiteColorButton.layer.borderColor=UIColor.clear.cgColor
        whiteColorButton.layer.borderWidth=0.0
        blackColorButton.layer.borderColor=UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0).cgColor
        blackColorButton.layer.borderWidth=2.0
        selectedColor=UIColor.black
        if caption != nil {
            
            caption?.textColor=selectedColor
            caption?.layer.borderColor=selectedColor?.cgColor
        }
    }
    
    @IBAction func selectWhiteColor(_ sender: UIButton) {
        
        blackColorButton.layer.borderColor=UIColor.clear.cgColor
        blackColorButton.layer.borderWidth=0.0
        whiteColorButton.layer.borderColor=UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0).cgColor
        whiteColorButton.layer.borderWidth=2.0
        selectedColor=UIColor.white
        
        if caption != nil {
            
            caption?.textColor=selectedColor
            caption?.layer.borderColor=selectedColor?.cgColor
        }
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
    
    // MARK: - Common Methods
    func commonMethodOfCancelDoneAction() {
        
//        if isAddTextSelected {
//            photoPreviewImageView.removeGestureRecognizer(drag!)
//        }
        scrollViewObject.delegate=self
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
    
    func commonMethodOfRotateAddTextAction() {
        
        scrollViewObject.zoomScale=1.0
        scrollViewObject.delegate=nil
        shareButton.isEnabled=false;
        airbrushButton.isEnabled=false;
        addBarButtonWithDone()
    }
    // MARK: - end
    
    // MARK: - Save image
    func saveEditedImage() {
    
        //Adds the edited image to the user’s Camera Roll album
        UIImageWriteToSavedPhotosAlbum(photoPreviewImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //UIImagePickerController delegate
    //Selector should be called after the image has been written to the Camera Roll album
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        //Stop indicator
        AppDelegate().stopIndicator(uiView: self.view)
//        activityControllerObject.isHidden=true;
        
        if error != nil {
            //We got back an error!
            let alertViewController = UIAlertController(title: nil, message: "Some error occurred, Please try again later.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                
            }
            alertViewController.addAction(okAction)
            
            present(alertViewController, animated: true, completion: nil)
        } else {
            
            let alertViewController = UIAlertController(title: nil, message: "Image has been saved.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                
                self.navigationController?.popViewController(animated: true)
            }
            alertViewController.addAction(okAction)
            
            present(alertViewController, animated: true, completion: nil)
        }
    }
    // MARK: - end
    
    // MARK: - Add caption(Text) at selected image
    func initCaption() {
        
        caption = UITextView.init(frame: CGRect(x: (UIScreen.main.bounds.size.width/2)-15, y: (photoPreviewImageView.frame.size.height/2) - 15 - 44, width: 30, height: 34))
        //        caption?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        caption?.backgroundColor = UIColor.clear
        caption?.textAlignment = NSTextAlignment.center
        caption?.textColor = UIColor.black
        caption?.keyboardAppearance = UIKeyboardAppearance.default
        caption?.tintColor = UIColor.white
        caption?.font=UIFont().montserratLightWithSize(size: 15)
        caption?.autocorrectionType=UITextAutocorrectionType.no
        caption?.delegate = self
        caption?.layer.borderWidth=1.0
        caption?.layer.borderColor=UIColor.black.cgColor
        photoPreviewImageView.addSubview(caption!)
//        caption?.becomeFirstResponder()
        caption?.isScrollEnabled=false
        caption?.addGestureRecognizer(drag!)
        
        textViewToolbar = UIToolbar.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height-64-258, width: UIScreen.main.bounds.size.width, height: 44))
        textViewToolbar?.barStyle = UIBarStyle.default
        textViewToolbar?.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doneWithNumberPad))]
        photoBackView.addSubview(textViewToolbar!)
        caption?.becomeFirstResponder()
    }
    
    func doneWithNumberPad() {
        
        if caption != nil {
            
            textViewToolbar?.isHidden=true
            caption?.layer.borderWidth=0.0
            caption?.resignFirstResponder()
        }
    }
    
    func captionDrag(gestureRecognizer:UIGestureRecognizer) {
        
        let translation = gestureRecognizer.location(in: photoPreviewImageView)
        //        print(translation)
        
        caption?.center=CGPoint(x: translation.x, y: translation.y)
//        selectTextColorBackView.isHidden=true
//        if(gestureRecognizer.state == UIGestureRecognizerState.ended) {
//            
////            selectTextColorBackView.isHidden=false
//            caption?.backgroundColor = UIColor.clear
//        }
//        else {
//        
//            caption?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
//        }
        //        if(gestureRecognizer.state == UIGestureRecognizerState.ended) {
        //
        //            //Set drag limit of caption at photoPreviewImageView
        //            if translation.y < ((caption?.frame.size.height)!/2)  {
        //
        //                caption?.center=CGPoint(x: translation.x, y: ((caption?.frame.size.height)!/2))
        ////                caption?.center=CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: ((caption?.frame.size.height)!/2))
        //            }
        //            else if translation.y > (photoPreviewImageView.frame.size.height - ((caption?.frame.size.height)!/2))  {
        //
        //                caption?.center=CGPoint(x: translation.x, y: (photoPreviewImageView.frame.size.height - ((caption?.frame.size.height)!/2)))
        ////                caption?.center=CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: (photoPreviewImageView.frame.size.height - ((caption?.frame.size.height)!/2)))
        //            }
        //        }
    }
    
    func setCustomTextAtSelectedImage() {
        
        UIGraphicsBeginImageContextWithOptions(photoPreviewImageView.frame.size, true, 0.0)
        photoPreviewImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        photoPreviewImageView.image=UIGraphicsGetImageFromCurrentImageContext()!
    }
    // MARK: - end
    
    // MARK: - UITextView delegate methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textViewToolbar?.isHidden=false
        caption?.layer.borderWidth=1.0
        textViewBeginMethod()
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        
        ////        print(textView.text.characters.count); //the textView parameter is the textView where text was changed
        //        if ((caption?.sizeThatFits((caption?.frame.size)!).height)! > CGFloat(36.0)) {
        //
        ////            caption?.frame = CGRect(x: 0, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2), width: UIScreen.main.bounds.size.width, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
        //
        //            if (caption?.sizeThatFits((caption?.frame.size)!).width)!+30 > UIScreen.main.bounds.size.width-30 {
        //
        ////                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - 15, width: UIScreen.main.bounds.size.width - 30, height: 34)
        //                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2), width: UIScreen.main.bounds.size.width - 30, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
        //            }
        //            else {
        //
        ////                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - 15, width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: 34)
        //                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2), width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
        //            }
        //        }
        //        else {
        //
        //            if (caption?.sizeThatFits((caption?.frame.size)!).width)!+30 > UIScreen.main.bounds.size.width-30 {
        //
        //                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - 15, width: UIScreen.main.bounds.size.width - 30, height: 34)
        //            }
        //            else {
        //
        //                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - 15, width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: 34)
        //            }
        //
        ////             caption = UITextView.init(frame: CGRect(x: (UIScreen.main.bounds.size.width/2)-5, y: (photoPreviewImageView.frame.size.height/2) - 15, width: 10, height: 34))
        //        }
        
        textViewBeginMethod()
    }
    
    func textViewBeginMethod() {
        
//        selectTextColorBackView.isHidden=false
        caption?.textColor=selectedColor
        caption?.layer.borderColor=selectedColor?.cgColor
        if ((caption?.sizeThatFits((caption?.frame.size)!).height)! > CGFloat(36.0)) {
            
            //            caption?.frame = CGRect(x: 0, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2), width: UIScreen.main.bounds.size.width, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
            
            if (caption?.sizeThatFits((caption?.frame.size)!).width)!+30 > UIScreen.main.bounds.size.width-30 {
                
                //                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - 15, width: UIScreen.main.bounds.size.width - 30, height: 34)
                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2) - 44, width: UIScreen.main.bounds.size.width - 30, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
            }
            else {
                
                //                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - 15, width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: 34)
                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2) - 44, width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
            }
        }
        else {
            
            if (caption?.sizeThatFits((caption?.frame.size)!).width)!+30 > UIScreen.main.bounds.size.width-30 {
                
                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - 15 - 44, width: UIScreen.main.bounds.size.width - 30, height: 34)
            }
            else {
                
                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - 15 - 44, width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: 34)
            }
            
            //             caption = UITextView.init(frame: CGRect(x: (UIScreen.main.bounds.size.width/2)-5, y: (photoPreviewImageView.frame.size.height/2) - 15, width: 10, height: 34))
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            //            print(caption?.sizeThatFits((caption?.frame.size)!).height as Any)
            if (caption?.sizeThatFits((caption?.frame.size)!).height)! > CGFloat(85.0) {
                return false
            }
            return true
        }
        else if(text.characters.count>1) {
            
            return false
        }
        else {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.characters.count // for Swift use count(newText)
            return numberOfChars < 101;
        }
    }
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
