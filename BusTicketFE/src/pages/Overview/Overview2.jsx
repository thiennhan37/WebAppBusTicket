import React, { useState, useRef } from 'react';
import { 
  Building2, Phone, Mail, FileText, User, 
  Calendar, Edit2, Save, X, Loader2, 
  Star, Ticket, Users, Bus, Camera, Image as ImageIcon
} from 'lucide-react';

const initialBusCompany = {
  id: "BC001",
  host_Name: "Nguyễn Văn A",
  company_name: "Nhà xe Hoàng Long",
  hotline: "0909123456",
  avatar_url: "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=2069&auto=format&fit=crop",
  email: "contact@hoanglong.vn",
  policy: "Hủy vé trước 24h hoàn 100% tiền vé...",
  created_at: "2026-05-09T10:00:00"
};

const Overview1 = () => {
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [formData, setFormData] = useState(initialBusCompany);
  const [tempData, setTempData] = useState(initialBusCompany);
  
  // Ref để trigger input file ẩn
  const fileInputRef = useRef(null);

  const handleEdit = () => {
    setTempData(formData);
    setIsEditing(true);
  };

  const handleCancel = () => {
    setFormData(tempData);
    setIsEditing(false);
  };

  const handleSave = () => {
    setIsSaving(true);
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

  // Xử lý khi chọn ảnh từ máy tính
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
        
        {/* Header Section */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold">Tổng quan doanh nghiệp</h1>
            <p className="text-slate-500 text-sm mt-1">Cập nhật hồ sơ và ảnh đại diện nhà xe</p>
          </div>
          <div className="flex items-center gap-3">
            {!isEditing ? (
              <button onClick={handleEdit} className="flex items-center gap-2 px-4 py-2 bg-slate-900 text-white rounded-lg hover:bg-slate-800 transition-all font-medium">
                <Edit2 className="w-4 h-4" /> Chỉnh sửa hồ sơ
              </button>
            ) : (
              <>
                <button onClick={handleCancel} disabled={isSaving} className="flex items-center gap-2 px-4 py-2 bg-white text-slate-700 border border-slate-200 rounded-lg hover:bg-slate-50 transition-all font-medium">
                  <X className="w-4 h-4" /> Hủy
                </button>
                <button onClick={handleSave} disabled={isSaving} className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all font-medium shadow-blue-100 shadow-lg">
                  {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                  Lưu thay đổi
                </button>
              </>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Cột trái: Avatar Upload Section */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-3xl p-8 border border-slate-100 shadow-sm flex flex-col items-center text-center relative overflow-hidden">
              <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-b from-blue-50/50 to-transparent"></div>
              
              {/* Avatar Container */}
              <div className="relative z-10 mt-4 group">
                <div 
                  onClick={triggerFileSelect}
                  className={`relative w-48 h-48 rounded-full border-[12px] border-white shadow-xl overflow-hidden bg-slate-100 ${isEditing ? 'cursor-pointer hover:opacity-90' : ''}`}
                >
                  {formData.avatar_url ? (
                    <img src={formData.avatar_url} alt="Avatar" className="w-full h-full object-cover" />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center"><ImageIcon className="w-12 h-12 text-slate-300" /></div>
                  )}

                  {/* Overlay khi Edit */}
                  {isEditing && (
                    <div className="absolute inset-0 bg-black/40 flex flex-col items-center justify-center text-white opacity-0 group-hover:opacity-100 transition-opacity">
                      <Camera className="w-8 h-8 mb-1" />
                      <span className="text-xs font-medium">Thay đổi ảnh</span>
                    </div>
                  )}
                </div>

                {/* Input File ẩn */}
                <input 
                  type="file" 
                  ref={fileInputRef} 
                  onChange={handleFileChange} 
                  className="hidden" 
                  accept="image/*" 
                />
              </div>

              <div className="relative z-10 mt-6">
                <h2 className="text-xl font-bold">{formData.company_name}</h2>
                <p className="text-blue-600 text-sm font-medium mt-1">{formData.id}</p>
                
                {isEditing && (
                  <p className="text-xs text-slate-400 mt-4 italic">* Click vào ảnh để tải ảnh mới từ máy tính</p>
                )}
              </div>
            </div>
          </div>

          {/* Cột phải: Form thông tin */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-3xl p-6 md:p-8 border border-slate-100 shadow-sm">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Các trường input tương tự như trước nhưng bỏ input URL */}
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Tên công ty *</label>
                  <input
                    type="text"
                    name="company_name"
                    value={formData.company_name}
                    onChange={handleChange}
                    disabled={!isEditing}
                    className={`w-full px-4 py-2.5 rounded-xl border ${isEditing ? 'border-slate-300 bg-white focus:ring-2 focus:ring-blue-500/20' : 'border-transparent bg-slate-50 cursor-not-allowed'}`}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Người đại diện</label>
                  <input
                    type="text"
                    name="host_Name"
                    value={formData.host_Name}
                    onChange={handleChange}
                    disabled={!isEditing}
                    className={`w-full px-4 py-2.5 rounded-xl border ${isEditing ? 'border-slate-300 bg-white' : 'border-transparent bg-slate-50'}`}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Hotline</label>
                  <input
                    type="text"
                    name="hotline"
                    value={formData.hotline}
                    onChange={handleChange}
                    disabled={!isEditing}
                    className={`w-full px-4 py-2.5 rounded-xl border ${isEditing ? 'border-slate-300 bg-white' : 'border-transparent bg-slate-50'}`}
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Chính sách</label>
                  <textarea
                    name="policy"
                    value={formData.policy}
                    onChange={handleChange}
                    disabled={!isEditing}
                    rows={4}
                    className={`w-full px-4 py-2.5 rounded-xl border ${isEditing ? 'border-slate-300 bg-white' : 'border-transparent bg-slate-50'}`}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Overview1;