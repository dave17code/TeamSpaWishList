//
//  ViewController.swift
//  TeamSpaWishList
//
//  Created by woonKim on 2024/01/06.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    // currentProduct가 set되면, imageView, titleLabel, descriptionLabel, priceLabel에 각각 적절한 값을 지정합니다.
    private var currentProduct: RemoteProduct? = nil {
        didSet {
            guard let currentProduct = self.currentProduct else { return }
            DispatchQueue.main.async {
                self.imageView.image = nil
                self.titleLabel.text = currentProduct.title
                self.descriptionLabel.text = currentProduct.description
                self.priceLabel.text = "\(currentProduct.price)$"
            }
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: currentProduct.thumbnail), let image = UIImage(data: data) {
                    DispatchQueue.main.async { self?.imageView.image = image }
                }
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRemoteProduct()
    }
    
    // URLSession을 통해 RemoteProduct를 가져와 currentProduct 변수에 저장
    private func fetchRemoteProduct() {
        let productID = Int.random(in: 1...100)
        if let url = URL(string: "https://dummyjson.com/products/\(productID)") {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        // product를 디코드하여, currentProduct 변수에 담음
                        let product = try JSONDecoder().decode(RemoteProduct.self, from: data)
                        self.currentProduct = product
                    } catch {
                        print("Decode Error: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
    
    private func saveWishProduct() {
        guard let context = self.persistentContainer?.viewContext else { return }
        guard let currentProduct = self.currentProduct else { return }
        let wishProduct = Product(context: context)
        wishProduct.id = Int64(currentProduct.id)
        wishProduct.title = currentProduct.title
        wishProduct.price = currentProduct.price
        try? context.save()
    }
    
    @IBAction func tappedSaveProductButton(_ sender: Any) {
        // Core Data에 상품을 저장하는 함수 호출
        saveWishProduct()
    }
    
    @IBAction func tappedSkipButton(_ sender: Any) {
        // 새로운 상품을 불러오는 함수 호출
        fetchRemoteProduct()
    }
    
    @IBAction func tappedPresentWishList(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "WishListViewController") as? WishListViewController else { return }
        present(nextVC, animated: true)
    }
}
