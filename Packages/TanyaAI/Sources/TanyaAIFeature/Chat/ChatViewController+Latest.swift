// Created by Wendra on 16/10/26.

import DesignKit
import UIKit

extension ChatViewController
{
    func configureLatestButton()
    {
        latestButton.translatesAutoresizingMaskIntoConstraints = false
        latestButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        latestButton.backgroundColor = UIColor(CustomColors.background)
        latestButton.tintColor = UIColor(CustomColors.accent)
        latestButton.layer.cornerRadius = CustomSizes.minimumTap / 2
        latestButton.addTarget(self, action: #selector(latestTapped), for: .touchUpInside)
        latestButton.isHidden = true
        view.addSubview(latestButton)
        NSLayoutConstraint.activate([
            latestButton.centerXAnchor.constraint(equalTo: table.centerXAnchor),
            latestButton.bottomAnchor.constraint(equalTo: table.bottomAnchor, constant: -FigmaSize.spacingMedium),
            latestButton.widthAnchor.constraint(equalToConstant: CustomSizes.minimumTap),
            latestButton.heightAnchor.constraint(equalToConstant: CustomSizes.minimumTap),
        ])
    }

    @objc private func latestTapped()
    {
        model.showLatest()
    }

    func resumeFollowingIfNearBottom()
    {
        isFollowingLatest = table.contentSize.height - table.contentOffset.y - table.bounds.height
            <= CustomSizes.nearBottomThreshold
        updateLatestButton()
    }

    func updateLatestButton()
    {
        latestButton.accessibilityLabel = FeatureCopy(language: model.state.language).latest
        latestButton.isHidden = isFollowingLatest || table.contentSize.height - table.contentOffset.y
            <= table.bounds.height + CustomSizes.nearBottomThreshold
    }
}
