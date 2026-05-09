import React, { useState, useRef } from 'react';
import { 
  Star, Ticket, Users, Bus
} from 'lucide-react';
import OverviewHeader from './OverviewHeader';
import CompanyAvatar from './CompanyAvatar';
import DetailedForm from './DetailedForm';
const initialBusCompany = {
  id: "BC001",
  host_Name: "Nguyễn Văn A",
  company_name: "Nhà xe Hoàng Long",
  hotline: "0909123456",
  avatar_url: "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=2069&auto=format&fit=crop", // Ảnh ví dụ thật, không dùng placeholder mờ
  email: "contact@hoanglong.vn",
  policy: "Hủy vé trước 24h hoàn 100% tiền vé. Hủy trước 12h hoàn 50%. Không hoàn tiền nếu hủy sát giờ khởi hành.",
  created_at: "2026-05-09T10:00:00"
};

// Dữ liệu thống kê mô phỏng (doanh nghiệp)
const statsData = [
  { label: "Tổng chuyến xe", value: "1,245", icon: Bus, color: "text-blue-600", bg: "bg-blue-50" },
  { label: "Tổng nhân viên", value: "48", icon: Users, color: "text-emerald-600", bg: "bg-emerald-50" },
  { label: "Vé đã bán (tháng)", value: "8,920", icon: Ticket, color: "text-violet-600", bg: "bg-violet-50" },
  { label: "Đánh giá", value: "4.8/5", icon: Star, color: "text-amber-500", bg: "bg-amber-50" }
];

  

const Overview = () => {
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [formData, setFormData] = useState(initialBusCompany);
  const [tempData, setTempData] = useState(initialBusCompany);

  const handleEdit = () => {
    setTempData(formData);
    setIsEditing(true);
  };

  const handleCancel = () => {
    setFormData(tempData);
    setIsEditing(false);
  };

  const handleSave = () => {
    // Validation cơ bản
    if (!formData.company_name || !formData.hotline || !formData.email) {
      alert("Vui lòng điền đầy đủ các trường bắt buộc.");
      return;
    }

    setIsSaving(true);
    // Giả lập API call
    setTimeout(() => {
      setIsSaving(false);
      setIsEditing(false);
      setTempData(formData);
    }, 1200);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const formatDate = (dateString) => {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(dateString).toLocaleDateString('vi-VN', options);
  };

  const fileInputRef = useRef(null);
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      // Kiểm tra định dạng (tùy chọn)
      if (!file.type.startsWith('image/')) {
        alert('Vui lòng chọn file hình ảnh!');
        return;
      }
      // Tạo URL tạm thời để preview
      const previewUrl = URL.createObjectURL(file);
      setFormData(prev => ({ ...prev, avatar_url: previewUrl }));
    }
  };

  const triggerFileSelect = () => {
    if (isEditing) fileInputRef.current.click();
  };

  return (
    <div className="min-h-screen bg-slate-50 p-4 md:p-8 text-slate-900 font-sans">
      <div className="max-w-7xl mx-auto space-y-6">
        
        <OverviewHeader 
          isEditing={isEditing}
          handleEdit={handleEdit}
          handleCancel={handleCancel}
          handleSave={handleSave}
          isSaving={isSaving} />

        {/* Stats Section */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {statsData.map((stat, index) => (
            <div 
              key={index} 
              className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow duration-300 group"
            >
              <div className="flex items-center gap-4">
                <div className={`p-3 rounded-xl ${stat.bg} ${stat.color} group-hover:scale-110 transition-transform duration-300`}>
                  <stat.icon className="w-6 h-6" />
                </div>
                <div>
                  <p className="text-sm text-slate-500 font-medium">{stat.label}</p>
                  <h3 className="text-2xl font-bold text-slate-900 mt-0.5">{stat.value}</h3>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Main Content Split Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
           
          {/* Left Column: Avatar & Quick Info */}
          <CompanyAvatar formData={formData} formatDate={formatDate} 
            triggerFileSelect={triggerFileSelect} fileInputRef={fileInputRef} 
            handleFileChange={handleFileChange} isEditing={isEditing} />

          {/* Right Column: Detailed Form */}
          <DetailedForm
            formData={formData}
            isEditing={isEditing}
            handleChange={handleChange}
          />
        </div>
      </div>
    </div>
  );
};

export default Overview;