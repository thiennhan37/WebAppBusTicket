import React, { useState, useEffect } from "react";
import SearchForm from "../../components/SearchForm";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import { ShieldCheck, Headphones, Zap, MapPin, Bus, Ticket, Star, Gift } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { getCompaniesWithHighRating } from "../../services/companyService";
import "./HomePage.css";



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
  const [companies, setCompanies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCompanies = async () => {
      try {
        const response = await getCompaniesWithHighRating();
        setCompanies(response.data.result || []);
      } catch (err) {
        console.error("Failed to fetch high rated companies:", err);
        setError("Không thể tải danh sách nhà xe đánh giá cao.");
      } finally {
        setLoading(false);
      }
    };
    fetchCompanies();
  }, []);

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

      {/* High-Rated Companies */}
      <section className="home-routes section">
        <div className="container">
          <h2 className="section-title text-center">Nhà xe đánh giá cao</h2>
          
          {loading && (
            <div className="page-loader text-center" style={{ padding: "2rem" }}>
              <div className="brutal-spinner" style={{ margin: "0 auto 1rem" }}></div>
              <p className="text-mono">Đang tải danh sách nhà xe...</p>
            </div>
          )}

          {error && (
            <div className="brutal-card text-center" style={{ padding: "2rem", backgroundColor: "var(--color-white)" }}>
              <p className="text-mono" style={{ color: "var(--color-red)" }}>{error}</p>
            </div>
          )}

          {!loading && !error && companies.length === 0 && (
            <div className="brutal-card text-center" style={{ padding: "2rem", backgroundColor: "var(--color-white)" }}>
              <p className="text-mono">Chưa có đánh giá nào cho nhà xe.</p>
            </div>
          )}

          {!loading && !error && companies.length > 0 && (
            <div className="routes-grid">
              {companies.map((company) => (
                <BrutalCard key={company.id} className="company-card">
                  <div className="company-card__media">
                    {company.avatarUrl ? (
                      <img src={company.avatarUrl} alt={company.CompanyName} className="company-card__img" />
                    ) : (
                      <div className="company-card__emoji">🚌</div>
                    )}
                  </div>
                  <div className="company-card__body">
                    <h3 className="company-card__title">{company.CompanyName}</h3>
                    
                    <div className="company-card__rating">
                      <Star size={16} className="company-card__star" fill="#FFE600" />
                      <span className="company-card__stars-val">{company.avgStars.toFixed(1)}</span>
                      <span className="company-card__count">({company.ratingCount} đánh giá)</span>
                    </div>

                    <div className="company-card__details text-mono">
                      <span>Hotline: {company.hotline || "N/A"}</span>
                      <span>Email: {company.email || "N/A"}</span>
                    </div>

                    <div className="company-card__footer">
                      <BrutalButton
                        variant="primary"
                        onClick={() => {
                          const searchSection = document.querySelector(".home-search-section");
                          if (searchSection) {
                            searchSection.scrollIntoView({ behavior: "smooth" });
                          }
                        }}
                      >
                        ĐẶT VÉ NGAY
                      </BrutalButton>
                    </div>
                  </div>
                </BrutalCard>
              ))}
            </div>
          )}
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
