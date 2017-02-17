//
//  ViewController.swift
//  Assignment1
//
//  Created by Assaf, Michael on 2017-02-02.
//  Copyright © 2017 Assaf, Michael. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ContactSavable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    let MIN_NAME_LENGTH = 3
    let MIN_PHONE_LENGTH = 10
    let MAX_PHONE_LENGTH = 14

    // Main Contacts list
    var theContacts = [Contact]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    // Temp searched Contacts list
    var theFilteredContacts = [Contact]()
    var NAME_IS_VALID = false
    var PHONE_IS_VALID = false
    
    // Get Object Context from persistant container within AppDelegate
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Title of Navigation bar
        navigationBar.title = "Contacts"
        
        // Search Bar Settings
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.automaticallyAdjustsScrollViewInsets = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Fetch Request People from CoreData
        loadPeopleFromCoreData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Filter main Contacts list depending on Search Bar Text
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        theFilteredContacts = theContacts.filter { Contact in
            return Contact.theName.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    // Fetch People from CoreData
    func loadPeopleFromCoreData() {
        let theFetchRequest:NSFetchRequest<PersonEntity> = PersonEntity.fetchRequest()
        
        do {
            for aPersonEntity in try self.managedObjectContext.fetch(theFetchRequest){
                let aPerson = Contact(theName: aPersonEntity.name!, thePhoneNum: aPersonEntity.phoneNumber!, theManagedObject: aPersonEntity)
                self.theContacts.append(aPerson)
            }
        } catch {
            fatalError("Failure loading Person Entities from CoreData: \(error)")
        }
    }
}

// DataSource Methods
extension ViewController {
    func SaveAContact(theContact:Contact, indexOfContact:Int!) {
        if let _ = indexOfContact {
            self.theContacts[indexOfContact] = theContact
        }
        else {
            self.theContacts.append(theContact)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return theFilteredContacts.count
        }
        
        return self.theContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = self.tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            theCell.textLabel?.text = self.theFilteredContacts[indexPath.row].theName
            theCell.detailTextLabel?.text = self.theFilteredContacts[indexPath.row].thePhoneNum
        }
        else {
            theCell.textLabel?.text = self.theContacts[indexPath.row].theName
            theCell.detailTextLabel?.text = self.theContacts[indexPath.row].thePhoneNum
        }
        return theCell
    }
}

// Button Actions
extension ViewController {
    @IBAction func doAdd(_ sender: UIBarButtonItem) {
            // Create Add Alert
            let doAddAlert = UIAlertController(title: "Name and Phone", message: "Please enter Name and Phone Number...", preferredStyle: .alert)
        
            // Create Cancel and Add Actions
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let addAction = UIAlertAction(title: "Add Contact", style: .default, handler: { (_) in
            
                // Reverse if... if true then skip the else
                guard let theNameTextField = doAddAlert.textFields?.first, let theName = theNameTextField.text
                    else{
                        return
                    }
                guard let thePhoneTextField = doAddAlert.textFields?.last, let thePhoneNumber = thePhoneTextField.text
                    else{
                        return
                }
            
                let thePersonEntity = PersonEntity(context: self.managedObjectContext)
                
                // Valid Name! Add it to List of Contacts in Table View
                self.theContacts.append(Contact(theName: theName, thePhoneNum: thePhoneNumber, theManagedObject: thePersonEntity))
                
                thePersonEntity.name = theName
                thePersonEntity.phoneNumber = thePhoneNumber
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    fatalError("Failure to save PersonEntity to CoreData: \(error)")
                }
        })
        
        // Add Action is flase at default
        addAction.isEnabled = false
        
        // Add Actions to the Add Alert
        doAddAlert.addAction(cancelAction)
        doAddAlert.addAction(addAction)
        
        // add a Text Field to the Alert
        doAddAlert.addTextField{(textField: UITextField!) -> Void in
            textField.placeholder = "Name (3 or more chars)"
            textField.keyboardType = UIKeyboardType.alphabet
        }
        // add a Text Field to the Alert
        doAddAlert.addTextField{(textField: UITextField!) -> Void in
            textField.placeholder = "Phone number (10 to 14 chars)"
            textField.keyboardType = UIKeyboardType.phonePad
        }
        
        self.NAME_IS_VALID = false
        self.PHONE_IS_VALID = false
        
        // Add Event Handler for Text Field (Name and Phone)
        doAddAlert.textFields?.first?.addTarget(self, action: #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        doAddAlert.textFields?.last?.addTarget(self, action: #selector(phoneTextFieldDidChange(_:)), for: .editingChanged)
        
        // Present the Alert
        present(doAddAlert, animated: true, completion: nil)
    }
}

// Delegate Methods
extension ViewController {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Delete Rows
        if editingStyle == .delete {

            // Delete theManagedObject to remove from CoreData
            self.managedObjectContext.delete(self.theContacts[indexPath.row].theManagedObject)
            self.theContacts.remove(at: indexPath.row)
            
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalError("Failure to save PersonEntity to CoreData: \(error)")
            }
         }
    }
    
    // Prepare to go to the next View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let theNextVC = segue.destination as! EditViewController
        theNextVC.objectToSave = self
        
        if segue.identifier == "EditSegue" {
            if let indexPath = self.tableView.indexPathsForSelectedRows?[0] {
                
                // Check if user is currently searching
                if searchController.isActive && searchController.searchBar.text != "" {
                    theNextVC.theContact = self.theFilteredContacts[indexPath.row]
                    theNextVC.indexOfContact = indexPath.row
                }
                else {
                    theNextVC.theContact = self.theContacts[indexPath.row]
                    theNextVC.indexOfContact = indexPath.row
                }
            }
        }
        searchController.isActive = false
    }
}

// Event Handlers
extension ViewController {
    func nameTextFieldDidChange(_ textField: UITextField) {
        // Gain Access to UIAlertController and it's properties
        let theController = presentedViewController as? UIAlertController
        
        // Check if Name is Valid
        self.NAME_IS_VALID = (textField.text?.characters.count)! >= 3
        
        // Disable or Enable Add Button
        theController?.actions.last?.isEnabled = self.NAME_IS_VALID && PHONE_IS_VALID
    }
    
    func phoneTextFieldDidChange(_ textField: UITextField) {
        // Gain Access to UIAlertController and it's properties
        let theController = presentedViewController as? UIAlertController
        
        // Check if Phone is Valid
        let theLength = textField.text?.characters.count
        self.PHONE_IS_VALID = theLength! >= 10 && theLength! <= 14
        
        // Disable or Enable Add Button
        theController?.actions.last?.isEnabled = self.NAME_IS_VALID && self.PHONE_IS_VALID
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
