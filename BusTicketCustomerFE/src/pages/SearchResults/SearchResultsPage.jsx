import React, { useState, useEffect } from "react";
import { useSearchParams, Link } from "react-router-dom";
import { searchTrips } from "../../services/tripService";
import TripCard from "../../components/TripCard";
import SearchForm from "../../components/SearchForm";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import { Filter, ArrowUpDown, ChevronDown, RefreshCw, AlertTriangle } from "lucide-react";
import "./SearchResultsPage.css";

export default function SearchResultsPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [trips, setTrips] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Search parameters from URL
  const startProvince = searchParams.get("startProvince") || "";
  const endProvince = searchParams.get("endProvince") || "";
  const date = searchParams.get("date") || "";

  // Filter states
  const [selectedCompanies, setSelectedCompanies] = useState([]);
  const [selectedBusTypes, setSelectedBusTypes] = useState([]);
  const [priceRange, setPriceRange] = useState(1000000); // Max price slider
  const [minPrice, setMinPrice] = useState(0);
  const [departureTimeRange, setDepartureTimeRange] = useState("all"); // all, morning, afternoon, evening
  const [sortBy, setSortBy] = useState("departureTimeAsc"); // departureTimeAsc, priceAsc, priceDesc, ratingDesc

  // List of unique companies/types from fetched trips for sidebar filters
  const [companiesList, setCompaniesList] = useState([]);
  const [busTypesList, setBusTypesList] = useState([]);

  useEffect(() => {
    const fetchTripsList = async () => {
      if (!startProvince || !endProvince || !date) {
        setLoading(false);
        return;
      }
      setLoading(true);
      setError(null);
      try {
        const response = await searchTrips({
          startProvince,
          endProvince,
          date,
        });
        const result = response.data.result;
        const fetchedTrips = Array.isArray(result)
          ? result
          : result?.content || [];
        setTrips(fetchedTrips);

        // Extract filter options
        const companies = [...new Set(fetchedTrips.map((t) => t.busCompanyName))].filter(Boolean);
        const types = [...new Set(fetchedTrips.map((t) => t.busType))].filter(Boolean);
        setCompaniesList(companies);
        setBusTypesList(types);

        // Auto set max price from results if trips exist
        if (fetchedTrips.length > 0) {
          const max = Math.max(...fetchedTrips.map((t) => t.price));
          setPriceRange(max);
        }
      } catch (err) {
        console.error("Search trips error:", err);
        setError("Có lỗi xảy ra khi tìm kiếm chuyến xe. Vui lòng thử lại!");
      } finally {
        setLoading(false);
      }
    };

    fetchTripsList();
  }, [startProvince, endProvince, date]);

  // Handle filter changes
  const handleCompanyToggle = (company) => {
    setSelectedCompanies((prev) =>
      prev.includes(company) ? prev.filter((c) => c !== company) : [...prev, company]
    );
  };

  const handleBusTypeToggle = (type) => {
    setSelectedBusTypes((prev) =>
      prev.includes(type) ? prev.filter((t) => t !== type) : [...prev, type]
    );
  };

  // Reset all filters
  const handleResetFilters = () => {
    setSelectedCompanies([]);
    setSelectedBusTypes([]);
    setDepartureTimeRange("all");
    if (trips.length > 0) {
      const max = Math.max(...trips.map((t) => t.price));
      setPriceRange(max);
    }
  };

  // Filter & Sort Logic
  const getFilteredAndSortedTrips = () => {
    let result = [...trips];

    // Filter by Company
    if (selectedCompanies.length > 0) {
      result = result.filter((t) => selectedCompanies.includes(t.busCompanyName));
    }

    // Filter by Bus Type
    if (selectedBusTypes.length > 0) {
      result = result.filter((t) => selectedBusTypes.includes(t.busType));
    }

    // Filter by Price
    result = result.filter((t) => t.price <= priceRange);

    // Filter by Departure Time
    if (departureTimeRange !== "all") {
      result = result.filter((t) => {
        if (!t.departureTime) return false;
        const hour = parseInt(t.departureTime.split(":")[0], 10);
        if (departureTimeRange === "morning") return hour >= 0 && hour < 12;
        if (departureTimeRange === "afternoon") return hour >= 12 && hour < 18;
        if (departureTimeRange === "evening") return hour >= 18 && hour <= 23;
        return true;
      });
    }

    // Sort
    result.sort((a, b) => {
      if (sortBy === "departureTimeAsc") {
        return (a.departureTime || "").localeCompare(b.departureTime || "");
      }
      if (sortBy === "priceAsc") {
        return a.price - b.price;
      }
      if (sortBy === "priceDesc") {
        return b.price - a.price;
      }
      if (sortBy === "ratingDesc") {
        return (b.rating || 0) - (a.rating || 0);
      }
      return 0;
    });

    return result;
  };

  const filteredTrips = getFilteredAndSortedTrips();

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

  const startProvinceName = getProvinceName(startProvince);
  const endProvinceName = getProvinceName(endProvince);

  return (
    <div className="search-results-page">
      {/* Top Search bar indicator */}
      <div className="search-summary-bar">
        <div className="container search-summary-bar__inner">
          <div className="search-summary-info">
            <span className="search-summary-info__route">
              {startProvinceName || "Nơi đi"} ➔ {endProvinceName || "Nơi đến"}
            </span>
            <span className="search-summary-info__date text-mono">{date}</span>
          </div>
          <details className="search-summary-edit">
            <summary className="brutal-btn">THAY ĐỔI TÌM KIẾM</summary>
            <div className="search-summary-form-dropdown brutal-card">
              <SearchForm initialValues={{ startProvince, endProvince, date }} />
            </div>
          </details>
        </div>
      </div>

      <div className="container">
        <div className="search-results-layout">
          {/* Sidebar Filter */}
          <aside className="search-sidebar">
            <BrutalCard className="filter-card" noHover>
              <div className="filter-card__header">
                <h3 className="filter-card__title">
                  <Filter size={18} />
                  BỘ LỌC CHUYẾN
                </h3>
                <button className="filter-card__reset text-mono" onClick={handleResetFilters}>
                  XÓA LỌC
                </button>
              </div>

              {/* Price range filter */}
              <div className="filter-group">
                <span className="brutal-label">Giá tối đa</span>
                <div className="price-slider-wrapper">
                  <input
                    type="range"
                    min="50000"
                    max="1000000"
                    step="10000"
                    value={priceRange}
                    onChange={(e) => setPriceRange(parseInt(e.target.value))}
                    className="brutal-range-slider"
                  />
                  <div className="price-slider-values text-mono">
                    <span>50K</span>
                    <span className="current-price">
                      {new Intl.NumberFormat("vi-VN").format(priceRange)}đ
                    </span>
                    <span>1M</span>
                  </div>
                </div>
              </div>

              {/* Departure Time filter */}
              <div className="filter-group">
                <span className="brutal-label">Giờ khởi hành</span>
                <div className="filter-radio-group">
                  <label className="filter-checkbox-label">
                    <input
                      type="radio"
                      name="timeRange"
                      checked={departureTimeRange === "all"}
                      onChange={() => setDepartureTimeRange("all")}
                    />
                    <span>Tất cả thời gian</span>
                  </label>
                  <label className="filter-checkbox-label">
                    <input
                      type="radio"
                      name="timeRange"
                      checked={departureTimeRange === "morning"}
                      onChange={() => setDepartureTimeRange("morning")}
                    />
                    <span>Sáng (00:00 - 12:00)</span>
                  </label>
                  <label className="filter-checkbox-label">
                    <input
                      type="radio"
                      name="timeRange"
                      checked={departureTimeRange === "afternoon"}
                      onChange={() => setDepartureTimeRange("afternoon")}
                    />
                    <span>Chiều (12:00 - 18:00)</span>
                  </label>
                  <label className="filter-checkbox-label">
                    <input
                      type="radio"
                      name="timeRange"
                      checked={departureTimeRange === "evening"}
                      onChange={() => setDepartureTimeRange("evening")}
                    />
                    <span>Tối (18:00 - 24:00)</span>
                  </label>
                </div>
              </div>

              {/* Company filter */}
              {companiesList.length > 0 && (
                <div className="filter-group">
                  <span className="brutal-label">Nhà xe</span>
                  <div className="filter-checkbox-group">
                    {companiesList.map((company) => (
                      <label key={company} className="filter-checkbox-label">
                        <input
                          type="checkbox"
                          checked={selectedCompanies.includes(company)}
                          onChange={() => handleCompanyToggle(company)}
                        />
                        <span>{company}</span>
                      </label>
                    ))}
                  </div>
                </div>
              )}

              {/* Bus type filter */}
              {busTypesList.length > 0 && (
                <div className="filter-group">
                  <span className="brutal-label">Loại xe</span>
                  <div className="filter-checkbox-group">
                    {busTypesList.map((type) => (
                      <label key={type} className="filter-checkbox-label">
                        <input
                          type="checkbox"
                          checked={selectedBusTypes.includes(type)}
                          onChange={() => handleBusTypeToggle(type)}
                        />
                        <span>{type}</span>
                      </label>
                    ))}
                  </div>
                </div>
              )}
            </BrutalCard>
          </aside>

          {/* Main Trip List */}
          <main className="search-main">
            {/* Sort toolbar */}
            <div className="sort-toolbar brutal-card">
              <div className="sort-toolbar__label text-mono">
                <ArrowUpDown size={14} /> SẮP XẾP THEO:
              </div>
              <div className="sort-toolbar__options">
                <button
                  className={`sort-option ${sortBy === "departureTimeAsc" ? "sort-option--active" : ""}`}
                  onClick={() => setSortBy("departureTimeAsc")}
                >
                  Giờ chạy
                </button>
                <button
                  className={`sort-option ${sortBy === "priceAsc" ? "sort-option--active" : ""}`}
                  onClick={() => setSortBy("priceAsc")}
                >
                  Giá tăng dần
                </button>
                <button
                  className={`sort-option ${sortBy === "priceDesc" ? "sort-option--active" : ""}`}
                  onClick={() => setSortBy("priceDesc")}
                >
                  Giá giảm dần
                </button>
                <button
                  className={`sort-option ${sortBy === "ratingDesc" ? "sort-option--active" : ""}`}
                  onClick={() => setSortBy("ratingDesc")}
                >
                  Đánh giá cao
                </button>
              </div>
            </div>

            {/* Content states */}
            {loading && (
              <div className="page-loader">
                <div className="brutal-spinner"></div>
                <p>Đang tìm chuyến xe phù hợp...</p>
              </div>
            )}

            {error && (
              <BrutalCard className="error-card text-center">
                <AlertTriangle size={48} color="var(--color-red)" style={{ marginBottom: "1rem" }} />
                <h3>Đã xảy ra lỗi</h3>
                <p>{error}</p>
                <BrutalButton
                  variant="primary"
                  onClick={() => window.location.reload()}
                  style={{ marginTop: "1rem" }}
                >
                  <RefreshCw size={14} /> Thử lại
                </BrutalButton>
              </BrutalCard>
            )}

            {!loading && !error && filteredTrips.length === 0 && (
              <BrutalCard className="empty-results-card text-center" noHover>
                <h3>KHÔNG TÌM THẤY CHUYẾN XE</h3>
                <p>Không có chuyến xe nào khớp với điều kiện tìm kiếm hoặc bộ lọc của bạn.</p>
                <div style={{ marginTop: "1.5rem", display: "flex", gap: "1rem", justifyContent: "center" }}>
                  <BrutalButton variant="primary" onClick={handleResetFilters}>
                    XÓA BỘ LỌC
                  </BrutalButton>
                  <Link to="/khachhang" className="brutal-btn">
                    QUAY LẠI TRANG CHỦ
                  </Link>
                </div>
              </BrutalCard>
            )}

            {!loading && !error && filteredTrips.length > 0 && (
              <div className="trips-list">
                {filteredTrips.map((trip) => (
                  <TripCard key={trip.tripId} trip={trip} />
                ))}
              </div>
            )}
          </main>
        </div>
      </div>
    </div>
  );
}
