//
//  FlashlightView.swift
//  Rule2
//
//  Created by 蔡振宇 on 2025/8/16.
//

import SwiftUI
import AVFoundation

struct FlashlightView: View {
    var onBack: () -> Void
    @ObservedObject private var flashlightVM = FlashlightViewModel()
    
    var body: some View {
        ZStack {
            // 背景色根据手电筒状态变化
            Color(flashlightVM.isOn ? .white : .black)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: flashlightVM.isOn)
            
            VStack(spacing: 0) {
                // 顶部控制区域
                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(flashlightVM.isOn ? .black : .white)
                        Text("返回")
                            .foregroundColor(flashlightVM.isOn ? .black : .white)
                    }
                    .padding(.top, 8)
                    Spacer()
                }
                .padding(.leading)
                
                Spacer()
                
                // 手电筒图标和开关
                VStack(spacing: 30) {
                    // 手电筒图标
                    Image(systemName: flashlightVM.isOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.system(size: 120))
                        .foregroundColor(flashlightVM.isOn ? .black : .white)
                        .animation(.easeInOut(duration: 0.3), value: flashlightVM.isOn)
                    
                    // 开关按钮
                    Button(action: {
                        flashlightVM.toggleFlashlight()
                    }) {
                        Text(flashlightVM.isOn ? "关闭" : "开启")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(flashlightVM.isOn ? .white : .black)
                            .frame(width: 120, height: 50)
                            .background(flashlightVM.isOn ? Color.black : Color.white)
                            .cornerRadius(25)
                            .shadow(radius: 10)
                    }
                    .animation(.easeInOut(duration: 0.3), value: flashlightVM.isOn)
                }
                
                Spacer()
                
                // 亮度调节滑块（仅在开启时显示）
                if flashlightVM.isOn {
                    VStack(spacing: 20) {
                        Text("亮度调节")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        HStack {
                            Image(systemName: "sun.min")
                                .foregroundColor(.black)
                            
                            Slider(value: $flashlightVM.brightness, in: 0.1...1.0, step: 0.1)
                                .accentColor(.black)
                                .onChange(of: flashlightVM.brightness) { newValue in
                                    flashlightVM.updateBrightness(newValue)
                                }
                            
                            Image(systemName: "sun.max")
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 40)
                        
                        Text("\(Int(flashlightVM.brightness * 100))%")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: flashlightVM.isOn)
                }
            }
        }
        .onAppear {
            flashlightVM.checkFlashlightAvailability()
        }
    }
}

// 手电筒ViewModel
class FlashlightViewModel: ObservableObject {
    @Published var isOn: Bool = false
    @Published var brightness: Double = 1.0
    @Published var isAvailable: Bool = false
    
    private var device: AVCaptureDevice?
    
    init() {
        device = AVCaptureDevice.default(for: .video)
    }
    
    func checkFlashlightAvailability() {
        guard let device = device else {
            isAvailable = false
            return
        }
        
        isAvailable = device.hasTorch && device.isTorchAvailable
    }
    
    func toggleFlashlight() {
        guard isAvailable else { return }
        
        if isOn {
            turnOffFlashlight()
        } else {
            turnOnFlashlight()
        }
    }
    
    func turnOnFlashlight() {
        guard let device = device, isAvailable else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                try device.setTorchModeOn(level: Float(brightness))
                DispatchQueue.main.async {
                    self.isOn = true
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print("开启手电筒失败: \(error.localizedDescription)")
        }
    }
    
    func turnOffFlashlight() {
        guard let device = device, isAvailable else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                device.torchMode = .off
                DispatchQueue.main.async {
                    self.isOn = false
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print("关闭手电筒失败: \(error.localizedDescription)")
        }
    }
    
    func updateBrightness(_ newBrightness: Double) {
        guard let device = device, isAvailable, isOn else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.hasTorch {
                try device.setTorchModeOn(level: Float(newBrightness))
            }
            
            device.unlockForConfiguration()
        } catch {
            print("调节亮度失败: \(error.localizedDescription)")
        }
    }
}

#Preview {
    FlashlightView(onBack: {})
}
