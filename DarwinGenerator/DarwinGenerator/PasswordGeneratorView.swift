//
//  PasswordGeneratorView.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import SwiftUI

struct PasswordGeneratorView: View {
    
    @ObservedObject var viewModel: PasswordGeneratorViewModel
    
    @State var isNumberAllowed = false
    @State var isSymbolAllowed = false
    
    @State var selectedIndex: Int?
    
    var body: some View {
        ZStack {
            
            // Background
            Color(hex: 0x4D455D)
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                
                switch viewModel.state {
                case .loading:
                    ProgressView()
                case .loaded(let data):
                    
                    if let text = viewModel.selectedCharacterText {
                        Text(text)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack {
                        ForEach(data) { text in
                            Button(text.value) {
                                viewModel.selectedCharacter(text: text)
                            }
                            .foregroundColor(Color(hex: 0xE96479))
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .minimumScaleFactor(0.01)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.black, lineWidth: 5)
                            )
                            .background(Color(hex: 0xF5E9CF))
                            .cornerRadius(8)
                        }
                    }
                    
                    HStack {
                        Button("Contains Numbers") {
                            print("ContainsNumbersPressed")
                            isNumberAllowed.toggle()
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(hex: isNumberAllowed ? 0x7DB9B6 : 0xF5E9CF))
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Button("Contains Symbols") {
                            print("ContainsNumbersPressed")
                            isSymbolAllowed.toggle()
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(hex: isSymbolAllowed ? 0x7DB9B6 : 0xF5E9CF))
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    
                    Button("Generate") {
                        Task {
                            await viewModel.fetchNetwork()
                        }
                    }
                    
                case .error(let error):
                    // TODO: Move color into another place
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .task {
                await viewModel.fetchNetwork()
            }
        }
    }
    
    init(viewModel: PasswordGeneratorViewModel) {
        self.viewModel = viewModel
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Mocked viewModel, without calling the internet for information
        let viewModel = PasswordGeneratorViewModel()
        return PasswordGeneratorView(viewModel: viewModel)
    }
}

// TODO: Remove this
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
