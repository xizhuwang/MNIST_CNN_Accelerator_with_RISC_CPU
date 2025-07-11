# MNIST_CNN_Accelerator_with_RISC_CPU
> **Disclaimer**  
> This document is part of the coursework for **Low Power SOC Design Lab 2** at National Taiwan University of Science and technology.  
> Authors: **Wei-Wen Lin** and **Xi-Zhu Wang**.

---
## 1. Discuss of the RTL Design
### System Overview

#### Load Data
1. CPU fetches the LDM instruction.  
2. CPU enters Sleep Mode (waits for a Ready signal and locks the PC).  
3. Sleep_Mode_Controller transfers PictureData / WeightData.  
4. CPU exits Sleep Mode (unlocks the PC).  

#### Predict Data
1. CPU fetches the MNIST instruction.  
2. CPU enters Sleep Mode (waits for a Ready signal and locks the PC).  
3. Sleep_Mode_Controller sends a Start signal to the accelerator.  
4. Accelerator is computing.  
5. Accelerator finishes computation and returns Done and Predict_Label signals.  
6. Sleep_Mode_Controller stores the Predict_Label into RF$0.  
7. CPU exits Sleep Mode (unlocks the PC).  

---
## Flow System Architecture
---

## ⚫ 神經網路架構演算法

神經網路架構如下：

- 經過兩次 Conv2d → ReLU → Maxpool2d 運算  
- 接著 Fully Connected Layer 將 feature 映射到 10 類別  
- 最後使用 ArgMax 輸出預測類別  

### 運算設定

- **Conv2d**:  
  - Kernel Size: 5x5  
  - Stride: 1  
  - Padding: 0  
  - FilterIn = FilterOut = 1  

- **Maxpool2d**:  
  - Kernel Size: 2x2  
  - Stride: 2  
  - Padding: 0  

- **Fully Connected Layer**:  
  - 10x16 (Input Dim = 16, Output Dim = 10)  

---

## ⚫ Accelerator Architecture

### 訓練與量化設定

- **Dataset**: MNIST (無預處理)  
- **Batch size**: 128  
- **Loss Function**: Cross Entropy  
- **Learning rate**: 1e-3  
- **Optimizer**: Adam  
- **Epochs**: 100  

使用 **Post Training Static Quantization** 將浮點數轉為 INT8  
- Validation Accuracy: **89.16%**

---

## ⚫ AI Accelerator 硬體架構設計

- 使用 Controller 傳輸圖片與權重  
- Datapath 包含單一個運算元件：MAC、ReLU、Comparator  
- 降低硬體複雜度與靜態功耗，實現 Low Power 設計  

---

## Controller 架構

- 包含五個 Sub Controller (Conv2d、ReLU、Maxpool 等)
- 使用 Handshake Controller 控制通訊
- Top Controller 根據 Start 信號觸發各層處理流程（Conv → ReLU → Maxpool x2 → FC → Predict）

---

## Datapath 架構

### MAC (Multiplier and Accumulator)

- 原始方法需用 16-bit 累加器：
  ```verilog
  Out(16) <= Out(16) + Feature(8) * Weight(8)
  Out_norm(8) = normalize(Out(8))
  ```

- 優化方式：先 Normalize 再累加，只需 8-bit：
  ```verilog
  Out_tmp(16) = Feature(8) * Weight(8)
  Out_tmp1(8) = normalize(Out_tmp(16))
  Out_norm(8) <= Out_norm(8) + Out_tmp1(8)
  ```

- 使用 10-bit、12-bit Scaling Factor 實驗  
- 結果顯示：10-bit 精度足夠，且可用位移實現（節省硬體）

---

### ReLU 電路設計

- 若輸入 in 的 MSB = 0，則輸出為 in；否則輸出為 0。

---

### Comparator 設計

- 用於 Maxpool 與 ArgMax
- 若當前輸入 > V_register，則更新最大值與其 Index

---

## 2. DRC, LVS 結果

| 項目 | 結果 |
|------|------|
| DRC  | ✅ 通過 |
| LVS  | ✅ 通過 |

---

## 3. Area, Power, Leakage Power

### Design Compiler (RTL → Netlist)
- **Single_Cycle_CPU.area**
- **Single_Cycle_CPU.power**

### Innovus (Netlist → Chip Layout)
- **Single_Cycle_CPU.area**
- **Single_Cycle_CPU.static_power**
- **Single_Cycle_CPU.dynamic_power**

---

## IR Drop & Instance Power

- IR_DROP_static / dynamic  
- INSTANCE_POWER_static / dynamic  

---

## 4. RTL Waveform

### Post-Simulation

- Load Data  
- Prediction  

### Post Layout

- Layout-based simulation 波形展示

---

## 5.Optimization
因為本次Project沒有針對CPU進行檢測，所以我們移除了CPU來提升面積與功耗效益。


---
