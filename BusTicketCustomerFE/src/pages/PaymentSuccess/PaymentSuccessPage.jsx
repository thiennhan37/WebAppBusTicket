import React from "react";
import { useSearchParams, useNavigate } from "react-router-dom";
import { CheckCircle2, XCircle, ArrowLeft } from "lucide-react";
import "./PaymentSuccessPage.css";

export default function PaymentSuccessPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();

  // Lấy các tham số từ URL (Hỗ trợ cả MoMo và VNPay)
  const amount = searchParams.get("amount") || searchParams.get("vnp_Amount") || "0";
  const orderInfo = searchParams.get("orderInfo") || searchParams.get("vnp_OrderInfo") || "Không có thông tin";
  const transId = searchParams.get("transId") || searchParams.get("vnp_TransactionNo") || "N/A";
  
  // Kiểm tra trạng thái thành công: MoMo (resultCode=0) hoặc VNPay (vnp_ResponseCode=00)
  const resultCode = searchParams.get("resultCode");
  const vnpResponseCode = searchParams.get("vnp_ResponseCode");
  const isSuccess = resultCode === "0" || vnpResponseCode === "00";

  // Format tiền tệ (VNPay thường nhân 100 số tiền thật, MoMo thì giữ nguyên)
  const formattedAmount = new Intl.NumberFormat("vi-VN", {
    style: "currency",
    currency: "VND",
  }).format(vnpResponseCode ? Number(amount) / 100 : Number(amount));

  return (
    <div className="payment-result-page">
      <div className="payment-card">
        <div className={`payment-icon ${isSuccess ? "success" : "error"}`}>
          {isSuccess ? <CheckCircle2 size={64} /> : <XCircle size={64} />}
        </div>
        
        <h1 className="payment-title">
          {isSuccess ? "THANH TOÁN THÀNH CÔNG!" : "THANH TOÁN THẤT BẠI!"}
        </h1>
        
        <p className="payment-message">
          {isSuccess 
            ? "Cảm ơn bạn đã sử dụng dịch vụ của VÉ XE Đắt. Đơn hàng của bạn đã được xác nhận." 
            : "Rất tiếc, giao dịch của bạn không thành công hoặc đã bị hủy. Vui lòng thử lại."}
        </p>

        <div className="payment-details">
          <div className="payment-row">
            <span className="payment-label">Mã giao dịch:</span>
            <span className="payment-value">{transId}</span>
          </div>
          <div className="payment-row">
            <span className="payment-label">Nội dung:</span>
            <span className="payment-value">{orderInfo}</span>
          </div>
          <div className="payment-row">
            <span className="payment-label">Số tiền:</span>
            <span className="payment-value amount">{formattedAmount}</span>
          </div>
        </div>

        <button 
          className="brutal-btn brutal-btn--primary payment-home-btn"
          onClick={() => navigate("/khachhang")}
        >
          <ArrowLeft size={18} style={{ marginRight: "8px" }} />
          QUAY VỀ TRANG CHỦ
        </button>
      </div>
    </div>
  );
}