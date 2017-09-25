//
//  FilterViewController.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/21/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    @objc optional func filterViewController (filterViewController: FilterViewController,
                                        didUpDateFilters filters: [String: AnyObject])
}

class FilterViewController: UIViewController {
    @IBOutlet weak var filtersTableView: UITableView!
    
    let yelpSortModesMap = [YelpSortMode.distance.rawValue : "Distance",
        YelpSortMode.bestMatched.rawValue : "Best Matched",
        YelpSortMode.highestRated.rawValue : "Highest Rated"]
    
    // Keep an array version to maintain order
    let yelpSortModes: [(key: Int, value: String)] = [
        (key: YelpSortMode.bestMatched.rawValue, value: "Best Matched"),
        (key: YelpSortMode.highestRated.rawValue, value: "Highest Rated"),
        (key: YelpSortMode.distance.rawValue, value: "Distance")
    ]
    
    let distanceFiltersMap: [Int: String] = [ 0: "Auto",
                            804: ".5 miles",
                            1609: "1 mile",
                            8046: "5 miles",
                            32186: "20 miles"
    ]
    
    
    // Keep an array version to maintain order
    let distanceFilters: [(key: Int, value: String)] = [
        (key: 0, value: "Auto"),
        (key: 804, value: ".5 miles"),
        (key: 1609, value: "1 mile"),
        (key: 8046, value: "5 miles"),
        (key: 32186, value: "20 miles")
    ]
    
    var categories: [Dictionary<String, String>]!
    var categoryStates : [String:Bool] = [String:Bool]()
    weak var delegate : FilterViewControllerDelegate?
    var dealState: Bool = false
    var showSortMode: Bool = false
    var showDistance: Bool = false
    var selectedDistance: Int = 0
    var selectedSortMode: Int = YelpSortMode.bestMatched.rawValue
    var showAllCategories: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = makeCategories()

        filtersTableView.estimatedRowHeight = 100
        filtersTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onReset(_ sender: Any) {
        parepare(filters: [String : AnyObject]())
        filtersTableView.reloadData()
    }
    
    @IBAction func onSearch(_ sender: Any) {
        var filters = [String : AnyObject]()
        var selectedCategories : [String] = [String]()
        
        for (code, isSelected) in categoryStates {
            if isSelected  {
                print("Adding \(code)")
                selectedCategories.append(code)
            }
        }
        
        filters["categories"] = selectedCategories as AnyObject
        filters["deal"] = dealState as AnyObject
        
        if selectedDistance > 0 {
            filters["distance"] = selectedDistance as AnyObject
        }
        
        if selectedSortMode != YelpSortMode.bestMatched.rawValue {
            filters["sortMode"] = YelpSortMode(rawValue: selectedSortMode) as AnyObject
        }

        delegate?.filterViewController?(filterViewController: self, didUpDateFilters: filters)
        
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func parepare(filters: [String : AnyObject]) -> Void {
        print("Preparing filters \(filters)")

        // first revert to default
        categoryStates.removeAll()
        dealState = false
        selectedDistance = 0
        selectedSortMode = 0

        if let selectedCategories = filters["categories"] as? [String] {
            for selectedCategory in selectedCategories {
                categoryStates[selectedCategory] = true
                print("Select \(selectedCategory)")
            }
        }
        
        if let deal = filters["deal"] as? Bool {
            dealState = deal
            print("Deal \(deal)")

        }
        
        if let distance = filters["distance"] as? Int {
            selectedDistance = distance
            print("Distance \(distance)")
        }
        
        if let sort = filters["sortMode"] as? YelpSortMode {
            selectedSortMode = sort.rawValue
            print("Sort Mode \(sort)")
        }

    }
}

// MARK:- TableView
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    enum filterSection: Int {
        case deal = 0,
        distance,
        sortMode,
        category
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case filterSection.deal.rawValue:
            return 1
        case filterSection.sortMode.rawValue:
            if showSortMode {
                return yelpSortModes.count
            }
            return 1
        case filterSection.distance.rawValue:
            if showDistance {
                return distanceFilters.count
            } else {
                return 1
            }
        case filterSection.category.rawValue:
            if showAllCategories {
                return categories.count
            } else {
                return 8
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1, 2, 3:
            return 40
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func makeDistanceCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let distanceCell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
        
        var row: (key: Int, value: String)?
        
        if showDistance {
            row = distanceFilters[indexPath.row]
            distanceCell.prepare(selectionLabel: (row?.value)!, isSelected: row?.key == selectedDistance)
        } else {
            // Menu is collapsed, show only selected element
            distanceCell.prepare(selectionLabel: distanceFiltersMap[selectedDistance]!, isSelected: true)
        }
        return distanceCell
    }
    
    func makeSortModeCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let sortModeCell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
        
        var row: (key: Int, value: String)?
        
        if showSortMode {
            row = yelpSortModes[indexPath.row]
            sortModeCell.prepare(selectionLabel: (row?.value)!, isSelected: row?.key == selectedDistance)
        } else {
            // Menu is collapsed, show only selected element
            sortModeCell.prepare(selectionLabel: yelpSortModesMap[selectedSortMode]!, isSelected: true)
        }
        return sortModeCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case filterSection.deal.rawValue:
            let dealCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            dealCell.prepare(with: "Offering a Deal")
            dealCell.switchHandler = { (isOn)  in
                self.dealState = isOn
            }
            dealCell.switchToggle.isOn = dealState
            return dealCell
            
        case filterSection.distance.rawValue:
            return makeDistanceCell(tableView: tableView, indexPath: indexPath)
            
        case filterSection.sortMode.rawValue:
            return makeSortModeCell(tableView: tableView, indexPath: indexPath)
            
        case filterSection.category.rawValue:
            if !showAllCategories && indexPath.row == 7 {
                let showAllCell = tableView.dequeueReusableCell(withIdentifier: "ShowAllCell", for: indexPath)
                return showAllCell
            }
            
            let categoryCell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            let code : String! = categories[indexPath.row]["code"]
            categoryCell.prepare(with: categories[indexPath.row]["name"]!)
            categoryCell.switchHandler = { (isOn)  in
                self.categoryStates[code] = isOn
            }
            
            categoryCell.switchToggle.isOn = self.categoryStates[code] ?? false
            
            return categoryCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case filterSection.distance.rawValue:
            if showDistance {
                self.selectedDistance = distanceFilters[indexPath.row].key
                print ("Selected distance \(distanceFilters[indexPath.row].value)")
            }
            self.showDistance = !self.showDistance
            tableView.reloadData()
            break
        case filterSection.sortMode.rawValue:
            if showSortMode {
                self.selectedSortMode = yelpSortModes[indexPath.row].key
                print ("Selected sort mode \(yelpSortModes[indexPath.row].value)")
            }
            self.showSortMode = !self.showSortMode
            tableView.reloadData()
            break;
        case filterSection.category.rawValue:
            if !showAllCategories && indexPath.row == 7 {
                showAllCategories = !showAllCategories
                tableView.reloadData()
            }
            break;
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            let distanceHeader = UITableViewHeaderFooterView()
            distanceHeader.textLabel?.text = "Distance"
            return distanceHeader
        case 2:
            let distanceHeader = UITableViewHeaderFooterView()
            distanceHeader.textLabel?.text = "Sort By"
            return distanceHeader
        case 3:
            let categoryHeader = UITableViewHeaderFooterView()
            categoryHeader.textLabel?.text = "Categories"
            return categoryHeader
        default:
            return UITableViewHeaderFooterView()
        }
    }
    
}

extension FilterViewController {
    func makeCategories() -> [Dictionary<String, String>] {
    return [["name" : "Afghan", "code": "afghani"],
    ["name" : "African", "code": "african"],
    ["name" : "American, New", "code": "newamerican"],
    ["name" : "American, Traditional", "code": "tradamerican"],
    ["name" : "Arabian", "code": "arabian"],
    ["name" : "Argentine", "code": "argentine"],
    ["name" : "Armenian", "code": "armenian"],
    ["name" : "Asian Fusion", "code": "asianfusion"],
    ["name" : "Asturian", "code": "asturian"],
    ["name" : "Australian", "code": "australian"],
    ["name" : "Austrian", "code": "austrian"],
    ["name" : "Baguettes", "code": "baguettes"],
    ["name" : "Bangladeshi", "code": "bangladeshi"],
    ["name" : "Barbeque", "code": "bbq"],
    ["name" : "Basque", "code": "basque"],
    ["name" : "Bavarian", "code": "bavarian"],
    ["name" : "Beer Garden", "code": "beergarden"],
    ["name" : "Beer Hall", "code": "beerhall"],
    ["name" : "Beisl", "code": "beisl"],
    ["name" : "Belgian", "code": "belgian"],
    ["name" : "Bistros", "code": "bistros"],
    ["name" : "Black Sea", "code": "blacksea"],
    ["name" : "Brasseries", "code": "brasseries"],
    ["name" : "Brazilian", "code": "brazilian"],
    ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
    ["name" : "British", "code": "british"],
    ["name" : "Buffets", "code": "buffets"],
    ["name" : "Bulgarian", "code": "bulgarian"],
    ["name" : "Burgers", "code": "burgers"],
    ["name" : "Burmese", "code": "burmese"],
    ["name" : "Cafes", "code": "cafes"],
    ["name" : "Cafeteria", "code": "cafeteria"],
    ["name" : "Cajun/Creole", "code": "cajun"],
    ["name" : "Cambodian", "code": "cambodian"],
    ["name" : "Canadian", "code": "New)"],
    ["name" : "Canteen", "code": "canteen"],
    ["name" : "Caribbean", "code": "caribbean"],
    ["name" : "Catalan", "code": "catalan"],
    ["name" : "Chech", "code": "chech"],
    ["name" : "Cheesesteaks", "code": "cheesesteaks"],
    ["name" : "Chicken Shop", "code": "chickenshop"],
    ["name" : "Chicken Wings", "code": "chicken_wings"],
    ["name" : "Chilean", "code": "chilean"],
    ["name" : "Chinese", "code": "chinese"],
    ["name" : "Comfort Food", "code": "comfortfood"],
    ["name" : "Corsican", "code": "corsican"],
    ["name" : "Creperies", "code": "creperies"],
    ["name" : "Cuban", "code": "cuban"],
    ["name" : "Curry Sausage", "code": "currysausage"],
    ["name" : "Cypriot", "code": "cypriot"],
    ["name" : "Czech", "code": "czech"],
    ["name" : "Czech/Slovakian", "code": "czechslovakian"],
    ["name" : "Danish", "code": "danish"],
    ["name" : "Delis", "code": "delis"],
    ["name" : "Diners", "code": "diners"],
    ["name" : "Dumplings", "code": "dumplings"],
    ["name" : "Eastern European", "code": "eastern_european"],
    ["name" : "Ethiopian", "code": "ethiopian"],
    ["name" : "Fast Food", "code": "hotdogs"],
    ["name" : "Filipino", "code": "filipino"],
    ["name" : "Fish & Chips", "code": "fishnchips"],
    ["name" : "Fondue", "code": "fondue"],
    ["name" : "Food Court", "code": "food_court"],
    ["name" : "Food Stands", "code": "foodstands"],
    ["name" : "French", "code": "french"],
    ["name" : "French Southwest", "code": "sud_ouest"],
    ["name" : "Galician", "code": "galician"],
    ["name" : "Gastropubs", "code": "gastropubs"],
    ["name" : "Georgian", "code": "georgian"],
    ["name" : "German", "code": "german"],
    ["name" : "Giblets", "code": "giblets"],
    ["name" : "Gluten-Free", "code": "gluten_free"],
    ["name" : "Greek", "code": "greek"],
    ["name" : "Halal", "code": "halal"],
    ["name" : "Hawaiian", "code": "hawaiian"],
    ["name" : "Heuriger", "code": "heuriger"],
    ["name" : "Himalayan/Nepalese", "code": "himalayan"],
    ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
    ["name" : "Hot Dogs", "code": "hotdog"],
    ["name" : "Hot Pot", "code": "hotpot"],
    ["name" : "Hungarian", "code": "hungarian"],
    ["name" : "Iberian", "code": "iberian"],
    ["name" : "Indian", "code": "indpak"],
    ["name" : "Indonesian", "code": "indonesian"],
    ["name" : "International", "code": "international"],
    ["name" : "Irish", "code": "irish"],
    ["name" : "Island Pub", "code": "island_pub"],
    ["name" : "Israeli", "code": "israeli"],
    ["name" : "Italian", "code": "italian"],
    ["name" : "Japanese", "code": "japanese"],
    ["name" : "Jewish", "code": "jewish"],
    ["name" : "Kebab", "code": "kebab"],
    ["name" : "Korean", "code": "korean"],
    ["name" : "Kosher", "code": "kosher"],
    ["name" : "Kurdish", "code": "kurdish"],
    ["name" : "Laos", "code": "laos"],
    ["name" : "Laotian", "code": "laotian"],
    ["name" : "Latin American", "code": "latin"],
    ["name" : "Live/Raw Food", "code": "raw_food"],
    ["name" : "Lyonnais", "code": "lyonnais"],
    ["name" : "Malaysian", "code": "malaysian"],
    ["name" : "Meatballs", "code": "meatballs"],
    ["name" : "Mediterranean", "code": "mediterranean"],
    ["name" : "Mexican", "code": "mexican"],
    ["name" : "Middle Eastern", "code": "mideastern"],
    ["name" : "Milk Bars", "code": "milkbars"],
    ["name" : "Modern Australian", "code": "modern_australian"],
    ["name" : "Modern European", "code": "modern_european"],
    ["name" : "Mongolian", "code": "mongolian"],
    ["name" : "Moroccan", "code": "moroccan"],
    ["name" : "New Zealand", "code": "newzealand"],
    ["name" : "Night Food", "code": "nightfood"],
    ["name" : "Norcinerie", "code": "norcinerie"],
    ["name" : "Open Sandwiches", "code": "opensandwiches"],
    ["name" : "Oriental", "code": "oriental"],
    ["name" : "Pakistani", "code": "pakistani"],
    ["name" : "Parent Cafes", "code": "eltern_cafes"],
    ["name" : "Parma", "code": "parma"],
    ["name" : "Persian/Iranian", "code": "persian"],
    ["name" : "Peruvian", "code": "peruvian"],
    ["name" : "Pita", "code": "pita"],
    ["name" : "Pizza", "code": "pizza"],
    ["name" : "Polish", "code": "polish"],
    ["name" : "Portuguese", "code": "portuguese"],
    ["name" : "Potatoes", "code": "potatoes"],
    ["name" : "Poutineries", "code": "poutineries"],
    ["name" : "Pub Food", "code": "pubfood"],
    ["name" : "Rice", "code": "riceshop"],
    ["name" : "Romanian", "code": "romanian"],
    ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
    ["name" : "Rumanian", "code": "rumanian"],
    ["name" : "Russian", "code": "russian"],
    ["name" : "Salad", "code": "salad"],
    ["name" : "Sandwiches", "code": "sandwiches"],
    ["name" : "Scandinavian", "code": "scandinavian"],
    ["name" : "Scottish", "code": "scottish"],
    ["name" : "Seafood", "code": "seafood"],
    ["name" : "Serbo Croatian", "code": "serbocroatian"],
    ["name" : "Signature Cuisine", "code": "signature_cuisine"],
    ["name" : "Singaporean", "code": "singaporean"],
    ["name" : "Slovakian", "code": "slovakian"],
    ["name" : "Soul Food", "code": "soulfood"],
    ["name" : "Soup", "code": "soup"],
    ["name" : "Southern", "code": "southern"],
    ["name" : "Spanish", "code": "spanish"],
    ["name" : "Steakhouses", "code": "steak"],
    ["name" : "Sushi Bars", "code": "sushi"],
    ["name" : "Swabian", "code": "swabian"],
    ["name" : "Swedish", "code": "swedish"],
    ["name" : "Swiss Food", "code": "swissfood"],
    ["name" : "Tabernas", "code": "tabernas"],
    ["name" : "Taiwanese", "code": "taiwanese"],
    ["name" : "Tapas Bars", "code": "tapas"],
    ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
    ["name" : "Tex-Mex", "code": "tex-mex"],
    ["name" : "Thai", "code": "thai"],
    ["name" : "Traditional Norwegian", "code": "norwegian"],
    ["name" : "Traditional Swedish", "code": "traditional_swedish"],
    ["name" : "Trattorie", "code": "trattorie"],
    ["name" : "Turkish", "code": "turkish"],
    ["name" : "Ukrainian", "code": "ukrainian"],
    ["name" : "Uzbek", "code": "uzbek"],
    ["name" : "Vegan", "code": "vegan"],
    ["name" : "Vegetarian", "code": "vegetarian"],
    ["name" : "Venison", "code": "venison"],
    ["name" : "Vietnamese", "code": "vietnamese"],
    ["name" : "Wok", "code": "wok"],
    ["name" : "Wraps", "code": "wraps"],
    ["name" : "Yugoslav", "code": "yugoslav"]]
    }
}
