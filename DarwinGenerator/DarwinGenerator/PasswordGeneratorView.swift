//
//  PasswordGeneratorView.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import SwiftUI

struct PasswordGeneratorView: View {
    
    @ObservedObject var viewModel: PasswordGeneratorViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .loaded(let data):
                Text(data)
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
