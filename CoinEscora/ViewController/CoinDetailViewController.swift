//
//  CoinDetailViewController.swift
//  CoinEscora
//
//  Created by Shwait Kumar on 26/01/23.
//

import UIKit

class CoinDetailViewController: UIViewController {
    typealias Datasource = UICollectionViewDiffableDataSource<Int, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    
    private var collectionView: UICollectionView! = nil
    
    private var dataSource: Datasource!
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    public var coin: Coin?
    
    private var coinDetail: CoinDetail?
    
    struct Item: Hashable {
        let coinData: CoinDetail
        let assignedId: Int
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.assignedId == rhs.assignedId
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(assignedId)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(named: "Background")
        configureCollectionView()
        setupLoadingIndicator()
        configureDataSource()
        fetchCoinDetail()
    }

}

// MARK: - Call API
extension CoinDetailViewController {
    private func fetchCoinDetail() {
        loadingIndicator.startAnimating()
        SimpleNetworkHelper.shared.fetchCoinDetail(id: coin!.id, completion: { (coin) in
            if let coin = coin {
                self.coinDetail = coin
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.generateData(animated: true)
                }
            }
        })
    }
}

// MARK: - Setup CollectionView & Layout
extension CoinDetailViewController {
    private func setupLoadingIndicator() {
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubview(loadingIndicator)
        
        // Show loading indiactor at start in the middle
        NSLayoutConstraint.activate([
            layoutGuide.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            layoutGuide.centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor)
        ])
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.backgroundColor = .clear
        configuration.separatorConfiguration.color = UIColor(named: "Seperator") ?? .separator
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}

// MARK: - CollectionView Datasource
extension CoinDetailViewController {
    private func configureDataSource() {
        // list cell
        let headerCellRegistration = UICollectionView.CellRegistration<CoinLogoHeaderListCell, CoinDetail> { (cell, indexPath, coin) in
            if let coinLogo = coin.logo {
                cell.setImage(with: coinLogo)
            }
            cell.rank = coin.rank
            cell.symbol = coin.symbol
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, CoinDetail> { (cell, indexPath, coin) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            if coin.description != nil {
                contentConfiguration.secondaryText = coin.description == "" ? coin.links?.website?[0].absoluteString : coin.description
            }
            
            cell.contentConfiguration = contentConfiguration
        }
        
        // data source
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) {
            (collectionView, indexPath, coin) -> UICollectionViewCell? in
            if indexPath.section == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: coin.coinData)
            }
            else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: coin.coinData)
            }
        }
    }
    
    private func generateData(animated: Bool) {
        var snapshot = Snapshot()
        
        if let coinModel = self.coinDetail {
            snapshot.appendSections([0])
            let item = Item(coinData: coinModel, assignedId: 0)
            snapshot.appendItems([item])
            
            if coinModel.description != "" {
                snapshot.appendSections([1])
                let item = Item(coinData: coinModel, assignedId: 1)
                snapshot.appendItems([item])
            }
            else {
                if coinModel.links?.website != [] {
                    snapshot.appendSections([1])
                    let item = Item(coinData: coinModel, assignedId: 1)
                    snapshot.appendItems([item])
                }
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - CollectionView Delegate
extension CoinDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print(indexPath.section, indexPath.item)
    }
}
