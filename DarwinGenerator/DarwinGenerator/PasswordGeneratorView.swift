//
//  PasswordGeneratorView.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import SwiftUI

struct PasswordGeneratorView: View {
    
    @ObservedObject var viewModel: PasswordGeneratorViewModel
        
    @State var selectedIndex: Int?
    
    var body: some View {
        ZStack {
            
            // Background
            Color(hex: 0x4D455D)
                .ignoresSafeArea()
                        
            VStack(alignment: .center) {
                
                Spacer()
                    .frame(height: 300)
                
                if case .loaded(_) = viewModel.state {
                    Toggle("Contains Numbers", isOn: $viewModel.isNumberAllowed)
                        .opacity(viewModel.selectedCharacterText == nil ? 1 : 0)
                        .foregroundColor(.white)
                    
                    Toggle("Contains Symbols", isOn: $viewModel.isSymbolAllowed)
                        .opacity(viewModel.selectedCharacterText == nil ? 1 : 0)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Password Length: \(Int(viewModel.characterCount))")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    Slider(value: $viewModel.characterCount, in: 2...7, step: 1) {
                        Text("Password Length")
                    } minimumValueLabel: {
                        Text("2").font(.title2)
                    } maximumValueLabel: {
                        Text("7").font(.title2)
                    }
                    .foregroundColor(.white)
                    .tint(Color(hex: 0xE96479))
                    .opacity(viewModel.selectedCharacterText == nil ? 1 : 0)
                }
            }
            .sheet(item: $viewModel.selectedCharacterText, content: { text in
                Text(text)
                    .font(.title2)
                    .fixedSize(horizontal: false, vertical: true)
                    .presentationDetents([.medium, .large])
                    .padding(.horizontal)
            })
            .padding()
            .task {
                await viewModel.fetchNetwork()
            }
            
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: 0xE96479)))
                    .scaleEffect(3)
            case .loaded(let data):
                HStack {
                    ForEach(data.indices, id: \.self) { index in
                        let text = data[index]
                        let isSelected = viewModel.selectedCharacterText != nil
                        let isHidden = isSelected ? (viewModel.selectedCharacterIndex != index) : false
                        PasswordCharacterItem(data: text,
                                              isSelected: isSelected,
                                              isHidden:  isHidden) {
                            viewModel.selectedCharacter(text: text, at: index)
                        }
                    }
                }
                .offset(y: viewModel.selectedCharacterText == nil ? 0 : -100)
                .scaleEffect(viewModel.selectedCharacterText == nil ? 1 : 1.07)
                .animation(Animation.easeInOut(duration: 0.2), value: viewModel.selectedCharacterText)
                
                VStack {
                    Spacer()
                    
                    Button("Generate") {
                        Task {
                            await viewModel.fetchNetwork()
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(hex: 0xE96479))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                
            case .error(let error):
                // TODO: Move color into another place
                Text(error.localizedDescription)
                    .foregroundColor(.red)
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

// TODO: Remove this
extension AttributedString: Identifiable {
    public var id: String {
        return self.characters.map { String($0) }.reduce("",+)
    }
}
