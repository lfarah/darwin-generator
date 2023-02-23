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
            Color.backgroundPurple
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
                    .opacity(viewModel.selectedCharacterText == nil ? 1 : 0)

                    
                    Slider(value: $viewModel.characterCount, in: viewModel.characterCountRange, step: 1) {
                        Text("Password Length")
                    } minimumValueLabel: {
                        Text(viewModel.minimumValueText).font(.title2)
                    } maximumValueLabel: {
                        Text(viewModel.maximumValueText).font(.title2)
                    }
                    .foregroundColor(.white)
                    .tint(Color.tintRed)
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
            
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.tintRed))
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
                            await viewModel.reloadData()
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.tintRed)
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
        // If I had more time, I'd create a mocked service for this viewModel to use so we can have previews without calling the internet
        let viewModel = PasswordGeneratorViewModel()
        return PasswordGeneratorView(viewModel: viewModel)
    }
}
