//
//  CoinLogoHeaderListCell.swift
//  CoinEscora
//
//  Created by Shwait Kumar on 27/01/23.
//

import UIKit
import Kingfisher

class CoinLogoHeaderListCell: UICollectionViewListCell {
    static let resuseIdentifier = "coin-logo-header-item-list-cell-identifier"
    
    let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    let dataStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()
    
    let coinSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    func setImage(with url: URL) {
        let resource = ImageResource(downloadURL: url)
        logo.kf.setImage(with: resource, placeholder: nil, options: [
            .transition(.fade(0.2)),
            .cacheOriginalImage
        ], progressBlock: nil) { (result) in
            switch result {
            case .success(_): break
                // Success case
            case .failure(_): break
                // Failed case
            }
        }
    }
    
    var symbol: String? {
        didSet {
            configure()
        }
    }
    
    var rank: Int? {
        didSet {
            configure()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CoinLogoHeaderListCell {
    func configure() {
        contentView.addSubview(stackView)
        
        dataStack.addArrangedSubview(coinSymbolLabel)
        dataStack.addArrangedSubview(rankLabel)
        
        stackView.addArrangedSubview(logo)
        stackView.addArrangedSubview(dataStack)
        
        coinSymbolLabel.text = symbol
        if let coinRank = rank {
            rankLabel.text = "Rank: \(coinRank)"
        }
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.widthAnchor.constraint(equalToConstant: 80),
            logo.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
