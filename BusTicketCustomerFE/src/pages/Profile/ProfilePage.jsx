import React, { useState, useEffect } from "react";
import { useAuth } from "../../context/AuthContext";
import { updateProfile } from "../../services/authService";
import BrutalCard from "../../components/BrutalCard";
import BrutalButton from "../../components/BrutalButton";
import BrutalInput from "../../components/BrutalInput";
import BrutalSelect from "../../components/BrutalSelect";
import { User, ShieldCheck } from "lucide-react";
import { toast } from "sonner";
import "./ProfilePage.css";

export default function ProfilePage() {
  const { user, login } = useAuth();

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [dob, setDob] = useState(""); // input type="date" (yyyy-mm-dd)
  const [gender, setGender] = useState("MALE"); // MALE, FEMALE, OTHER
  const [idRegion, setIdRegion] = useState("+84");
  const [submitting, setSubmitting] = useState(false);

  // Parse backend date (dd/MM/yyyy) to HTML date input format (yyyy-mm-dd)
  // or handle standard ISO string
  const parseBackendDate = (dateVal) => {
    if (!dateVal) return "";
    // If it's dd/MM/yyyy
    if (typeof dateVal === "string" && dateVal.includes("/")) {
      const [dd, mm, yyyy] = dateVal.split("/");
      return `${yyyy}-${mm}-${dd}`;
    }
    // If it's array [yyyy, mm, dd] (sometimes Spring Boot sends dates as arrays)
    if (Array.isArray(dateVal)) {
      const yyyy = dateVal[0];
      const mm = String(dateVal[1]).padStart(2, "0");
      const dd = String(dateVal[2]).padStart(2, "0");
      return `${yyyy}-${mm}-${dd}`;
    }
    // If it's yyyy-mm-dd
    return dateVal;
  };

  // Format yyyy-mm-dd to dd/MM/yyyy for backend UpdateCustomerProfileRequest
  const formatDateForBackend = (dateString) => {
    if (!dateString) return "";
    const [yyyy, mm, dd] = dateString.split("-");
    return `${dd}/${mm}/${yyyy}`;
  };

  useEffect(() => {
    if (user) {
      setFullName(user.fullName || "");
      setEmail(user.email || "");
      setPhone(user.phone || "");
      setGender(user.gender || "MALE");
      setIdRegion(user.idRegion || "+84");
      if (user.dob) {
        setDob(parseBackendDate(user.dob));
      }
    }
  }, [user]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!fullName || !phone || !dob || !idRegion || !gender) {
      toast.error("Vui lòng điền đầy đủ các thông tin bắt buộc!");
      return;
    }

    setSubmitting(true);
    try {
      const payload = {
        fullName,
        phone,
        email,
        dob: formatDateForBackend(dob),
        gender,
        idRegion,
      };
      
      const res = await updateProfile(payload);
      const updatedInfo = res.data.result || res.data;
      
      // Update local storage & context state
      const accessToken = localStorage.getItem("accessToken");
      const refreshToken = localStorage.getItem("refreshToken");
      login(updatedInfo, accessToken, refreshToken);
      
      toast.success("Cập nhật thông tin cá nhân thành công!");
    } catch (err) {
      console.error("Update profile error:", err);
      const errMsg = err.response?.data?.message || "Cập nhật thất bại. Vui lòng thử lại!";
      toast.error(errMsg);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="profile-page">
      <div className="container">
        <div className="profile-layout">
          {/* Profile Sidebar Info card */}
          <div className="profile-info-sidebar">
            <BrutalCard className="user-avatar-card text-center" noHover>
              <div className="avatar-placeholder">
                <User size={48} />
              </div>
              <h3 className="user-displayName text-mono">{user?.fullName || "Khách Hàng"}</h3>
              <span className="user-email-badge brutal-tag">{user?.email}</span>
            </BrutalCard>
          </div>

          {/* Profile form section */}
          <div className="profile-form-main">
            <BrutalCard className="profile-form-card" noHover>
              <h3 className="profile-form-title">Thông tin cá nhân</h3>
              
              <form onSubmit={handleSubmit}>
                <BrutalInput
                  label="Họ và tên"
                  id="profile-fullname"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  required
                />

                <BrutalInput
                  label="Địa chỉ Email (Không thể thay đổi)"
                  id="profile-email"
                  type="email"
                  value={email}
                  disabled
                  style={{ backgroundColor: "var(--color-gray-200)", cursor: "not-allowed" }}
                />

                <div className="phone-row">
                  <div style={{ width: "100px" }}>
                    <BrutalSelect
                      label="Mã vùng"
                      id="profile-region"
                      options={[
                        { value: "+84", label: "+84" },
                        { value: "+1", label: "+1" },
                        { value: "+44", label: "+44" },
                      ]}
                      value={idRegion}
                      onChange={(e) => setIdRegion(e.target.value)}
                    />
                  </div>
                  <div style={{ flex: 1 }}>
                    <BrutalInput
                      label="Số điện thoại"
                      id="profile-phone"
                      type="tel"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div className="gender-dob-row">
                  <div style={{ flex: 1 }}>
                    <BrutalInput
                      label="Ngày sinh"
                      id="profile-dob"
                      type="date"
                      value={dob}
                      onChange={(e) => setDob(e.target.value)}
                      required
                    />
                  </div>
                  <div style={{ width: "160px" }}>
                    <BrutalSelect
                      label="Giới tính"
                      id="profile-gender"
                      options={[
                        { value: "MALE", label: "Nam" },
                        { value: "FEMALE", label: "Nữ" },
                        { value: "OTHER", label: "Khác" },
                      ]}
                      value={gender}
                      onChange={(e) => setGender(e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div style={{ marginTop: "2rem" }}>
                  <BrutalButton
                    type="submit"
                    variant="primary"
                    size="large"
                    disabled={submitting}
                  >
                    {submitting ? "ĐANG LƯU THAY ĐỔI..." : "LƯU THAY ĐỔI"}
                  </BrutalButton>
                </div>
              </form>
            </BrutalCard>
          </div>
        </div>
      </div>
    </div>
  );
}
