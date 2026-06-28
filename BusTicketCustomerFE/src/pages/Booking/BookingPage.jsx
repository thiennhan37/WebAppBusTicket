import {useEffect, useState} from "react";
import {useLocation, useNavigate, useParams} from "react-router-dom";
import {holdSeats} from "../../services/orderService";
import {useAuth} from "../../context/AuthContext";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import BrutalInput from "../../components/BrutalInput";
import {ArrowLeft, MapPin} from "lucide-react";
import {toast} from "sonner";
import "./BookingPage.css";

export default function BookingPage() {
    const {tripId} = useParams();
    const navigate = useNavigate();
    const location = useLocation();
    const {user} = useAuth();

    const {
        selectedSeatIds,
        selectedSeatCodes,
        selectedPickupStopId,
        selectedDropoffStopId,
        selectedPickupStop,
        selectedDropoffStop,
        totalCost,
    } = location.state || {};

    const [customerName, setCustomerName] = useState(user?.fullName || "");
    const [customerPhone, setCustomerPhone] = useState(user?.phone || "");
    const [customerEmail, setCustomerEmail] = useState(user?.email || "");
    const [submitting, setSubmitting] = useState(false);

    useEffect(() => {
        if (!selectedSeatIds || selectedSeatIds.length === 0) {
            toast.error("Vui lòng chọn ghế trước khi nhập thông tin");
            navigate(`/khachhang/chon-ghe/${tripId}`, {replace: true});
            return;
        }

        if (!selectedPickupStopId || !selectedDropoffStopId) {
            toast.error("Vui lòng chọn điểm đón/trả trước khi nhập thông tin");
            navigate(`/khachhang/chon-diem/${tripId}`, {
                replace: true,
                state: {selectedSeatIds, selectedSeatCodes, totalCost},
            });
        }
    }, [navigate, selectedDropoffStopId, selectedPickupStopId, selectedSeatCodes, selectedSeatIds, totalCost, tripId]);

    const handleSubmit = async (e) => {
    e.preventDefault();

    if (!customerName || !customerPhone || !customerEmail) {
      toast.error("Vui lòng điền đầy đủ thông tin liên hệ");
      return;
    }

    setSubmitting(true);
    try {
      const holdRes = await holdSeats(tripId, {
        tripSeatIdList: selectedSeatIds,
        arrivalId: selectedPickupStopId,
        destinationId: selectedDropoffStopId,
      });
      const orderId = holdRes.data.result || holdRes.data;
      const holdStartedAt = Date.now();

      toast.success("Giữ ghế thành công! Vui lòng thanh toán trong 10 phút.");
      navigate(`/khachhang/thanh-toan/${tripId}?orderId=${orderId}`, {
        state: {
          orderId,
          holdStartedAt,
          selectedSeatIds,
          selectedSeatCodes,
          selectedPickupStopId,
          selectedDropoffStopId,
          selectedPickupStop,
          selectedDropoffStop,
          totalCost,
          customerName,
          customerPhone,
          customerEmail,
        },
      });
    } catch (err) {
      console.error("Hold seats error:", err);
      
      const errData = err.response?.data;
      const errMsg = errData?.message || err.message || "Không thể giữ ghế. Vui lòng thử lại.";
      
      // Hiển thị thông báo lỗi chung từ hệ thống
      toast.error(errMsg);

      // Nếu mã lỗi là 4010 (Ghế đã bị đặt)
      if (errData?.code === 4010) {
        // Quay lại trang chọn ghế và đính kèm danh sách ghế đang xử lý qua state
        navigate(`/khachhang/chon-ghe/${tripId}`, { 
          replace: true, 
          state: {
            previouslySelectedSeatIds: selectedSeatIds,
            previouslySelectedSeatCodes: selectedSeatCodes
          }
        });
      }
    } finally {
      setSubmitting(false);
    }
  };

    return (
        <div className="booking-page">
            <div className="container">
                <div className="booking-actions">
                    <button className="brutal-btn" onClick={() => navigate(-1)}>
                        <ArrowLeft size={16}/> Quay lại
                    </button>
                </div>

                <div className="booking-layout">
                    <div className="booking-form-section">
                        <form onSubmit={handleSubmit}>
                            <BrutalCard className="form-card" noHover>
                                <h3 className="form-card__title">Thông tin khách hàng</h3>

                                <BrutalInput
                                    label="Họ và tên"
                                    id="customer-name"
                                    placeholder="Nhập họ và tên người đi xe..."
                                    value={customerName}
                                    onChange={(e) => setCustomerName(e.target.value)}
                                    required
                                />

                                <BrutalInput
                                    label="Số điện thoại"
                                    id="customer-phone"
                                    type="tel"
                                    placeholder="Nhập số điện thoại..."
                                    value={customerPhone}
                                    onChange={(e) => setCustomerPhone(e.target.value)}
                                    required
                                />

                                <BrutalInput
                                    label="Địa chỉ Email"
                                    id="customer-email"
                                    type="email"
                                    placeholder="Nhập email nhận vé..."
                                    value={customerEmail}
                                    onChange={(e) => setCustomerEmail(e.target.value)}
                                    required
                                />
                            </BrutalCard>

                            <div className="booking-submit-wrapper">
                                <BrutalButton
                                    type="submit"
                                    variant="primary"
                                    size="large"
                                    className="brutal-btn--full"
                                    disabled={submitting}
                                >
                                    {submitting ? "ĐANG GIỮ GHẾ..." : "TIẾP TỤC THANH TOÁN"}
                                </BrutalButton>
                            </div>
                        </form>
                    </div>

                    <div className="booking-summary-section">
                        <BrutalCard className="ticket-summary-card" noHover>
                            <h3 className="ticket-summary-title">Tóm tắt chuyến đi</h3>

                            <div className="ticket-summary-route">
                                <div className="station-indicator">
                                    <MapPin size={16}/>
                                    <div>
                                        <strong>Điểm đón</strong>
                                        <span className="station-detail">
                                            {selectedPickupStop?.stop?.name || selectedPickupStopId}
                                        </span>
                                        <span className="station-detail">
                                            {selectedPickupStop?.stop?.address}
                                        </span>
                                    </div>
                                </div>
                                <div className="route-connector"></div>
                                <div className="station-indicator">
                                    <MapPin size={16}/>
                                    <div>
                                        <strong>Điểm trả</strong>
                                        <span className="station-detail">
                                            {selectedDropoffStop?.stop?.name || selectedDropoffStopId}
                                        </span>
                                        <span className="station-detail">
                                            {selectedDropoffStop?.stop?.address}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div className="ticket-summary-divider"></div>

                            <div className="ticket-summary-seats">
                                <div className="detail-item__label">Danh sách ghế ({selectedSeatIds?.length || 0} ghế)</div>
                                <div className="seats-tags" style={{marginTop: "0.5rem"}}>
                                    {(selectedSeatCodes || []).map((code) => (
                                        <span key={code} className="brutal-tag text-mono">Ghế {code}</span>
                                    ))}
                                </div>
                            </div>

                            <div className="ticket-summary-divider"></div>

                            <div className="ticket-summary-total">
                                <span>Tổng tiền tạm tính:</span>
                                <span className="total-value text-mono">
                                    {new Intl.NumberFormat("vi-VN").format(totalCost || 0)}đ
                                </span>
                            </div>
                        </BrutalCard>
                    </div>
                </div>
            </div>
        </div>
    );
}
