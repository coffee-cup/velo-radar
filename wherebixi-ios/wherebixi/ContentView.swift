//
//  ContentView.swift
//  wherebixi
//
//  Created by Jake Runzer on 4/27/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StationFinderViewModel()
    @State private var navigationPath: [SearchMode] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ModePickerView { mode in
                viewModel.selectMode(mode)
                navigationPath = [mode]
            }
            .navigationDestination(for: SearchMode.self) { mode in
                StationFinderView(viewModel: viewModel)
                    .navigationTitle(mode.title)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onChange(of: navigationPath) { _, newPath in
            if newPath.isEmpty {
                viewModel.returnToModePicker()
            }
        }
        .tint(AppTheme.Colors.electricBike)
    }
}

#Preview {
    ContentView()
}
