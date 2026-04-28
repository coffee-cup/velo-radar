//
//  ContentView.swift
//  wherebixi
//
//  Created by Jake Runzer on 4/27/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StationFinderViewModel()

    var body: some View {
        Group {
            if viewModel.selectedMode == nil {
                ModePickerView { mode in
                    viewModel.selectMode(mode)
                }
            } else {
                StationFinderView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
