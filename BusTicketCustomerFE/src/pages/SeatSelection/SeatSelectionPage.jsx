import {useState, useEffect} from "react";
import {useParams, useNavigate, useLocation} from "react-router-dom";
import {getBusDiagram} from "../../services/tripService";
import {useAuth} from "../../context/AuthContext";
import SeatMap from "../../components/SeatMap";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import {ArrowLeft, HelpCircle} from "lucide-react";
import {toast} from "sonner";
import "./SeatSelectionPage.css";

export default function SeatSelectionPage() {
    const {tripId} = useParams();
    const navigate = useNavigate();
    const location = useLocation();
    const {isAuthenticated} = useAuth();

    const [seats, setSeats] = useState([]);
    const [busTypeName, setBusTypeName] = useState("");
    const [diagram, setDiagram] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [selectedSeatIds, setSelectedSeatIds] = useState([]);
    const [selectedSeatCodes, setSelectedSeatCodes] = useState([]);

    useEffect(() => {
        const fetchDiagram = async () => {
            setLoading(true);
            setError(null);
            try {
                const res = await getBusDiagram(tripId);
                const data = res.data.result || res.data;
                setSeats(data.seats || []);
                setBusTypeName(data.busTypeName || "");
                setDiagram(data.diagram || null);
            } catch (err) {
                console.error("Fetch bus diagram error:", err);
                setError("Không thể tải sơ đồ ghế ngồi. Vui lòng quay lại thử sau!");
            } finally {
                setLoading(false);
            }
        };

        fetchDiagram();
    }, [tripId]);

    const handleSeatSelect = (seat) => {
        if (selectedSeatIds.includes(seat.seatId)) {
            setSelectedSeatIds((prev) => prev.filter((id) => id !== seat.seatId));
            setSelectedSeatCodes((prev) => prev.filter((code) => code !== seat.seatCode));
            return;
        }

        if (selectedSeatIds.length >= 5) {
            toast.error("Bạn chỉ được chọn tối đa 5 ghế trên một đơn hàng");
            return;
        }

        setSelectedSeatIds((prev) => [...prev, seat.seatId]);
        setSelectedSeatCodes((prev) => [...prev, seat.seatCode]);
    };

    const calculateTotal = () => {
        return selectedSeatIds.reduce((total, id) => {
            const seat = seats.find((s) => s.seatId === id);
            return total + (seat ? seat.price : 0);
        }, 0);
    };

    const handleContinue = () => {
        if (selectedSeatIds.length === 0) {
            toast.error("Vui lòng chọn ít nhất một ghế");
            return;
        }

        if (!isAuthenticated) {
            toast.warning("Bạn cần đăng nhập để thực hiện đặt vé");
            navigate(`/khachhang/dang-nhap?redirect=${encodeURIComponent(location.pathname)}`);
            return;
        }

        navigate(`/khachhang/chon-diem/${tripId}`, {
            state: {
                selectedSeatIds,
                selectedSeatCodes,
                totalCost: calculateTotal(),
            },
        });
    };

    return (
        <div className="seat-selection-page">
            <div className="container">
                <button className="back-link brutal-btn" onClick={() => navigate(-1)}>
                    <ArrowLeft size={16}/> QUAY LẠI
                </button>

                {loading ? (
                    <div className="page-loader">
                        <div className="brutal-spinner"></div>
                        <p>Đang tải sơ đồ xe...</p>
                    </div>
                ) : error ? (
                    <BrutalCard className="error-card text-center">
                        <h3>Lỗi tải sơ đồ</h3>
                        <p>{error}</p>
                        <BrutalButton variant="primary" onClick={() => navigate(-1)} style={{marginTop: "1rem"}}>
                            Quay lại danh sách
                        </BrutalButton>
                    </BrutalCard>
                ) : (
                    <div className="seat-selection-grid">
                        <div className="seat-selection-map-container">
                            <SeatMap
                                seats={seats}
                                diagram={diagram}
                                busTypeName={busTypeName}
                                selectedSeats={selectedSeatIds}
                                onSeatSelect={handleSeatSelect}
                            />
                        </div>

                        <div className="seat-selection-summary">
                            <BrutalCard className="summary-card" noHover>
                                <h3 className="summary-card__title">Tóm tắt đặt vé</h3>

                                <div className="summary-card__info-row">
                                    <span>Loại xe:</span>
                                    <strong className="text-mono">{busTypeName}</strong>
                                </div>

                                <div className="summary-card__divider"></div>

                                <div className="summary-card__info-row">
                                    <span>Số ghế đã chọn:</span>
                                    <strong className="text-mono">{selectedSeatIds.length}</strong>
                                </div>

                                <div className="summary-card__seats-list">
                                    {selectedSeatCodes.length > 0 ? (
                                        selectedSeatCodes.map((code) => (
                                            <span key={code} className="brutal-tag text-mono">
                                                Ghế {code}
                                            </span>
                                        ))
                                    ) : (
                                        <span style={{color: "var(--color-gray-500)", fontStyle: "italic"}}>
                                            Chưa chọn ghế nào
                                        </span>
                                    )}
                                </div>

                                <div className="summary-card__divider"></div>

                                <div className="summary-card__info-row total-row">
                                    <span>Tổng tiền tạm tính:</span>
                                    <span className="total-price text-mono">
                                        {new Intl.NumberFormat("vi-VN").format(calculateTotal())}đ
                                    </span>
                                </div>

                                <BrutalButton
                                    variant="primary"
                                    size="large"
                                    className="brutal-btn--full"
                                    disabled={selectedSeatIds.length === 0}
                                    onClick={handleContinue}
                                >
                                    TIẾP TỤC ĐẶT VÉ
                                </BrutalButton>

                                <div className="summary-card__note">
                                    <HelpCircle size={14}/>
                                    <span>
                                        Mỗi tài khoản được chọn tối đa 5 ghế. Ghế chỉ được giữ sau khi bạn xác nhận thông tin cá nhân.
                                    </span>
                                </div>
                            </BrutalCard>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
