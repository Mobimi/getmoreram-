# Get More Ram (v2.0 Enhanced Edition) 🚀

Một ứng dụng iOS mã nguồn mở giúp quản lý và kích hoạt các quyền bộ nhớ cao cấp (**Increased Memory Limit** & **Extended Virtual Addressing**) cho các ứng dụng Sideload (SideStore, AltStore, LiveContainer) trực tiếp trên iPhone/iPad mà không cần máy tính.

---

## ✨ Tính Năng Nổi Bật (Features)

### 🧠 Quản lý Bộ Nhớ (Memory Budget)
- **Device RAM Gauge:** Hiển thị RAM phần cứng thực tế của thiết bị (ví dụ 6.0 GB).
- **Active Memory Budget:** Đo đạc bộ nhớ khả dụng theo thời gian thực qua hệ thống Darwin (`os_proc_available_memory()`).
- **Memory Ceiling Comparison:** So sánh trực quan giới hạn mặc định (~2-3 GB) với giới hạn mở rộng sau khi có IML (~4-5 GB).

### ⚡ Kích Hoạt Quyền Năng (Capabilities)
- **Increased Memory Limit (IML):** Hỗ trợ cho cả tài khoản Free & Paid Developer. Cần thiết cho Minecraft Java (Amethyst, PojavLauncher) và các giả lập nặng.
- **Extended Virtual Addressing (EVA):** Hỗ trợ tài khoản Paid Developer ($99/năm) để mở rộng không gian địa chỉ ảo 64-bit cho JIT compilers.
- **One-Tap Apply & Verify:** Chạm 1 lần để tự động apply và xác nhận trạng thái từ server.
- **Batch Apply (Hàng Loạt):** Chọn nhiều App ID cùng lúc để kích hoạt tự động với thanh tiến trình (**Progress Bar**).

### 🎯 Trải Nghiệm & Quản Lý Thông Minh
- **App Search & Filters:** Tìm kiếm theo tên hoặc Bundle ID. Lọc theo: Tất cả / Đã ghim ⭐ / Đã kích hoạt ✅ / Chưa kích hoạt ⏳ / Khuyến nghị 🎯.
- **Favorite Apps (⭐):** Ghim các ứng dụng yêu thích như Amethyst hoặc PojavLauncher lên đầu danh sách.
- **Recommended Profiles:** Tự động nhận diện cấu hình tối ưu cho Amethyst, PojavLauncher, Dolphin, MeloNX, UTM, RetroArch, PPSSPP...
- **Duplicate App ID Detection:** Cảnh báo khi có nhiều App ID bị trùng lặp bundle identifier.
- **Team ID Mismatch Check:** Kiểm tra và cảnh báo nếu Team ID không khớp với tài khoản đang đăng nhập.

### 🔍 Xác Minh Quyền (Entitlement Verifier)
- **Mobileprovision & IPA Inspector:** Chọn file `.mobileprovision` hoặc `.ipa` để phân tích cấu trúc CMS/plist, kiểm tra xem Apple đã thật sự ký các key `increased-memory-limit` và `extended-virtual-addressing` hay chưa.
- Kiểm tra ngày hết hạn, Team ID và cảnh báo profile hết hạn.

### 🛠️ Chẩn Đoán & Ngôn Ngữ
- **In-App Diagnostics Log:** Ghi log toàn diện mọi hành động (Anisette, Network, Apple API, Response).
- **Export Logs:** Sao chép hoặc xuất file `.txt` qua Share Sheet để gửi hỗ trợ debug.
- **Song Ngữ (Bilingual):** Hỗ trợ đầy đủ **Tiếng Việt 🇻🇳** và **English 🇺🇸** với công tắc chuyển đổi trực tiếp trong Cài Đặt.

---

## 📖 Hướng Dẫn Sử Dụng (How to Use)

1. Cài đặt (**Sideload**) file IPA của ứng dụng bằng SideStore hoặc AltStore.
2. Vào tab **Cài Đặt (Settings)**, đăng nhập Apple ID (hoặc nhập file tài khoản xuất từ SideStore).
3. Vào tab **Danh Sách App (App IDs)**:
   - Danh sách App ID đã đăng ký của bạn sẽ tự động hiển thị.
   - Nhấn vào app bạn muốn cấp quyền (ví dụ Amethyst hoặc PojavLauncher).
   - Bật **Increased Memory Limit** rồi nhấn **One-Tap Apply**.
   - *(Hoặc bấm nút "Áp Dụng Hàng Loạt" để chọn nhiều app cùng lúc).*
4. Mở SideStore/AltStore, tiến hành **Re-install / Refresh** lại ứng dụng vừa cấp quyền để Apple tạo và ký Provisioning Profile mới.
5. Vào tab **Kiểm Tra Quyền (Verifier)** để kiểm tra lại file profile nếu cần.

---

## 🔒 Bản Quyền & Lời Cảm Ơn (Credits)
- **Stossy11** — Tác giả thư viện [StosSign](https://github.com/stossy11/StosSign).
- **SideStore Team** — Anisette data fetching & Apple auth mechanisms.
- **GetMoreRam Contributors** — Core concept & implementation.
