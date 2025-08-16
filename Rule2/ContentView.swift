//
//  ContentView.swift
//  Rule2
//
//  Created by 蔡振宇 on 2025/8/16.
//

import SwiftUI
import CoreLocation

struct Tool: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

struct ContentView: View {
    let tools: [Tool] = [
        Tool(name: "尺子", icon: "ruler"),
        Tool(name: "指南针", icon: "location.north.line"),
        Tool(name: "计算器", icon: "plus.slash.minus"),
        Tool(name: "汇率换算", icon: "dollarsign.circle"),
        Tool(name: "水平仪", icon: "circle.lefthalf.filled"),
        Tool(name: "手电筒", icon: "flashlight.on.fill")
    ]
    @State private var selectedTool: Tool? = nil
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            exit(0)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                            Text("返回")
                        }
                        .padding(.top, 8)
                        Spacer()
                    }
                    .padding(.leading)
                    Text("小工具合集")
                        .font(.largeTitle)
                        .bold()
                        .padding([.leading, .top])
                    Spacer().frame(height: 20)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                        ForEach(tools) { tool in
                            Button(action: {
                                selectedTool = tool
                            }) {
                                VStack {
                                    Image(systemName: tool.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.accentColor)
                                    Text(tool.name)
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                    Spacer()
                }
                .navigationBarHidden(true)
                // 指南针界面弹出
                if selectedTool?.name == "指南针" {
                    CompassView(onBack: { selectedTool = nil })
                        .transition(.move(edge: .trailing))
                        .zIndex(1)
                }
            }
        }
    }
}

// 指南针界面
struct CompassView: View {
    var onBack: () -> Void
    @ObservedObject private var compassVM = CompassViewModel()
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("返回")
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                    Spacer()
                }
                .padding(.leading)
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 8)
                        .frame(width: 220, height: 220)
                    CompassNeedle(angle: compassVM.heading)
                        .frame(width: 180, height: 180)
                    Text("\(Int(compassVM.heading))°")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: 120)
                }
                Spacer()
            }
        }
    }
}

// 指南针指针
struct CompassNeedle: View {
    var angle: Double
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.red)
                .frame(width: 8, height: 90)
                .cornerRadius(4)
                .offset(y: -45)
            Rectangle()
                .fill(Color.white)
                .frame(width: 8, height: 60)
                .cornerRadius(4)
                .offset(y: 30)
        }
        .rotationEffect(.degrees(angle))
    }
}

// 指南针ViewModel
class CompassViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0.0
    private let locationManager = CLLocationManager()
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.startUpdatingHeading()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
    }
}

#Preview {
    ContentView()
}
