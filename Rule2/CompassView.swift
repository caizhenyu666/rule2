//
//  CompassView.swift
//  Rule2
//
//  Created by 蔡振宇 on 2025/8/16.
//

import SwiftUI
import CoreLocation
import AudioToolbox

struct CompassView: View {
    var onBack: () -> Void
    @ObservedObject private var compassVM = CompassViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部状态栏区域
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
                
                // 指南针主体
                ZStack {
                    // 外圈刻度 - 需要根据方向转动
                    CompassDial(heading: compassVM.heading)
                        .frame(width: 280, height: 280)
                    
                    // 方向指示线 - 固定不动
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 140)
                        .offset(y: -70)
                    
                    // 中心十字准星 - 固定不动
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 1, height: 12)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 12, height: 1)
                    }
                    
                    // 北方红色指针 - 固定不动
                    Triangle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .offset(y: -134)
                }
                
                Spacer()
                
                // 底部信息
                VStack(spacing: 8) {
                    Text("\(Int(compassVM.heading))° \(compassVM.directionText)")
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            compassVM.startCompass()
        }
    }
}

// 指南针刻度盘 - 根据方向转动
struct CompassDial: View {
    let heading: Double
    
    var body: some View {
        ZStack {
            // 外圈
            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            
            // 刻度线
            ForEach(0..<360, id: \.self) { degree in
                let isMajor = degree % 30 == 0
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: isMajor ? 3 : 1, height: isMajor ? 15 : 8)
                    .offset(y: isMajor ? -127.5 : -131)
                    .rotationEffect(.degrees(Double(degree) - heading))
            }
            
            // 主要方向文字
            ForEach(0..<4, id: \.self) { index in
                let directions = ["北", "东", "南", "西"]
                let degrees = [0, 90, 180, 270]
                
                Text(directions[index])
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .offset(y: -110)
                    .rotationEffect(.degrees(Double(degrees[index]) - heading))
            }
            
            // 度数标记
            ForEach(0..<12, id: \.self) { index in
                let degree = index * 30
                Text("\(degree)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .offset(y: -95)
                    .rotationEffect(.degrees(Double(degree) - heading))
            }
        }
    }
}

// 三角形指针
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// 指南针ViewModel
class CompassViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0.0
    
    private let locationManager = CLLocationManager()
    private var lastVibrationHeading: Int = -1
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
    }
    
    func startCompass() {
        locationManager.startUpdatingHeading()
    }
    
    var directionText: String {
        let directions = ["北", "东北", "东", "东南", "南", "西南", "西", "西北"]
        let index = Int((heading + 22.5) / 45) % 8
        return directions[index]
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let newHeadingValue = newHeading.magneticHeading
        
        // 检查是否需要震动（每30度）
        let currentHeadingInt = Int(newHeadingValue)
        let lastHeadingInt = Int(heading)
        
        // 检查是否跨越了30度的倍数
        let current30Degree = currentHeadingInt / 30
        let last30Degree = lastHeadingInt / 30
        
        if current30Degree != last30Degree && currentHeadingInt != lastVibrationHeading {
            // 震动反馈
            AudioServicesPlaySystemSound(1519) // 轻微震动
            lastVibrationHeading = currentHeadingInt
        }
        
        DispatchQueue.main.async {
            self.heading = newHeadingValue
        }
    }
}

#Preview {
    CompassView(onBack: {})
}
