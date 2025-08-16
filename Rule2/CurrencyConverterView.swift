//
//  CurrencyConverterView.swift
//  Rule2
//
//  Created by 蔡振宇 on 2025/8/16.
//

import SwiftUI

struct CurrencyConverterView: View {
    var onBack: () -> Void
    @ObservedObject private var converterVM = CurrencyConverterViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部控制区域
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
                
                // 标题
                Text("汇率换算")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // 转换区域
                VStack(spacing: 30) {
                    // 输入区域
                    VStack(spacing: 15) {
                        HStack {
                            Text("从")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack {
                            TextField("0.00", text: $converterVM.inputAmount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .focused($isInputFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("完成") {
                                            isInputFocused = false
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                .onChange(of: converterVM.inputAmount) { newValue in
                                    // 限制只能输入数字和小数点
                                    let filtered = newValue.filter { "0123456789.".contains($0) }
                                    if filtered != newValue {
                                        converterVM.inputAmount = filtered
                                    }
                                    // 自动转换
                                    if !filtered.isEmpty {
                                        converterVM.convert()
                                    }
                                }
                            
                            Menu {
                                ForEach(converterVM.currencies, id: \.code) { currency in
                                    Button(currency.name) {
                                        converterVM.fromCurrency = currency
                                        if !converterVM.inputAmount.isEmpty {
                                            converterVM.convert()
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(converterVM.fromCurrency.code)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    // 转换按钮
                    Button(action: {
                        // 强制隐藏键盘
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        converterVM.convert()
                    }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                    .disabled(converterVM.inputAmount.isEmpty)
                    
                    // 输出区域
                    VStack(spacing: 15) {
                        HStack {
                            Text("到")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack {
                            Text(converterVM.resultAmount)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                            
                            Menu {
                                ForEach(converterVM.currencies, id: \.code) { currency in
                                    Button(currency.name) {
                                        converterVM.toCurrency = currency
                                        if !converterVM.inputAmount.isEmpty {
                                            converterVM.convert()
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(converterVM.toCurrency.code)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 汇率信息
                if !converterVM.exchangeRate.isEmpty {
                    VStack(spacing: 10) {
                        Text("汇率")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(converterVM.exchangeRate)
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("更新时间: \(converterVM.lastUpdateTime)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            converterVM.loadExchangeRates()
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
}

// 货币模型
struct Currency {
    let code: String
    let name: String
    let symbol: String
}

// 汇率换算ViewModel
class CurrencyConverterViewModel: ObservableObject {
    @Published var inputAmount: String = ""
    @Published var resultAmount: String = "0.00"
    @Published var fromCurrency: Currency = Currency(code: "CNY", name: "人民币", symbol: "¥")
    @Published var toCurrency: Currency = Currency(code: "USD", name: "美元", symbol: "$")
    @Published var exchangeRate: String = ""
    @Published var lastUpdateTime: String = ""
    
    // 支持的货币列表
    let currencies: [Currency] = [
        Currency(code: "CNY", name: "人民币", symbol: "¥"),
        Currency(code: "USD", name: "美元", symbol: "$"),
        Currency(code: "EUR", name: "欧元", symbol: "€"),
        Currency(code: "JPY", name: "日元", symbol: "¥"),
        Currency(code: "GBP", name: "英镑", symbol: "£"),
        Currency(code: "KRW", name: "韩元", symbol: "₩"),
        Currency(code: "HKD", name: "港币", symbol: "HK$"),
        Currency(code: "CAD", name: "加拿大元", symbol: "C$"),
        Currency(code: "AUD", name: "澳大利亚元", symbol: "A$"),
        Currency(code: "SGD", name: "新加坡元", symbol: "S$")
    ]
    
    // 模拟汇率数据（实际应用中应该从API获取）
    private var rates: [String: Double] = [
        "USD": 1.0,
        "CNY": 7.23,
        "EUR": 0.92,
        "JPY": 148.5,
        "GBP": 0.79,
        "KRW": 1330.0,
        "HKD": 7.82,
        "CAD": 1.35,
        "AUD": 1.52,
        "SGD": 1.34
    ]
    
    func loadExchangeRates() {
        // 这里应该调用真实的汇率API
        // 目前使用模拟数据
        updateLastUpdateTime()
    }
    
    func convert() {
        guard let inputValue = Double(inputAmount) else {
            resultAmount = "0.00"
            return
        }
        
        // 获取汇率
        let fromRate = rates[fromCurrency.code] ?? 1.0
        let toRate = rates[toCurrency.code] ?? 1.0
        
        // 计算转换结果
        let result = (inputValue / fromRate) * toRate
        
        // 格式化结果
        resultAmount = String(format: "%.2f", result)
        
        // 更新汇率显示
        let rate = toRate / fromRate
        exchangeRate = "1 \(fromCurrency.code) = \(String(format: "%.4f", rate)) \(toCurrency.code)"
    }
    
    private func updateLastUpdateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        lastUpdateTime = formatter.string(from: Date())
    }
}

#Preview {
    CurrencyConverterView(onBack: {})
}
