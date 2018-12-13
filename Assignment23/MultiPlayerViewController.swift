/*
 Made by Navpreet Kaur
 This class contains all the code for connecting to the remote database. After the connection is established the stores are fetched and displayed inside a table view
 */
import UIKit

struct Player: Decodable {
    
    let PlayerName : String
    let PlayerScore : String }


class MultiPlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var jsonData = [String: Any]()
    var player = [Player]()
    var PlayerName = [String]()
    var PlayerScore = [String]()
    
    @IBOutlet weak var tableData: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableData.dataSource = self
        tableData.delegate = self
        getJSONData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var dbData : [NSDictionary]?
    let myUrl = "https://kaur1973.dev.fast.sheridanc.on.ca/iOS_Assign/sqlToJson.php" as String
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    //This method establishes connection with the remote database afters the data is stored in the dictionary/struct object
    func getJSONData() {
        let jsonURL = "https://kaur1973.dev.fast.sheridanc.on.ca/iOS_Assign/sqlToJson.php"
        let url = URL(string: jsonURL)
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            do {
                self.player = try JSONDecoder().decode([Player].self, from: data!)
                
                for info in self.player {
                    
                    self.PlayerName.append(info.PlayerName)
                    self.PlayerScore.append(info.PlayerScore)
                    
                    DispatchQueue.main.async {
                        self.tableData.reloadData()
                    }
                }
            }
                
            catch {
                print("Error is : \n\(error)")
            }
            }.resume()
        
    }
    //method returns number of rows inside the table depending on how many values are in the dictionary
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.PlayerScore.count
    }
    //This method renders the values on the tableview
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = PlayerName[indexPath.row] + "      " + PlayerScore[indexPath.row]
        return cell
        
    }
}

