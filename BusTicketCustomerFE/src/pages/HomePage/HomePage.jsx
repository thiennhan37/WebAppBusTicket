import React from "react";
import SearchForm from "../../components/SearchForm";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import { ShieldCheck, Headphones, Zap, MapPin, Bus, Ticket, Star, Gift } from "lucide-react";
import { useNavigate } from "react-router-dom";
import "./HomePage.css";

const POPULAR_ROUTES = [
  {
    id: 1,
    start: "Sài Gòn",
    end: "Đà Lạt",
    startId: "HCM",
    endId: "LDO",
    price: 300000,
    distance: "310 km",
    duration: "8 giờ",
    image: "🏔️",
  },
  {
    id: 2,
    start: "Hà Nội",
    end: "Sapa",
    startId: "HNO",
    endId: "LCA",
    price: 350000,
    distance: "320 km",
    duration: "6 giờ",
    image: "⛰️",
  },
  {
    id: 3,
    start: "Sài Gòn",
    end: "Nha Trang",
    startId: "HCM",
    endId: "KHO",
    price: 250000,
    distance: "430 km",
    duration: "9 giờ",
    image: "🏖️",
  },
  {
    id: 4,
    start: "Đà Nẵng",
    end: "Huế",
    startId: "DNG",
    endId: "TTH",
    price: 120000,
    distance: "100 km",
    duration: "2 giờ 30 phút",
    image: "🏰",
  },
];

const PLATFORM_FEATURES = [
  {
    id: 1,
    icon: <Bus size={28} />,
    iconColor: "blue",
    title: "2000+ nhà xe chất lượng cao",
    desc: "5000+ tuyến đường trên toàn quốc, chủ động và đa dạng lựa chọn.",
  },
  {
    id: 2,
    icon: <Ticket size={28} />,
    iconColor: "yellow",
    title: "Đặt vé dễ dàng",
    desc: "Đặt vé chỉ với 60s. Chọn xe yêu thích cực nhanh và thuận tiện.",
  },
  {
    id: 3,
    icon: <ShieldCheck size={28} />,
    iconColor: "green",
    title: "Chắc chắn có chỗ",
    desc: "Hoàn ngay 150% nếu nhà xe không cung cấp dịch vụ vận chuyển, mang đến hành trình trọn vẹn.",
  },
  {
    id: 4,
    icon: <Gift size={28} />,
    iconColor: "red",
    title: "Nhiều ưu đãi",
    desc: "Hàng ngàn ưu đãi cực chất độc quyền tại VeXeDat.",
  },
];

export default function HomePage() {
  const navigate = useNavigate();

  const handleRouteClick = (startId, endId, startName, endName) => {
    const today = new Date();
    const dd = String(today.getDate()).padStart(2, "0");
    const mm = String(today.getMonth() + 1).padStart(2, "0");
    const yyyy = today.getFullYear();
    const dateFormatted = `${dd}/${mm}/${yyyy}`;

    // Store the province name mapping to ensure local storage lookup is set up properly
    try {
      const map = JSON.parse(localStorage.getItem("provincesMap") || "{}");
      map[startId] = startName;
      map[endId] = endName;
      localStorage.setItem("provincesMap", JSON.stringify(map));
    } catch (e) {
      console.error(e);
    }

    const params = new URLSearchParams({
      startProvince: startId,
      endProvince: endId,
      date: dateFormatted,
    });
    navigate(`/khachhang/ket-qua?${params.toString()}`);
  };

  return (
    <div className="home-page">
      {/* Hero Section */}
      <section className="home-hero">
        <div className="container">
          <div className="home-hero__content brutal-card">
            <h1 className="home-hero__title">
              ĐẶT VÉ XE KHÁCH <br />
              <span className="highlight">NHANH CHÓNG & ĐƠN GIẢN</span>
            </h1>
            <p className="home-hero__subtitle text-mono">
              Hệ thống đặt vé xe bus liên tỉnh toàn quốc. Cam kết chất lượng, giữ chỗ 100%.
            </p>
          </div>
        </div>
      </section>

      {/* Search Form Container */}
      <section className="home-search-section">
        <div className="container">
          <div className="search-form-container">
            <SearchForm />
          </div>
        </div>
      </section>

      {/* Popular Routes */}
      <section className="home-routes section">
        <div className="container">
          <h2 className="section-title text-center">Tuyến đường phổ biến</h2>
          <div className="routes-grid">
            {POPULAR_ROUTES.map((route) => (
              <BrutalCard key={route.id} className="route-card">
                <div className="route-card__media">{route.image}</div>
                <div className="route-card__body">
                  <h3 className="route-card__title">
                    {route.start} ➔ {route.end}
                  </h3>
                  <div className="route-card__details text-mono">
                    <span>Khoảng cách: {route.distance}</span>
                    <span>Thời gian: {route.duration}</span>
                  </div>
                  <div className="route-card__footer">
                    <div className="route-card__price">
                      <span className="route-card__price-label brutal-tag">Giá từ</span>
                      <span className="route-card__price-value">
                        {new Intl.NumberFormat("vi-VN").format(route.price)}đ
                      </span>
                    </div>
                    <BrutalButton
                      variant="primary"
                      onClick={() => handleRouteClick(route.startId, route.endId, route.start, route.end)}
                    >
                      TÌM VÉ
                    </BrutalButton>
                  </div>
                </div>
              </BrutalCard>
            ))}
          </div>
        </div>
      </section>

      {/* Platform Features — "Nền tảng kết nối người dùng và nhà xe" */}
      <section className="home-platform section">
        <div className="container">
          <div className="platform-header">
            <h2 className="platform-title">Nền tảng kết nối người dùng và nhà xe</h2>
          </div>
          <div className="platform-grid">
            {PLATFORM_FEATURES.map((feat) => (
              <div key={feat.id} className="platform-card brutal-card brutal-card--no-hover">
                <div className={`platform-card__icon platform-card__icon--${feat.iconColor}`}>
                  {feat.icon}
                </div>
                <div className="platform-card__content">
                  <h3 className="platform-card__title">{feat.title}</h3>
                  <p className="platform-card__desc">{feat.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
