//
//  ContentView.swift
//  CDDataStackDemo
//
//  Created by Sean Erickson on 3/3/24.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel: ViewModel = ViewModel(position: nil)
    var body: some View {
        VStack {
            Text("User Position: \(viewModel.position.x), \(viewModel.position.y)")
                .padding()
            Button {
                viewModel.position.y += 1
            } label: {
                Image(systemName: "chevron.up")
                    .imageScale(.large)
            }
            HStack {
                Button {
                    viewModel.position.x -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .padding()
                }
                Button {
                    viewModel.position.x += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                        .padding()
                }
            }
            Button {
                viewModel.position.y -= 1
            } label: {
                Image(systemName: "chevron.down")
                    .imageScale(.large)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
