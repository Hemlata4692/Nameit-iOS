//
//  GlobalBackViewController.swift
//  NameIt
//
//  Created by Ranosys on 05/07/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class GlobalBackViewController: UIViewController {

    // MARK: - UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackBarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - Add and customize navigation bar button
    func addBackBarButton() {
        
        self.navigationItem.leftBarButtonItem=nil
        self.navigationItem.rightBarButtonItem=nil

        //Navigation bar buttons
        let framing:CGRect=CGRect(x: 0, y: 0, width: 30, height: 30)
        let backButton=UIButton.init(frame: framing)
        backButton.setImage(UIImage.init(named: "back_btn_"), for: UIControlState.normal)
        let backBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: backButton)
        backButton.addTarget(self, action: #selector(backButtonAction), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem=backBarButton
    }
    
    func addSaveBarButton() {
        
        self.navigationItem.rightBarButtonItem=nil
        
        //Navigation bar buttons
        let framing:CGRect=CGRect(x: 0, y: 0, width: 50, height: 30)
        let saveButton=UIButton.init(frame: framing)
        saveButton.titleLabel!.font =  UIFont.systemFont(ofSize: 17)
        saveButton.setTitle("Save", for: UIControlState.normal)
        saveButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0)
        let saveBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: UIControlEvents.touchUpInside)
        self.navigationItem.rightBarButtonItem=saveBarButton
    }
    
    func addBarButtonWithDone() {
        
        self.navigationItem.leftBarButtonItem=nil
        self.navigationItem.rightBarButtonItem=nil
        
        //Navigation bar buttons
        var framing:CGRect=CGRect(x: 0, y: 0, width: 60, height: 30)
        let cancelButton=UIButton.init(frame: framing)
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, -10.0, 0.0, +10.0)
        cancelButton.titleLabel!.font =  UIFont.systemFont(ofSize: 17)
        let cancelBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem=cancelBarButton
        
        //Navigation bar buttons
        framing=CGRect(x: 0, y: 0, width: 50, height: 30)
        let doneButton=UIButton.init(frame: framing)
        doneButton.titleLabel!.font =  UIFont.systemFont(ofSize: 17)
//        doneButton.backgroundColor=UIColor.red
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, -10.0)
        let doneBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: doneButton)
        doneButton.addTarget(self, action: #selector(doneButtonAction), for: UIControlEvents.touchUpInside)
        self.navigationItem.rightBarButtonItem=doneBarButton
    }

    // MARK: - BarButton actions
    func backButtonAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveButtonAction() {}
    
    func cancelButtonAction() {}
    
    func doneButtonAction() {}
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
