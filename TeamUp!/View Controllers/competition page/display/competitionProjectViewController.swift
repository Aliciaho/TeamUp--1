//
//  competitionProjectViewController.swift
//  TeamUp!
//
//  Created by apple on 7/21/20.
//  Copyright © 2020 Alicia Ho. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class competitionProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var moduleArray = [String]()
    var documentID = ""
     
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
         
         super.viewDidLoad()
         self.table.delegate = self
         self.table.dataSource = self
         
         //loadData()
         //checkForUpdates()
         loadProject()
         alterLayout()
         
        // _tableView.estimatedRowHeight = 100
      //   _tableView.rowHeight = UITableView.automaticDimension
         
      //   _tableView.allowsMultipleSelectionDuringEditing = true
         
     }
        
     func loadProject() {
         let db = Firestore.firestore()
         var CURRENT_USER_UID: String? {
             if let currentUserUid = Auth.auth().currentUser?.uid {
                 return currentUserUid
             }
             return nil
         }
         //check whether the modules is alrdy there
         db.collection("users").whereField("uid", isEqualTo: CURRENT_USER_UID!).getDocuments() { (querySnapshot, error) in
             self.moduleArray.removeAll()
              if let error = error {
                  print("Error getting documents: \(error.localizedDescription)")
              } else {
                  for i in querySnapshot!.documents {
                     let id = i.documentID
                     self.documentID = id
                     //get the project approved
                     let docRef = db.collection("users").document(self.documentID).collection("competition")
                     
                     docRef.getDocuments() { (document, error) in
                         if let error = error {
                             print("Error getting documents: \(error.localizedDescription)")
                         } else {
                             for i in document!.documents {
                                 let name = i.get("name") as! String
                                 self.moduleArray.append(name)
                                 print("done snapshot, \(name)")
                                 print("print \(self.moduleArray)")
                                 self.table.reloadData()
                             }
                         }
                     }
                  }
             }
             //print("print \(self.moduleArray)")
             //self.table.reloadData()
         }
     }
     
     func alterLayout() {
         table.tableHeaderView = UIView()
         table.estimatedSectionHeaderHeight = 100
     }
     
     func checkForUpdates() {
         let db = Firestore.firestore()
         let docRef = db.collection("users").document(self.documentID).collection("competition")
                             
         docRef.addSnapshotListener(includeMetadataChanges: true) {
                 querySnapshot, error in
                     guard let snapshot = querySnapshot else {
                         print("error fetching snapshots: \(error!)")
                         return
                 }
                 snapshot.documentChanges.forEach { diff in
                     if (diff.type == .added) {
                         let data = diff.document.data()
                         let code = data["name"] as? String ?? ""
                         self.moduleArray.append(code)
                                         DispatchQueue.main.async {
                                             self.table.reloadData()
                         }
                     }
                 }
             }
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return moduleArray.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "competitionCell") as? competitionCell else {
            print("here")
            return UITableViewCell()
        }
         cell.nameLbl.text = moduleArray[indexPath.row]
         cell.backgroundColor = UIColor.getRandomColor(index:indexPath.row)
         //print("here is for the cell, \(cell.nameLbl.text)")
         return cell
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 50
     }
     
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     
         if (editingStyle == UITableViewCell.EditingStyle.delete) {
         // 2. Now Delete the Child from the database
             let name = moduleArray[indexPath.row]
             let db = Firestore.firestore()
             let query: Query = db.collection("users").document(self.documentID).collection("competition").whereField("name", isEqualTo: name)
             query.getDocuments(completion: { (snapshot, error) in
                 if let error = error {
                     print(error.localizedDescription)
                 } else {
                     for document in snapshot!.documents {
                         //print("\(document.documentID) => \(document.data())")
                         db.collection("users").document(self.documentID).collection("competition").document("\(document.documentID)").delete()}}})

             moduleArray.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .fade)
         }
     }
}
