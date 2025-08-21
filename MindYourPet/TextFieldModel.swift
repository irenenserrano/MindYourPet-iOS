//
//  ExtractedView.swift
//  MindYourPet
//
//  Created by Irene Serrano on 8/20/25.
//

import SwiftUICore
import SwiftUI

struct TextFieldModel: View {
    var titleKey: String
    @State var fillingText: String
    var body: some View {
        TextField(titleKey, text: $fillingText)
            .frame(height: 50)
            .background(Color.pink.brightness(0.7))
            .padding(.horizontal, 10)
    }
}
