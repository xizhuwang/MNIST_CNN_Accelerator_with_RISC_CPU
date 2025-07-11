# MNIST_CNN_Accelerator_with_RISC_CPU
> **Disclaimer**  
> This document is part of the coursework for **Low Power SOC Design Lab 2** at National Taiwan University of Science and technology.
> Process: TSMC 16nm ADFP.
> Authors: **Wei-Wen Lin** and **Xi-Zhu Wang**.

## 1. Discuss of the RTL Design
### System Overview
<img width="786" height="700" alt="image" src="https://github.com/user-attachments/assets/9c10a97e-c34b-4af4-8847-6dab02c7707f" />
<img width="605" height="700" alt="image" src="https://github.com/user-attachments/assets/c939a480-ef1d-4f85-8e76-e09c6d82c718" />

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
<img width="2004" height="411" alt="image" src="https://github.com/user-attachments/assets/8e3819a1-e26b-4bef-85dd-98aaac6fc58b" />

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
<img width="615" height="462" alt="image" src="https://github.com/user-attachments/assets/55dd0931-9444-4196-8293-8556367ca4f3" />

使用 **Post Training Static Quantization** 將浮點數轉為 INT8  
- Validation Accuracy: **89.16%**

---

## ⚫ AI Accelerator 硬體架構設計
<img width="692" height="773" alt="image" src="https://github.com/user-attachments/assets/7996cef0-acef-4aa4-8d44-637cf73ef49b" />

- 使用 Controller 傳輸圖片與權重  
- Datapath 包含單一個運算元件：MAC、ReLU、Comparator  
- 降低硬體複雜度與靜態功耗，實現 Low Power 設計  

---

## Controller 架構
<img width="622" height="745" alt="image" src="https://github.com/user-attachments/assets/2a26be0e-98e3-4981-9da3-e116f0e91a12" />

- 包含五個 Sub Controller (Conv2d、ReLU、Maxpool 等)
- 使用 Handshake Controller 控制通訊
- Top Controller 根據 Start 信號觸發各層處理流程（Conv → ReLU → Maxpool x2 → FC → Predict）

---

## Datapath 架構

### MAC (Multiplier and Accumulator)
<img width="1492" height="590" alt="image" src="https://github.com/user-attachments/assets/b4e5e1bc-c8a2-4d54-8654-59cfdb657626" />
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
<img width="1356" height="336" alt="image" src="https://github.com/user-attachments/assets/0256f08c-321b-4304-a870-84fc2daf67e8" />

- 若輸入 in 的 MSB = 0，則輸出為 in；否則輸出為 0。

---

### Comparator 設計
<img width="928" height="495" alt="image" src="https://github.com/user-attachments/assets/8112e009-0347-4913-bf47-f31d95967529" />

- 用於 Maxpool 與 ArgMax
- 若當前輸入 > V_register，則更新最大值與其 Index

---

## 2. DRC, LVS 結果

| 項目 | 結果 |
|------|------|
| DRC  | ✅ 通過 |
| LVS  | ✅ 通過 |

---

## 3. Area, Power, Leakage Power(TSMC 16nm ADFP) 

- Advantage: MNIST Dataset without Preprocessing
- High Accuracy: Train Accuracy                           88%
 		              Validation Accuracy                   89%
- Area:                                                 13440.097 um2
- Frequency:                                           99.9703 MHz
- Dynamic Power:                                     2.463313 W
- Static Power:                                        2.383464 W (63.7974%)

---

## IR Drop & Instance Power

- IR_DROP_static / dynamic  
- INSTANCE_POWER_static / dynamic  

---

## 4. RTL Waveform
<img width="1727" height="709" alt="螢幕擷取畫面 2025-07-11 145540" src="https://github.com/user-attachments/assets/20d5fc1f-f5dd-49d2-9e85-511d262ef4cb" />

已完成Post sim，程式的ram需替換成adfp中的sram，怕有授權問題這邊僅提供Modelsim的波形供參考。
---

## 5.Optimization
因為本次Project沒有針對CPU進行評分，所以我們移除了CPU來提升面積與功耗效益，如果有需要可以針對Controller進行修改把原本的RISC架構復原。


---
