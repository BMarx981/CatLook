//
//  CatCollectionViewController.swift
//  CatLook
//
//  Created by Marx, Brian on 5/31/18.
//  Copyright © 2018 Marx, Brian. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cellId"

class CatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var pageNum = 0
    var cats = [Cat]()
    var catImages = [UIImage?]()
    var dataTask: URLSessionDataTask?
    var urlString: String = "https://chex-triplebyte.herokuapp.com/api/cats?page=0"
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: urlString)
        fetchCatImages(url: url!)
        collectionView?.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cats.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CatCollectionViewCell

        cell.label1?.text = cats[indexPath.item].name
        cell.label2?.text = cats[indexPath.item].date
        cell.image?.image = cats[indexPath.item].image
        cell.descript?.text = cats[indexPath.item].description
        cell.backgroundColor = .gray
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    //MARK: UICollectionViewDelegateFlowlayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = CGFloat(view.frame.size.width) - 16
        let screenHeight = CGFloat(screenWidth * 1.5)
        return CGSize(width: screenWidth, height: screenHeight)
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
    
    //MARK: HandleRefresh
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        cats.removeAll()
        let comp = urlString.components(separatedBy: "page=")
        pageNum += 1
        let newString = "\(comp[0])page=\(pageNum)"
        fetchCatImages(url: URL(string: newString)!)
        collectionView?.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK: FetchCatImages
    func fetchCatImages(url: URL) {
        let urlSession = URLSession.shared
        dataTask?.cancel()
        dataTask = urlSession.dataTask(with: url) {
            data, response, error in
            if let error = error as NSError?, error.code == -999 {
                return
            } else if let data = data, let jsonResponse = self.parse(json: data){
                if let dataArray = jsonResponse as [[String: Any]]? {
                    
                    DispatchQueue.main.async {
                        for item in dataArray {
                            let cat = Cat()
                            if item["title"] is String {
                                cat.name = item["title"] as! String
                                print(cat.name)
                            }
                            if item["timestamp"] is String {
                                cat.date = item["timestamp"] as! String
                                print(cat.date)
                            }
                            if item["description"] is String {
                                cat.description = item["description"] as! String
                                print(cat.description)
                            }
                            if item["image_url"] is String {
                                cat.imageURL = item["image_url"] as! String
                                
                                let getImageFromURL = urlSession.dataTask(with: URL(string: cat.imageURL)!) {
                                    (data, response, error) in
                                    if let e = error {
                                        print("We got an error \(e)")
                                    } else {
                                        if response as? HTTPURLResponse != nil {
                                            if let imageData = data {
                                                let image = UIImage(data: imageData)
                                                cat.image = image!
                                                self.collectionView?.reloadData()
                                            }
                                        }
                                    }
                                }
                                getImageFromURL.resume()
                                
                            }
                            self.cats.append(cat)
                        }
                    }
                    self.collectionView?.reloadData()
                }
            }
        }
        dataTask?.resume()
        collectionView?.reloadData()
    }
    
    func parse(json data: Data) -> [[String : Any]]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        } catch {
            return nil
        }
    }
}
