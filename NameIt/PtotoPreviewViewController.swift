//
//  PtotoPreviewViewController.swift
//  NameIt
//
//  Created by Ranosys on 03/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class PtotoPreviewViewController: GlobalBackViewController, UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var airbrushButton: UIButton!
    @IBOutlet var addTextButton: UIButton!
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var renameButton: UIButton!
    
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
    
    var assetRepresent:ALAssetRepresentation?
    
    var caption:UITextView?
    var textViewToolbar:UIToolbar?
    var drag:UIPanGestureRecognizer?
    
    var isAirBrushDone:Bool=false
    
    //Select add textLabel color
    @IBOutlet var selectTextColorBackView: UIView!
    @IBOutlet var whiteColorButton: UIButton!
    @IBOutlet var blackColorButton: UIButton!
    var selectedColor:UIColor?
    
    var lastEnteredUpdatedImageName:String=""
    var nonUpdatedPhotoName:String=""
    var cameraRollAssets: NSMutableArray?
    var isImageRenamed:Bool = false
    var keyboardHeight:CGFloat=258
    var assetsGroup:ALAssetsGroup?
    
    var dashboardViewObject:ViewController?
    var selectedDictData:NSDictionary?
    
    //Swipe gesture
    var swipeRight:UISwipeGestureRecognizer?
    var swipeLeft:UISwipeGestureRecognizer?
    var selectedImageIndex:Int?
    var swipedImageAssetArray: NSMutableArray = []
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewIntialization()
        nonUpdatedPhotoName=selectedPhotoName!
        initializedSwipeGesture()   //Set swipe gesture at photoBackView
        //Set keyboard show notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isAirBrushDone {
            //Change after done action of airbrush
            selectedImageSize = selectedPhoto?.size
            photoPreviewImageView.image=selectedPhoto
            photoPreviewImageView.isUserInteractionEnabled=true
            //Change photoPreviewImageView according to selected image size ratio
            changeImageRatio()
            isImageEdited=true
            addSaveBarButton()
            addSwipeGesture()
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
        assetRepresent = selectedPhotoAsset!.defaultRepresentation()
        let fullImageRef:CGImage=assetRepresent!.fullScreenImage().takeUnretainedValue()
        let fullImage:UIImage=UIImage.init(cgImage: fullImageRef)
        selectedPhoto=fullImage
        //Set navigation title
        self.navigationItem.title=selectedPhotoName?.components(separatedBy: ".").first?.capitalized
        selectedImageSize = selectedPhoto?.size
        photoPreviewImageView.image=selectedPhoto
        photoPreviewImageView.isUserInteractionEnabled=true
        selectTextColorBackView.isHidden=true
        whiteColorButton.layer.cornerRadius=13
        whiteColorButton.layer.masksToBounds=true
        blackColorButton.layer.cornerRadius=13
        blackColorButton.layer.masksToBounds=true
        blackColorButton.layer.borderColor=UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0).cgColor
        blackColorButton.layer.borderWidth=2.0
        whiteColorButton.layer.borderColor=UIColor.lightGray.cgColor
        whiteColorButton.layer.borderWidth=2.0
        selectedColor=UIColor.black
        //Set back left bar button
        addBackBarButton()
        isImageEdited=false;
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
    @IBAction func renameImage(_ sender: UIButton) {
        editImageNameRecursiveMethod()
    }
    
    @IBAction func shareImage(_ sender: UIButton) {
        var selectedImageArrayToShare:Array<NSURL> = [NSURL]()
        selectedImageArrayToShare.append(saveActivityControllerImage())
        //Present UIActivityViewController to share images
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: selectedImageArrayToShare as [Any], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func rotateImage(_ sender: UIButton) {
        if !isRotateSelected {
            removeSwipeGesture()
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
            removeSwipeGesture()
            selectedColor=UIColor.black
            isAddTextSelected=true
            rotateButton.isEnabled=false;
            commonMethodOfRotateAddTextAction()
            photoPreviewImageView.translatesAutoresizingMaskIntoConstraints=true;
            photoPreviewImageView.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-(64.0+64.0))
            initCaption()
        }
        else {
            caption?.becomeFirstResponder()
        }
    }
    
    @IBAction func addAirbrush(_ sender: UIButton) {
        removeSwipeGesture()
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
            AppDelegate().showIndicator(uiView: self.view)
            self.perform( #selector(saveEditedImage), with: nil, afterDelay: 0.01)
        }
        else {
            if isImageRenamed {
                AppDelegate().insertUpdateRenamedText(imageName: (assetRepresent?.filename().components(separatedBy: ".").first!.lowercased())!, rename: (selectedPhotoName?.components(separatedBy: ".").first!.lowercased())!)
                dashboardViewObject?.renameDatabaseDicData?.setValue((selectedPhotoName?.components(separatedBy: ".").first!.lowercased())!, forKey: (assetRepresent?.filename().components(separatedBy: ".").first!.lowercased())!)
                dashboardViewObject?.cameraRollAssets = editedNameInDashboardView(tempDict: (dashboardViewObject?.cameraRollAssets)!)
                if (dashboardViewObject?.searchedCameraRollAssets.count)!>0 {
                    dashboardViewObject?.searchedCameraRollAssets = editedNameInDashboardView(tempDict: (dashboardViewObject?.searchedCameraRollAssets)!)
                }
                self.showImageSavedPopUp(message: "Image has been renamed.")
            }
            else {
                dashboardViewObject?.scrollAtIndex=selectedImageIndex!
                dashboardViewObject?.scrolledCollectionAtIndexPath()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func cancelButtonAction() {
        selectedImageSize = selectedPhoto?.size
        photoPreviewImageView.image=selectedPhoto
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
        whiteColorButton.layer.borderColor=UIColor.lightGray.cgColor
        whiteColorButton.layer.borderWidth=2.0
        blackColorButton.layer.borderColor=UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0).cgColor
        blackColorButton.layer.borderWidth=2.0
        selectedColor=UIColor.black
        if caption != nil {
            caption?.textColor=selectedColor
            caption?.layer.borderColor=selectedColor?.cgColor
        }
    }
    
    @IBAction func selectWhiteColor(_ sender: UIButton) {
        blackColorButton.layer.borderColor=UIColor.lightGray.cgColor
        blackColorButton.layer.borderWidth=2.0
        whiteColorButton.layer.borderColor=UIColor(red: 5.0/255.0, green: 144.0/255.0, blue: 201.0/255.0, alpha: 1.0).cgColor
        whiteColorButton.layer.borderWidth=2.0
        selectedColor=UIColor.white
        if caption != nil {
            caption?.textColor=selectedColor
            caption?.layer.borderColor=selectedColor?.cgColor
        }
    }
    
    override func backButtonAction() {
        dashboardViewObject?.scrollAtIndex=selectedImageIndex!
        dashboardViewObject?.scrolledCollectionAtIndexPath()
        self.navigationController?.popViewController(animated: true)
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
        scrollViewObject.delegate=self
        //Change photoPreviewImageView according to selected image size ratio
        changeImageRatio()
        isRotateSelected=false;
        isAddTextSelected=false;
        shareButton.isEnabled=true;
        airbrushButton.isEnabled=true;
        rotateButton.isEnabled=true;
        addTextButton.isEnabled=true;
        renameButton.isEnabled=true;
        //Show back bar button and show save button if image is edited
        addBackBarButton()
        if isImageEdited || isImageRenamed {
            addSaveBarButton()
        }
        addSwipeGesture()
    }
    
    func commonMethodOfRotateAddTextAction() {
        scrollViewObject.zoomScale=1.0
        scrollViewObject.delegate=nil
        shareButton.isEnabled=false;
        airbrushButton.isEnabled=false;
        renameButton.isEnabled=false;
        addBarButtonWithDone()
    }
    // MARK: - end
    
    // MARK: - Save image
    func saveEditedImage() {
        let library = ALAssetsLibrary()
        library.writeImage(toSavedPhotosAlbum: photoPreviewImageView.image?.cgImage, orientation: ALAssetOrientation.init(rawValue: (photoPreviewImageView.image?.imageOrientation.rawValue)!)!, completionBlock: {
            url, error in
            if error == nil {
                library.asset(for: url, resultBlock: { (asset) -> Void in
                    if self.isImageRenamed {
                        AppDelegate().insertUpdateRenamedText(imageName: (asset?.defaultRepresentation().filename().components(separatedBy: ".").first!.lowercased())!, rename: (self.selectedPhotoName?.components(separatedBy: ".").first!.lowercased())!)
                        self.dashboardViewObject?.loadVeiwImageEdited()
                        self.showImageSavedPopUp(message: "Image has been saved.")
                    }
                    else {
                        self.dashboardViewObject?.loadVeiwImageEdited()
                        self.showImageSavedPopUp(message: "Image has been saved.")
                    }
                }, failureBlock: { (error) -> Void in
                })
            } else {
                AppDelegate().stopIndicator(uiView: self.view)
                let alertViewController = UIAlertController(title: nil, message: "Some error occurred, Please try again later.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                }
                alertViewController.addAction(okAction)
                self.navigationController?.present(alertViewController, animated: true, completion: nil)
            }
        })
    }
    // MARK: - end
    
    // MARK: - Add caption(Text) at selected image
    func initCaption() {
        caption = UITextView.init(frame: CGRect(x: (UIScreen.main.bounds.size.width/2)-15, y: (photoPreviewImageView.frame.size.height/2) - 15 - 88, width: 30, height: 34))
        caption?.backgroundColor = UIColor.clear
        caption?.textAlignment = NSTextAlignment.center
        caption?.textColor = UIColor.black
        caption?.keyboardType=UIKeyboardType.default
        caption?.keyboardAppearance = UIKeyboardAppearance.default
        caption?.tintColor = UIColor.white
        caption?.font=UIFont().montserratLightWithSize(size: 15)
        caption?.autocorrectionType=UITextAutocorrectionType.no
        caption?.delegate = self
        caption?.layer.borderWidth=1.0
        caption?.layer.borderColor=UIColor.black.cgColor
        photoPreviewImageView.addSubview(caption!)
        caption?.isScrollEnabled=false
        caption?.addGestureRecognizer(drag!)
        textViewToolbar = UIToolbar.init(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height-64-keyboardHeight, width: UIScreen.main.bounds.size.width, height: 44))
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
        caption?.center=CGPoint(x: translation.x, y: translation.y)
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
        textViewBeginMethod()
    }
    
    func textViewBeginMethod() {
        caption?.textColor=selectedColor
        caption?.layer.borderColor=selectedColor?.cgColor
        if ((caption?.sizeThatFits((caption?.frame.size)!).height)! > CGFloat(36.0)) {
            if (caption?.sizeThatFits((caption?.frame.size)!).width)!+30 > UIScreen.main.bounds.size.width-30 {
                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2) - 88, width: UIScreen.main.bounds.size.width - 30, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
            }
            else {
                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - ((caption?.sizeThatFits((caption?.frame.size)!).height)!/2) - 88, width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: (caption?.sizeThatFits((caption?.frame.size)!).height)!)
            }
        }
        else {
            if (caption?.sizeThatFits((caption?.frame.size)!).width)!+30 > UIScreen.main.bounds.size.width-30 {
                
                caption?.frame = CGRect(x: 15, y: (photoPreviewImageView.frame.size.height/2) - 15 - 88, width: UIScreen.main.bounds.size.width - 30, height: 34)
            }
            else {
                caption?.frame = CGRect(x: (UIScreen.main.bounds.size.width/2)-((caption?.sizeThatFits((caption?.frame.size)!).width)!/2)-15, y: (photoPreviewImageView.frame.size.height/2) - 15 - 88, width: (caption?.sizeThatFits((caption?.frame.size)!).width)!+30, height: 34)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
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
    
    // MARK: - Keyboard show-hide methods
    func keyboardWillShow(notification: NSNotification) {
        let info:NSDictionary=notification.userInfo as NSDictionary!
        let aValue:NSValue=info.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        keyboardHeight=aValue.cgRectValue.size.height
        print(keyboardHeight)
        textViewToolbar?.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height-64-keyboardHeight-44, width: UIScreen.main.bounds.size.width, height: 44)
    }
    // MARK: - end
    
    // MARK: - Image rename handling
    func editImageNameRecursiveMethod() {
        let alert = UIAlertController(title: "", message: "Please enter new image name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let saveAction = UIAlertAction(title:"Apply", style: .default, handler: { (action) -> Void in
            if let alertTextField = alert.textFields?.first, alertTextField.text != nil {
                if alertTextField.text?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != self.nonUpdatedPhotoName
                    .components(separatedBy: ".").first!.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                    var tempString:String=(alertTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    tempString = tempString + "." + (self.selectedPhotoName?.components(separatedBy: ".").last!)!
                    //Check for dot '.' character
                    let charset = CharacterSet(charactersIn: "./")
                    if alertTextField.text?.rangeOfCharacter(from: charset) != nil {
                        alert.dismiss(animated: false, completion: nil)
                        self.showImageNameAlreadyExistAlert(title: "Alert", message: "Dot '.' and Slash '/' characters are not allowed", tempString: alertTextField.text!)
                    }
                        //Check entered name is already exist or not
                    else if !self.isImageNameAlreadyExist(searchText: tempString) {
                        self.isImageRenamed=true
                        let tempString:String=(alertTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                        self.selectedPhotoName = tempString + "." + self.selectedPhotoName!.components(separatedBy: ".").last!
                        //Set navigation title
                        self.navigationItem.title=self.selectedPhotoName?.components(separatedBy: ".").first?.capitalized
                        self.addSaveBarButton()
                    }
                    else {
                        alert.dismiss(animated: false, completion: nil)
                        self.showImageNameAlreadyExistAlert(title: "Alert", message: "This image name already exists.", tempString: alertTextField.text!)
                    }
                }
                else {
                    self.selectedPhotoName = self.nonUpdatedPhotoName
                    //Set navigation title
                    self.navigationItem.title=self.selectedPhotoName?.components(separatedBy: ".").first?.capitalized
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
                textField.text=self.selectedPhotoName?
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
    
    func editedNameInDashboardView(tempDict:NSMutableArray) -> NSMutableArray {
        let index:Int=tempDict.index(of: selectedDictData as Any)
        let tempDictData:NSDictionary=tempDict.object(at: index) as! NSDictionary
        let tempMutableData:NSMutableDictionary=tempDictData.mutableCopy() as! NSMutableDictionary
        tempMutableData.setValue(selectedPhotoName?.lowercased(), forKey: "FileName")
        tempDict.replaceObject(at: index, with: tempMutableData)
        return tempDict
    }
    
    func isImageNameAlreadyExist(searchText:String) -> Bool {
        let tempString=searchText.components(separatedBy: ".").first! + "."
        let photoNamePredicate = NSPredicate(format: "FileName BEGINSWITH %@", tempString.lowercased())
        let tempFilteredArray:NSMutableArray=cameraRollAssets!.filtered(using: photoNamePredicate) as! NSMutableArray
        if tempFilteredArray.count > 0 {
            return true
        }
        return false
    }
    
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
    
    // MARK: - Save selected image in DocumentDirectory and return path of images
    func saveActivityControllerImage() -> NSURL {
        var name:String=selectedPhotoName!.capitalized
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
                    isSaved = ((try  UIImagePNGRepresentation(photoPreviewImageView.image!)?.write(to: urlString as URL, options: Data.WritingOptions.atomic)) != nil)
                }
                else {
                    isSaved = ((try  UIImageJPEGRepresentation(photoPreviewImageView.image!, 1.0)?.write(to: urlString as URL, options: Data.WritingOptions.atomic)) != nil)
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
    
    //Get documentDirectory path
    func getDocumentDirectoryPath(fileName:String) -> NSURL {
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuementDir:NSString = paths.object(at: 0) as! NSString
        return NSURL.fileURL(withPath: docuementDir.appendingPathComponent("NameIt/\(fileName)")) as NSURL
    }
    // MARK: - end
    
    // MARK: - Show popUp
    func showImageNameAlreadyExistAlert(title:String, message messageText:String, tempString:String) {
        let alertViewController = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            self.lastEnteredUpdatedImageName=tempString
            alertViewController.dismiss(animated: false, completion: nil)
            self.editImageNameRecursiveMethod()
        }
        alertViewController.addAction(okAction)
        self.navigationController?.present(alertViewController, animated: false, completion: nil)
    }
    
    func showImageSavedPopUp(message:String) {
        AppDelegate().stopIndicator(uiView: self.view)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            if !self.isImageEdited && self.isImageRenamed {
                if (self.dashboardViewObject?.isSearch)! {
                    self.swipedImageAssetArray=(self.dashboardViewObject?.searchedCameraRollAssets.mutableCopy() as! NSMutableArray)
                }
                else {
                    self.swipedImageAssetArray=(self.dashboardViewObject?.cameraRollAssets.mutableCopy() as! NSMutableArray)
                }
                self.resetAllInitializedVariables ()
            }
            else {
                 self.navigationController?.popViewController(animated: true)
            }
        }
        alertViewController.addAction(okAction)
        
        present(alertViewController, animated: true, completion: nil)
    }
    // MARK: - end
    
    // MARK: - Add swipe gesture
    func initializedSwipeGesture() {
        if (dashboardViewObject?.isSearch)! {
            swipedImageAssetArray=(dashboardViewObject?.searchedCameraRollAssets.mutableCopy() as! NSMutableArray)
        }
        else {
            swipedImageAssetArray=(cameraRollAssets?.mutableCopy() as! NSMutableArray)
        }
        setSwipeGesture()
    }
    
    func setSwipeGesture () {
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(PtotoPreviewViewController.respondToSwipeGestureRight))
        swipeRight?.direction = UISwipeGestureRecognizerDirection.right
        swipeRight?.delegate=self
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(PtotoPreviewViewController.respondToSwipeGestureLeft))
        swipeLeft?.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft?.delegate=self
        
        addSwipeGesture()
    }
    
    func respondToSwipeGestureRight () {
        selectedImageIndex = selectedImageIndex!-1;
        if selectedImageIndex! >= 0 {
            //Swipe image
            resetAllInitializedVariables()
            //Load full image and image name from selectedImageAsset
            assetRepresent = selectedPhotoAsset!.defaultRepresentation()
            let fullImageRef:CGImage=assetRepresent!.fullScreenImage().takeUnretainedValue()
            let fullImage:UIImage=UIImage.init(cgImage: fullImageRef)
            photoPreviewImageView.image=fullImage
            let moveImageView:UIImageView=photoPreviewImageView
            addRightAnimationPresentToView(viewTobeAnimatedRight: moveImageView)
        }
        else {
            selectedImageIndex = 0;
        }
    }
    
    func respondToSwipeGestureLeft () {
        selectedImageIndex = selectedImageIndex!+1;
        if selectedImageIndex!<swipedImageAssetArray.count {
            //Swipe image
            resetAllInitializedVariables()
            //Load full image and image name from selectedImageAsset
            assetRepresent = selectedPhotoAsset!.defaultRepresentation()
            let fullImageRef:CGImage=assetRepresent!.fullScreenImage().takeUnretainedValue()
            let fullImage:UIImage=UIImage.init(cgImage: fullImageRef)
            photoPreviewImageView.image=fullImage
            let moveImageView:UIImageView=photoPreviewImageView
            addLeftAnimationPresentToView(viewTobeAnimatedLeft: moveImageView)
        }
        else {
            selectedImageIndex = swipedImageAssetArray.count-1;
        }
    }
    
    func resetAllInitializedVariables() {
        var tempDictData:NSDictionary?
        tempDictData=swipedImageAssetArray[selectedImageIndex!] as? NSDictionary
        selectedPhotoAsset=tempDictData?.object(forKey: "Asset") as? ALAsset
        let imageName:String=tempDictData?.object(forKey: "FileName") as! String
        selectedPhotoName=imageName
        selectedDictData=tempDictData;
        viewIntialization()
    }

    func removeSwipeGesture() {
        photoBackView.removeGestureRecognizer(swipeRight!)
        photoBackView.removeGestureRecognizer(swipeLeft!)
    }
    
    func addSwipeGesture() {
        photoBackView.addGestureRecognizer(swipeRight!)
        photoBackView.addGestureRecognizer(swipeLeft!)
    }
    
    //Adding left animation to banner images
    func addLeftAnimationPresentToView(viewTobeAnimatedLeft:UIView) {
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction=CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        transition.setValue("IntroSwipeIn", forKey: "IntroAnimation")
        transition.fillMode=kCAFillModeForwards
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        viewTobeAnimatedLeft.layer.add(transition, forKey: nil)
    }
    
    //Adding right animation to banner images
    func addRightAnimationPresentToView(viewTobeAnimatedRight:UIView) {
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction=CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        transition.setValue("IntroSwipeIn", forKey: "IntroAnimation")
        transition.fillMode=kCAFillModeForwards
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        viewTobeAnimatedRight.layer.add(transition, forKey: nil)
    }
    // MARK: - end
}
