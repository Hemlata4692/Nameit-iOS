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
        
        addLeftBarButtonWithImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - end
    
    // MARK: - Add left navigation bar button
    func addLeftBarButtonWithImage() {
        
        //Navigation bar buttons
        let framing:CGRect=CGRect(x: 0, y: 0, width: 30, height: 30)
        let backButton=UIButton.init(frame: framing)
        backButton.setImage(UIImage.init(named: "back_btn_"), for: UIControlState.normal)
        let backBarButton:UIBarButtonItem=UIBarButtonItem.init(customView: backButton)
        backButton.addTarget(self, action: #selector(backButtonAction), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem=backBarButton
    }

    // MARK: - Back barButton action
    func backButtonAction() {
        
        self.navigationController?.popViewController(animated: true)
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
