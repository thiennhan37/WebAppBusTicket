import {useState, useEffect, useRef} from "react";
import {useNavigate} from "react-router-dom";
import {Search, ArrowLeftRight, MapPin, Calendar, Loader} from "lucide-react";
import {searchProvinces} from "../services/provinceService";
import {searchTrips} from "../services/tripService";
import {toast} from "sonner";
import "./SearchForm.css";

export default function SearchForm({initialValues}) {
    const navigate = useNavigate();

    // Helper to get province name by ID from localStorage
    const getProvinceName = (id) => {
        if (!id) return "";
        try {
            const map = JSON.parse(localStorage.getItem("provincesMap") || "{}");
            return map[id] || id;
        } catch {
            return id;
        }
    };

    const [startProvince, setStartProvince] = useState(initialValues?.startProvince || "");
    const [endProvince, setEndProvince] = useState(initialValues?.endProvince || "");
    const [date, setDate] = useState(initialValues?.date || getTodayString());
    const [startProvinces, setStartProvinces] = useState([]);
    const [endProvinces, setEndProvinces] = useState([]);
    const [showStartDropdown, setShowStartDropdown] = useState(false);
    const [showEndDropdown, setShowEndDropdown] = useState(false);
    const [startInput, setStartInput] = useState(getProvinceName(initialValues?.startProvince));
    const [endInput, setEndInput] = useState(getProvinceName(initialValues?.endProvince));
    const [searching, setSearching] = useState(false);
    const startRef = useRef(null);
    const endRef = useRef(null);

    function getTodayString() {
        const today = new Date();
        const dd = String(today.getDate()).padStart(2, "0");
        const mm = String(today.getMonth() + 1).padStart(2, "0");
        const yyyy = today.getFullYear();
        return `${yyyy}-${mm}-${dd}`;
    }

    function formatDateForApi(dateStr) {
        const [yyyy, mm, dd] = dateStr.split("-");
        return `${dd}/${mm}/${yyyy}`;
    }

    // Keep state in sync with initialValues changes (e.g. popular route click)
    useEffect(() => {
        if (initialValues) {
            if (initialValues.startProvince) {
                setStartProvince(initialValues.startProvince);
                setStartInput(getProvinceName(initialValues.startProvince));
            }
            if (initialValues.endProvince) {
                setEndProvince(initialValues.endProvince);
                setEndInput(getProvinceName(initialValues.endProvince));
            }
            if (initialValues.date) {
                setDate(initialValues.date);
            }
        }
    }, [initialValues]);

    // Fetch provinces and save to local storage
    useEffect(() => {
        const fetchProvinces = async (keyword, setter) => {
            try {
                const res = await searchProvinces(keyword);
                const list = res.data.result || [];
                setter(list);

                // Save the received provinces (id and name mapping) to localStorage
                const currentMap = JSON.parse(localStorage.getItem("provincesMap") || "{}");
                list.forEach((p) => {
                    if (p.id && p.name) {
                        currentMap[p.id] = p.name;
                    }
                });
                localStorage.setItem("provincesMap", JSON.stringify(currentMap));
            } catch {
                setter([]);
            }
        };

        const timer = setTimeout(() => {
            if (showStartDropdown) {
                fetchProvinces(startInput, setStartProvinces);
            }
        }, 300);
        return () => clearTimeout(timer);
    }, [startInput, showStartDropdown]);

    useEffect(() => {
        const fetchProvinces = async (keyword, setter) => {
            try {
                const res = await searchProvinces(keyword);
                const list = res.data.result || [];
                setter(list);

                // Save the received provinces (id and name mapping) to localStorage
                const currentMap = JSON.parse(localStorage.getItem("provincesMap") || "{}");
                list.forEach((p) => {
                    if (p.id && p.name) {
                        currentMap[p.id] = p.name;
                    }
                });
                localStorage.setItem("provincesMap", JSON.stringify(currentMap));
            } catch {
                setter([]);
            }
        };

        const timer = setTimeout(() => {
            if (showEndDropdown) {
                fetchProvinces(endInput, setEndProvinces);
            }
        }, 300);
        return () => clearTimeout(timer);
    }, [endInput, showEndDropdown]);

    // Click outside handler
    useEffect(() => {
        const handleClick = (e) => {
            if (startRef.current && !startRef.current.contains(e.target)) {
                setShowStartDropdown(false);
            }
            if (endRef.current && !endRef.current.contains(e.target)) {
                setShowEndDropdown(false);
            }
        };
        document.addEventListener("mousedown", handleClick);
        return () => document.removeEventListener("mousedown", handleClick);
    }, []);

    const handleSwap = () => {
        const tempProvince = startProvince;
        const tempInput = startInput;
        setStartProvince(endProvince);
        setStartInput(endInput);
        setEndProvince(tempProvince);
        setEndInput(tempInput);

        localStorage.setItem("selectedStartProvinceId", endProvince);
        localStorage.setItem("selectedStartProvinceName", endInput);
        localStorage.setItem("selectedEndProvinceId", tempProvince);
        localStorage.setItem("selectedEndProvinceName", tempInput);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        // Validate
        if (!startProvince) {
            toast.error("Vui lòng chọn nơi xuất phát từ danh sách gợi ý!");
            return;
        }
        if (!endProvince) {
            toast.error("Vui lòng chọn nơi đến từ danh sách gợi ý!");
            return;
        }
        if (!date) {
            toast.error("Vui lòng chọn ngày đi!");
            return;
        }
        if (startProvince === endProvince) {
            toast.error("Nơi xuất phát và nơi đến không được trùng nhau!");
            return;
        }

        const formattedDate = formatDateForApi(date);
        setSearching(true);

        try {
            // Gọi API trực tiếp để xác nhận backend response
            await searchTrips({
                startProvince,
                endProvince,
                date: formattedDate,
            });

            // Nếu thành công → navigate sang trang kết quả
            const params = new URLSearchParams({
                startProvince,
                endProvince,
                date: formattedDate,
            });
            navigate(`/khachhang/ket-qua?${params.toString()}`);
        } catch (err) {
            console.error("Search error:", err);
            // Nếu API lỗi, vẫn navigate nhưng cảnh báo
            if (err.response?.status === 404 || err.response?.status === 204) {
                toast.info("Không tìm thấy chuyến xe phù hợp cho tuyến đường này.");
                const params = new URLSearchParams({
                    startProvince,
                    endProvince,
                    date: formattedDate,
                });
                navigate(`/khachhang/ket-qua?${params.toString()}`);
            } else {
                toast.error("Máy chủ không phản hồi. Vui lòng kiểm tra kết nối!");
            }
        } finally {
            setSearching(false);
        }
    };

    const selectProvince = (province, type) => {
        try {
            const map = JSON.parse(localStorage.getItem("provincesMap") || "{}");
            map[province.id] = province.name;
            localStorage.setItem("provincesMap", JSON.stringify(map));
        } catch (e) {
            console.error(e);
        }

        if (type === "start") {
            setStartProvince(province.id);
            setStartInput(province.name);
            setShowStartDropdown(false);
            localStorage.setItem("selectedStartProvinceId", province.id);
            localStorage.setItem("selectedStartProvinceName", province.name);
        } else {
            setEndProvince(province.id);
            setEndInput(province.name);
            setShowEndDropdown(false);
            localStorage.setItem("selectedEndProvinceId", province.id);
            localStorage.setItem("selectedEndProvinceName", province.name);
        }
    };


    const handleProvinceFocus = (e, setShowDropdown) => {
        e.target.readOnly = false;
        setShowDropdown(true);
    };

    return (
        <form className="search-form" onSubmit={handleSubmit} id="search-form" autoComplete="off">
            <div className="search-form__title">
                <div className="search-form__title-icon">
                    <Search size={16}/>
                </div>
                TÌM CHUYẾN XE
            </div>

            <div className="search-form__fields">
                {/* Start Province */}
                <div className="search-form__field" ref={startRef}>
                    <label className="brutal-label">
                        <MapPin size={12} style={{display: "inline", marginRight: 4}}/>
                        Nơi xuất phát
                    </label>
                    <div className="search-form__dropdown-wrapper">
                        <input
                            type="text"
                            className="brutal-input"
                            name="vexedat-departure-query"
                            placeholder="Chọn nơi đi..."
                            value={startInput}
                            autoComplete="off"
                            autoCorrect="off"
                            autoCapitalize="off"
                            spellCheck={false}
                            role="combobox"
                            aria-autocomplete="list"
                            aria-expanded={showStartDropdown}
                            data-lpignore="true"
                            data-1p-ignore
                            readOnly
                            onChange={(e) => {
                                setStartInput(e.target.value);
                                setStartProvince("");
                                setShowStartDropdown(true);
                            }}
                            onFocus={(e) => handleProvinceFocus(e, setShowStartDropdown)}
                            id="input-start-province"
                        />
                        {showStartDropdown && (
                            <div className="search-form__dropdown">
                                {startProvinces.length > 0 ? (
                                    startProvinces.map((p) => (
                                        <div
                                            key={p.id}
                                            className="search-form__dropdown-item"
                                            onClick={() => selectProvince(p, "start")}
                                        >
                                            {p.name}
                                        </div>
                                    ))
                                ) : (
                                    <div className="search-form__dropdown-empty">
                                        Nhập tên tỉnh/thành phố
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                </div>

                {/* Swap button */}
                <button
                    type="button"
                    className="search-form__swap-btn"
                    onClick={handleSwap}
                    title="Đổi chiều"
                >
                    <ArrowLeftRight size={16}/>
                </button>

                {/* End Province */}
                <div className="search-form__field" ref={endRef}>
                    <label className="brutal-label">
                        <MapPin size={12} style={{display: "inline", marginRight: 4}}/>
                        Nơi đến
                    </label>
                    <div className="search-form__dropdown-wrapper">
                        <input
                            type="text"
                            className="brutal-input"
                            name="vexedat-arrival-query"
                            placeholder="Chọn nơi đến..."
                            value={endInput}
                            autoComplete="off"
                            autoCorrect="off"
                            autoCapitalize="off"
                            spellCheck={false}
                            role="combobox"
                            aria-autocomplete="list"
                            aria-expanded={showEndDropdown}
                            data-lpignore="true"
                            data-1p-ignore
                            readOnly
                            onChange={(e) => {
                                setEndInput(e.target.value);
                                setEndProvince("");
                                setShowEndDropdown(true);
                            }}
                            onFocus={(e) => handleProvinceFocus(e, setShowEndDropdown)}
                            id="input-end-province"
                        />
                        {showEndDropdown && (
                            <div className="search-form__dropdown">
                                {endProvinces.length > 0 ? (
                                    endProvinces.map((p) => (
                                        <div
                                            key={p.id}
                                            className="search-form__dropdown-item"
                                            onClick={() => selectProvince(p, "end")}
                                        >
                                            {p.name}
                                        </div>
                                    ))
                                ) : (
                                    <div className="search-form__dropdown-empty">
                                        Nhập tên tỉnh/thành phố
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                </div>

                {/* Date */}
                <div className="search-form__field">
                    <label className="brutal-label">
                        <Calendar size={12} style={{display: "inline", marginRight: 4}}/>
                        Ngày đi
                    </label>
                    <input
                        type="date"
                        className="brutal-input"
                        name="vexedat-travel-date"
                        value={date}
                        autoComplete="off"
                        onChange={(e) => setDate(e.target.value)}
                        min={getTodayString()}
                        id="input-date"
                    />
                </div>

                {/* Submit: Xóa class 'brutal-btn--large' để nút không bị quá to */}
                <button
                    type="submit"
                    className="brutal-btn brutal-btn--primary search-form__submit-btn"
                    id="btn-search"
                    disabled={searching}
                >
                    {searching ? (
                        <>
                            <Loader size={18} className="search-spin"/>
                            ĐANG TÌM...
                        </>
                    ) : (
                        <>
                            <Search size={18} style={{marginRight: 6}}/>
                            TÌM CHUYẾN
                        </>
                    )}
                </button>
            </div>
        </form>
    );
}