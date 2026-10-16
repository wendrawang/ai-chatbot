//
//  Composer.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI

struct Composer: View
{
    @State private var text: String = InitialValues.emptyText
    let copy: FeatureCopy
    let onSend: (String) -> Void
    var body: some View
    {
        MessageComposer(text: $text, placeholder: copy.placeholder, sendLabel: copy.send)
        {
            let message = text
            text = InitialValues.emptyText
            onSend(message)
        }

        .padding(FigmaSize.spacingLarge)
        .background(CustomColors.background)
    }
}
