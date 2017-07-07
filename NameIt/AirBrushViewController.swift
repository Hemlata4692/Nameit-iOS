//
//  AirBrushViewController.swift
//  NameIt
//
//  Created by Ranosys on 07/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AssetsLibrary

class AirBrushViewController: GlobalBackViewController, UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var airbrushButton: UIButton!
    @IBOutlet var addTextButton: UIButton!
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var eraserButton: UIButton!
    
    @IBOutlet var photoPreviewImageView: UIImageView!
    @IBOutlet var colorSliderImageView: UIImageView!
    @IBOutlet var tempPhotoImageView: UIImageView!
  
    var photoPreviewObj:PtotoPreviewViewController?
    var selectedPhoto:UIImage?
    var screenTitle:NSString?
    
    var selectedImageSize:CGSize?
    var isImageEdited:Bool = false
    
    
    @IBOutlet var colorPreviewView: UIView!
    @IBOutlet var resizeSlider: UISlider!
    
    var lastPoint = CGPoint.zero
    var brushWidth: CGFloat = 5.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var eraserSelected=false
    var selectedColor:UIColor?
    
    let size:CGSize=CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-114)
    
    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBarButtonWithDone()
        viewIntialization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - UIView initialized
    func viewIntialization() {
        
        //Set navigation title
        self.navigationItem.title=screenTitle! as String
        
        shareButton.isEnabled=false;
        airbrushButton.isEnabled=true;
        rotateButton.isEnabled=false;
        addTextButton.isEnabled=false;
        
        selectedColor=UIColor.red
        colorPreviewView.isHidden=true;
        colorPreviewView.backgroundColor=selectedColor
        colorPreviewView.layer.cornerRadius=18
        colorPreviewView.layer.masksToBounds=true
        
        colorSliderImageView.layer.cornerRadius=8
        colorSliderImageView.layer.masksToBounds=true
        
        eraserButton.layer.cornerRadius=13
        eraserButton.layer.masksToBounds=true
        
        selectedImageSize = selectedPhoto?.size
        tempPhotoImageView.image=selectedPhoto
        photoPreviewImageView.image=selectedPhoto
        photoPreviewImageView.isUserInteractionEnabled=true
        
//        //Customize slider view
//        resizeSlider.setMaximumTrackImage(UIImage(), for: UIControlState.normal)
//        resizeSlider.setMinimumTrackImage(UIImage(), for: UIControlState.normal)
//        resizeSlider.setThumbImage(UIImage.init(named: "sliderThumb"), for: UIControlState.normal)
    }
    
    // MARK: - IBActions
    @IBAction func eraserButtonAction(_ sender: Any) {
        
        eraserSelected=true
    }
    
    @IBAction func addAirbrush(_ sender: UIButton) {
        
       
    }
    
    override func cancelButtonAction() {
        
        self.navigationController?.popViewController(animated: false)
    }
    
    override func doneButtonAction() {
        
        mergeAirbrushedImage()
        selectedPhoto=photoPreviewImageView.image
        photoPreviewObj?.selectedPhoto=selectedPhoto
        photoPreviewObj?.isAirBrushDone=true
        self.navigationController?.popViewController(animated: false)
    }
    // MARK: - end
    
    // MARK: - UITouch methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        for touch: AnyObject in touches {
            print(touch.view.tag)
            if (touch.view == tempPhotoImageView) {
                
                if let touch = touches.first {
                    
                    isImageEdited=true
                    lastPoint = touch.location(in: tempPhotoImageView)
                    eraserButton.isHidden=true
                    colorSliderImageView.isHidden=true
                }
            }
            else if (touch.view == colorSliderImageView) {
                
                if let touch = touches.first {
                    
                    eraserSelected=false
                    let location = touch.location(in: colorSliderImageView)
                    let locationAtMainView = touch.location(in: tempPhotoImageView)
                    colorPreviewView.isHidden=false;
                    colorPreviewView.frame=CGRect(x: UIScreen.main.bounds.size.width - 70, y: locationAtMainView.y - 18, width: 36, height: 36)
                    selectedColor = getPixelColorAtPoint(point: location)
                    colorPreviewView.backgroundColor=selectedColor
                }
            }
        }
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        tempPhotoImageView.image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        if (eraserSelected) {
            context?.setBlendMode(CGBlendMode.clear)
        }
        else{
            context?.setStrokeColor((selectedColor?.cgColor)!)
            context?.setBlendMode(CGBlendMode.normal)
        }
        context?.strokePath()
        tempPhotoImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempPhotoImageView.alpha=1.0
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        for touch: AnyObject in touches {
            if (touch.view == tempPhotoImageView) {
                
                if let touch = touches.first {
                    
                    let currentPoint = touch.location(in: tempPhotoImageView)
                    drawLineFrom(lastPoint, toPoint: currentPoint)
                    lastPoint = currentPoint
                }
            }
            else if (touch.view == colorSliderImageView) {
                
                if let touch = touches.first {
                    
                    let location = touch.location(in: colorSliderImageView)
                    print(location.x)
                    if location.y > 1 && location.y < 245 && location.x > 1 && location.x < 15 {
                        let locationAtMainView = touch.location(in: tempPhotoImageView)
                        colorPreviewView.isHidden=false;
                        colorPreviewView.frame=CGRect(x: UIScreen.main.bounds.size.width - 70, y: locationAtMainView.y - 18, width: 36, height: 36)
                        
                        selectedColor = getPixelColorAtPoint(point: location)
                        colorPreviewView.backgroundColor=selectedColor
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            if (touch.view == tempPhotoImageView) {
                
                if touches.first != nil {
                    
                    if !swiped {
                        UIGraphicsBeginImageContext(size)
                        let context = UIGraphicsGetCurrentContext()
                        tempPhotoImageView.image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                        context?.setLineCap(CGLineCap.round)
                        context?.setLineWidth(brushWidth)
                        if (eraserSelected) {
                            context?.setBlendMode(CGBlendMode.clear)
                        }
                        else{
                            context?.setStrokeColor((selectedColor?.cgColor)!)
                            context?.setBlendMode(CGBlendMode.normal)
                        }
                        context?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                        context?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
                        context?.strokePath()
                        context?.flush()
                        tempPhotoImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                    }
                    
                    eraserButton.isHidden=false
                    colorSliderImageView.isHidden=false
                }
            }
            else if (touch.view == colorSliderImageView) {
                
                if touches.first != nil {
                    colorPreviewView.isHidden=true;
                }
            }
            
        }
    }
    // MARK: - end
    
    // MARK: - Get color from selected location
    func getPixelColorAtPoint(point:CGPoint) -> UIColor {
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        colorSliderImageView.layer.render(in: context!)
        var color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)
        if CGFloat(pixel[3])/255.0 == 0 {
            color = selectedColor!
        }
        pixel.deallocate(capacity: 4)
        
        return color
    }
    // MARK: - end
    
    // MARK: - Merge airbrushed image
    func mergeAirbrushedImage() {
        
        //Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(size)
        photoPreviewImageView.image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode:CGBlendMode.normal, alpha: 1.0)
        tempPhotoImageView.image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height:size.height), blendMode:CGBlendMode.normal, alpha: 1.0)
        photoPreviewImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempPhotoImageView.image = nil
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
