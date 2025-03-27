//
//  CurrencySearchView.swift
//  ExchangeAppForYou
//
//  Created by andy on 3/26/25.
//

import SwiftUI

struct CurrencySearchView: View {
    @StateObject var viewModel: CurrencySearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.items, id: \.universalId) { item in
                    Button(action: {
                        viewModel.toggleSelection(for: item)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.quote.capitalized)
                                    .font(.headline)
                                Text(item.type.marketType.capitalized)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: item.isFavorite == true ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(.blue)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            
            if viewModel.isLoading {
                ProgressView("Searching...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
            }
        }
        .navigationTitle("Search Currencies")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.saveSelection()
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .alert(item: $viewModel.error) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}
