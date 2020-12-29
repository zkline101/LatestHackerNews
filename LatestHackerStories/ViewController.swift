//
//  ViewController.swift
//  LatestHackerStories
//
//  Created by Zachary Kline on 12/29/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    let api = API()
    var subscriptions = [AnyCancellable]()
    var stories = [Story]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startIndicator()
        loadStories()
    }
    
    @IBAction func refreshPressed() {
        emptyTableView()
        startIndicator()
        loadStories()
    }
    
    private func loadStories() {
        api.stories()
            .sink(receiveCompletion: { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.stopIndicator()
                }
            },
            receiveValue: { [weak self] stories in
                guard let self = self else { return }
                self.stories = stories
            })
            .store(in: &subscriptions)
    }
    
    private func startIndicator() {
        indicator.startAnimating()
    }
    
    private func stopIndicator() {
        indicator.stopAnimating()
    }
    
    private func emptyTableView() {
        stories.removeAll()
        tableView.reloadData()
    }
    
    private func openURL(url: String) {
        guard let url = URL(string: url) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.textColor = .blue
        cell.textLabel?.text = stories[indexPath.section].title
        cell.detailTextLabel?.text = "By: \(stories[indexPath.section].by)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openURL(url: stories[indexPath.section].url)
    }
}
