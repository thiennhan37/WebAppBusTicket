import {useEffect, useState} from "react";
import {useLocation, useNavigate, useParams} from "react-router-dom";
import {getTripStops} from "../../services/tripService";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import {AlertCircle, ArrowLeft, MapPin} from "lucide-react";
import {toast} from "sonner";
import "./StopSelectionPage.css";

export default function StopSelectionPage() {
    const {tripId} = useParams();
    const navigate = useNavigate();
    const location = useLocation();
    const {selectedSeatIds, selectedSeatCodes, totalCost} = location.state || {};

    const [pickupStops, setPickupStops] = useState([]);
    const [dropoffStops, setDropoffStops] = useState([]);
    const [selectedPickupStopId, setSelectedPickupStopId] = useState("");
    const [selectedDropoffStopId, setSelectedDropoffStopId] = useState("");
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (!selectedSeatIds || selectedSeatIds.length === 0) {
            toast.error("Vui lòng chọn ghế trước khi chọn điểm đón/trả");
            navigate(`/khachhang/chon-ghe/${tripId}`, {replace: true});
            return;
        }

        const fetchStops = async () => {
            setLoading(true);
            setError(null);
            try {
                const res = await getTripStops(tripId);
                const stopsData = res.data.result || res.data || [];
                setPickupStops(stopsData.filter((stop) => stop.type === "UP"));
                setDropoffStops(stopsData.filter((stop) => stop.type === "DOWN"));
            } catch (err) {
                console.error("Fetch trip stops error:", err);
                setError("Không thể tải danh sách điểm đón/trả.");
            } finally {
                setLoading(false);
            }
        };

        fetchStops();
    }, [navigate, selectedSeatIds, tripId]);

    const handleContinue = () => {
        if (!selectedPickupStopId || !selectedDropoffStopId) {
            toast.error("Vui lòng chọn điểm đón và điểm trả");
            return;
        }

        const selectedPickupStop = pickupStops.find((stop) => String(stop.id) === selectedPickupStopId);
        const selectedDropoffStop = dropoffStops.find((stop) => String(stop.id) === selectedDropoffStopId);

        navigate(`/khachhang/dat-ve/${tripId}`, {
            state: {
                selectedSeatIds,
                selectedSeatCodes,
                selectedPickupStopId,
                selectedDropoffStopId,
                selectedPickupStop,
                selectedDropoffStop,
                totalCost,
            },
        });
    };

    return (
        <div className="stop-selection-page">
            <div className="container">
                <button className="back-link brutal-btn" onClick={() => navigate(-1)}>
                    <ArrowLeft size={16}/> QUAY LẠI
                </button>

                {loading ? (
                    <div className="page-loader">
                        <div className="brutal-spinner"></div>
                        <p>Đang tải điểm đón/trả...</p>
                    </div>
                ) : error ? (
                    <BrutalCard className="error-card text-center">
                        <AlertCircle size={48} color="var(--color-red)" style={{marginBottom: "1rem"}}/>
                        <h3>Đã xảy ra lỗi</h3>
                        <p>{error}</p>
                        <BrutalButton variant="primary" onClick={() => navigate(-1)} style={{marginTop: "1rem"}}>
                            Quay lại
                        </BrutalButton>
                    </BrutalCard>
                ) : (
                    <div className="stop-selection-layout">
                        <div className="stop-selection-main">
                            <BrutalCard className="stop-selection-card" noHover>
                                <h3 className="stop-selection-title">
                                    <MapPin size={20}/> Chọn điểm đón
                                </h3>
                                <div className="stop-options">
                                    {pickupStops.length > 0 ? (
                                        pickupStops.map((stop) => (
                                            <label
                                                key={stop.id}
                                                className={`stop-option-label brutal-card ${selectedPickupStopId === String(stop.id) ? "stop-option-label--selected" : ""}`}
                                            >
                                                <input
                                                    type="radio"
                                                    name="pickupStop"
                                                    value={stop.id}
                                                    checked={selectedPickupStopId === String(stop.id)}
                                                    onChange={(e) => setSelectedPickupStopId(e.target.value)}
                                                />
                                                <div className="stop-option-info">
                                                    <strong>{stop.stop?.name || "Điểm đón"}</strong>
                                                    <span>{stop.stop?.address}</span>
                                                </div>
                                            </label>
                                        ))
                                    ) : (
                                        <p className="stop-selection-muted">Không có điểm đón nào.</p>
                                    )}
                                </div>
                            </BrutalCard>

                            <BrutalCard className="stop-selection-card" noHover>
                                <h3 className="stop-selection-title">
                                    <MapPin size={20}/> Chọn điểm trả
                                </h3>
                                <div className="stop-options">
                                    {dropoffStops.length > 0 ? (
                                        dropoffStops.map((stop) => (
                                            <label
                                                key={stop.id}
                                                className={`stop-option-label brutal-card ${selectedDropoffStopId === String(stop.id) ? "stop-option-label--selected" : ""}`}
                                            >
                                                <input
                                                    type="radio"
                                                    name="dropoffStop"
                                                    value={stop.id}
                                                    checked={selectedDropoffStopId === String(stop.id)}
                                                    onChange={(e) => setSelectedDropoffStopId(e.target.value)}
                                                />
                                                <div className="stop-option-info">
                                                    <strong>{stop.stop?.name || "Điểm trả"}</strong>
                                                    <span>{stop.stop?.address}</span>
                                                </div>
                                            </label>
                                        ))
                                    ) : (
                                        <p className="stop-selection-muted">Không có điểm trả nào.</p>
                                    )}
                                </div>
                            </BrutalCard>
                        </div>

                        <BrutalCard className="stop-selection-summary" noHover>
                            <h3 className="stop-selection-title">Tóm tắt</h3>
                            <div className="summary-card__info-row">
                                <span>Số ghế:</span>
                                <strong className="text-mono">{selectedSeatIds?.length || 0}</strong>
                            </div>
                            <div className="summary-card__seats-list">
                                {(selectedSeatCodes || []).map((code) => (
                                    <span key={code} className="brutal-tag text-mono">Ghế {code}</span>
                                ))}
                            </div>
                            <div className="summary-card__divider"></div>
                            <div className="summary-card__info-row total-row">
                                <span>Tạm tính:</span>
                                <span className="total-price text-mono">
                                    {new Intl.NumberFormat("vi-VN").format(totalCost || 0)}đ
                                </span>
                            </div>
                            <BrutalButton
                                variant="primary"
                                size="large"
                                className="brutal-btn--full"
                                onClick={handleContinue}
                            >
                                TIẾP TỤC
                            </BrutalButton>
                        </BrutalCard>
                    </div>
                )}
            </div>
        </div>
    );
}
