//
//  ViewController.swift
//  NameOrigin
//
//  Created by Bekpayev Dias on 10.08.2023.
//

import UIKit
import SnapKit

struct Welcome: Codable {
    let count: Int
    let name: String
    let country: [Country]
}

struct Country: Codable {
    let countryID: String
    let probability: Double
    
    enum CodingKeys: String, CodingKey {
        case countryID = "country_id"
        case probability
    }
}

class ViewController: UIViewController {
    var countries: [Country] = []
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("Predict nationality", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.configuration = .filled()
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "enter the name"
        textField.font = .systemFont(ofSize: 40)
        textField.textAlignment = .center
        return textField
    }()
    
    @objc func buttonTapped() {
          guard let name = textField.text else { return }
          guard let url = URL(string: "https://api.nationalize.io/?name=\(name)") else { return }
          let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
              if let data = data {
                  let decoder = JSONDecoder()
                  if let decodedData = try? decoder.decode(Welcome.self, from: data) {
                      self.countries = decodedData.country.sorted(by: { $0.probability > $1.probability })
                      DispatchQueue.main.async {
                          self.tableView.reloadData()
                      }
                  }
              }
          }
          task.resume()
      }
    
    func flag(from country:String) -> String {
            let base : UInt32 = 127397
            var s = ""
            for v in country.uppercased().unicodeScalars {
                s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
            }
            return s
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        view.addSubview(tableView)
        view.addSubview(textField)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        
        textField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.left.right.equalToSuperview().inset(25)
        }
        
        button.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(100)
            $0.left.right.equalToSuperview().inset(25)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(button.snp.bottom).offset(50)
            $0.left.right.bottom.equalToSuperview().inset(25)
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let country = countries[indexPath.row]
        let flagEmoji = flag(from: country.countryID)
        cell.textLabel?.text = "\(flagEmoji) \(country.countryID) - \(String(format: "%.1f", country.probability * 100))%"
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .systemPurple
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 31)
        return cell
    }
}






