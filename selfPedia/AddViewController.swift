//
//  AddViewController.swift
//  selfPedia
//
//  Created by 川村周也 on 2018/11/01.
//  Copyright © 2018 川村周也. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var dataManager = DataManager()
    var currentID = "0"
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        // Do any additional setup after loading the view.
        nameTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if nameTextField.text == ""{
            
        }else{
            let newFolder = AnimeFolder()
            currentID = dataManager.hierarchy.last!
            newFolder.title = nameTextField.text!
            newFolder.parentID = currentID
            if viewController is MyListViewController || viewController is NextListViewController{
                dataManager.addAnimeFolder(parent: currentID, folder: newFolder)
            }
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
