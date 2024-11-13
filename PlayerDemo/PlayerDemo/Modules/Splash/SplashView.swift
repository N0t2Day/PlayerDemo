//
//  SplashView.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    
    @Bindable var store: StoreOf<SplashFeature>
    
    var body: some View {
        ZStack {
            Color("backgroundMain")
            VStack {
                Text("Verba")
                    .font(.custom("Zapfino", size: 34))
                    .foregroundStyle(Color.orange)
                
            }
        }
        .ignoresSafeArea()
        .onAppear {
            store.send(.toggleTimer)
        }
        .alert($store.scope(state: \.alert, action: \.alert))

    }
}

#Preview {
    SplashView(store: Store.init(initialState: SplashFeature.State(), reducer: {
        SplashFeature()
    }))
}
