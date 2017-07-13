//
//  SplashViewController.swift
//  NameIt
//
//  Created by Ranosys on 13/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet var image2: UIImageView!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView!
    @IBOutlet var image5: UIImageView!
    @IBOutlet var image6: UIImageView!
    @IBOutlet var image7: UIImageView!
    @IBOutlet var image8: UIImageView!
    @IBOutlet var image9: UIImageView!
    
    var scaleFactor:CGFloat?
    var size:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden=true
        changeImageSize()
        // Do any additional setup after loading the view.
    }
    
    func changeImageSize() {
        
        scaleFactor = UIScreen.main.bounds.size.width/320.0
        size=165.0*scaleFactor!
        
        image1.translatesAutoresizingMaskIntoConstraints=true
        image2.translatesAutoresizingMaskIntoConstraints=true
        image3.translatesAutoresizingMaskIntoConstraints=true
        image4.translatesAutoresizingMaskIntoConstraints=true
        image5.translatesAutoresizingMaskIntoConstraints=true
        image6.translatesAutoresizingMaskIntoConstraints=true
        image7.translatesAutoresizingMaskIntoConstraints=true
        image8.translatesAutoresizingMaskIntoConstraints=true
        image9.translatesAutoresizingMaskIntoConstraints=true
        
        image1.frame=CGRect(x: -(size!+10), y: UIScreen.main.bounds.size.height-size!+(23*scaleFactor!), width: size!, height: size!)
        image2.frame=CGRect(x: UIScreen.main.bounds.size.width+10, y: UIScreen.main.bounds.size.height-size!+(23*scaleFactor!), width: size!, height: size!)
        image3.frame=CGRect(x: -(size!*self.scaleFactor!), y: 0, width: size!, height: size!)
        image4.frame=CGRect(x: -(size!*self.scaleFactor!), y: (63*self.scaleFactor!), width: size!, height: size!)
        image5.frame=CGRect(x: (28*self.scaleFactor!), y: -(size!+10), width: size!, height: size!)
        image6.frame=CGRect(x: (UIScreen.main.bounds.size.width/2.0)-(size!/2.0)+2.5, y: -(size!+10), width: size!, height: size!)
        image7.frame=CGRect(x: UIScreen.main.bounds.size.width+10, y: (50*self.scaleFactor!), width: size!, height: size!)
        image8.frame=CGRect(x: UIScreen.main.bounds.size.width-self.size!-(9*self.scaleFactor!), y: -(size!+10), width: size!, height: size!)
        image9.frame=CGRect(x: UIScreen.main.bounds.size.width+10, y: -(14*self.scaleFactor!), width: size!, height: size!)
        
        animation1()
    }
    
    func animation1() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.image2.frame=CGRect(x: UIScreen.main.bounds.size.width-self.size!+(17*self.scaleFactor!), y: UIScreen.main.bounds.size.height-self.size!+(23*self.scaleFactor!), width: self.size!, height: self.size!)
        }) { (success) in
            
            self.animation2()
        }
    }
    
    func animation2() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.image1.frame=CGRect(x: UIScreen.main.bounds.size.width-self.size!-(93*self.scaleFactor!), y: UIScreen.main.bounds.size.height-self.size!+(23*self.scaleFactor!), width: self.size!, height: self.size!)
        }) { (success) in
            
            self.animation3()
        }
    }
    
    func animation3() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.image3.frame=CGRect(x: -(61*self.scaleFactor!), y: 0, width: self.size!, height: self.size!)
        }) { (success) in
            
            self.animation4()
        }
    }
    
    func animation4() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.image9.frame=CGRect(x: UIScreen.main.bounds.size.width-self.size!+(70*self.scaleFactor!), y: -(14*self.scaleFactor!), width: self.size!, height: self.size!)
        }) { (success) in
            
            self.animation5()
        }
    }
    
    func animation5() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.image5.frame=CGRect(x: (28*self.scaleFactor!), y: -(15*self.scaleFactor!), width: self.size!, height: self.size!)
        }) { (success) in
            
            self.animation6()
        }
    }
    
    func animation6() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.image8.frame=CGRect(x: UIScreen.main.bounds.size.width-self.size!-(9*self.scaleFactor!), y: -(15*self.scaleFactor!), width: self.size!, height: self.size!)
        }) { (success) in
            self.animation7()
        }
    }
    
    func animation7() {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.image4.frame=CGRect(x: (11*self.scaleFactor!), y: (63*self.scaleFactor!), width: self.size!, height: self.size!)
            self.image7.frame=CGRect(x: UIScreen.main.bounds.size.width-self.size!+(4*self.scaleFactor!), y: (50*self.scaleFactor!), width: self.size!, height: self.size!)
            self.image6.frame=CGRect(x: (UIScreen.main.bounds.size.width/2.0)-(self.size!/2.0)+2.5, y: (50*self.scaleFactor!), width: self.size!, height: self.size!)
        }) { (success) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    let photoPreviewViewObj = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
                    self.navigationController?.pushViewController(photoPreviewViewObj!, animated: false)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
