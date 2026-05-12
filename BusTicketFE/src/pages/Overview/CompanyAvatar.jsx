import { Building2, Calendar, ImageIcon, Camera } from "lucide-react";

const CompanyAvatar = ({ formData, formatDate, triggerFileSelect, fileInputRef, handleFileChange, isEditing }) => {
    return (
        <div className="lg:col-span-1 space-y-6">
            <div className="bg-white rounded-3xl p-6 border border-slate-100 shadow-sm flex flex-col items-center text-center relative overflow-hidden">
                {/* Decorative background element */}
                <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-r from-blue-50 to-indigo-50"></div>

                <div className="relative z-10 mt-8 mb-4">
                    {/* Bọc trong một div có class 'group' để hiệu ứng hover hoạt động */}
                    <div 
                        onClick={triggerFileSelect} 
                        className={`relative group ${isEditing ? 'cursor-pointer' : ''}`}
                    >
                        {formData.avatarUrl ? (
                            <img
                                src={formData.avatarUrl}
                                alt="Company Avatar"
                                // Sử dụng w-60 (240px) đồng nhất
                                className="w-60 h-60 rounded-full border-[12px] border-white shadow-lg object-cover bg-white"
                            />
                        ) : (
                            <div className="w-60 h-60 rounded-full border-[12px] border-white shadow-lg bg-slate-100 flex items-center justify-center">
                                <ImageIcon className="w-20 h-20 text-slate-400" />
                            </div>
                        )}

                        {/* Edit Overlay - Chỉ hiện khi isEditing = true */}
                        {isEditing && (
                            <div className="absolute inset-0 bg-black/40 flex flex-col items-center justify-center text-white opacity-0 group-hover:opacity-100 transition-opacity rounded-full">
                                <Camera className="w-8 h-8 mb-1" />
                                <span className="text-xs font-medium">Thay ảnh</span>
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

                <div className="relative z-10 w-full">
                    <h2 className="text-xl font-bold text-slate-900">
                        {formData.companyName || 'Tên nhà xe'}</h2>
                    <p className="text-slate-500 text-sm mt-1 flex items-center justify-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-emerald-500"></span>
                        Đang hoạt động
                    </p>

                    <div className="mt-10 pt-6 border-t border-slate-100 space-y-3 text-left">
                        <div className="flex items-center gap-3 text-sm text-slate-600">
                            <Calendar className="w-4 h-4 text-slate-400" />
                            <span>Tham gia: {formatDate(formData.createdAt)}</span>
                        </div>
                        <div className="flex items-center gap-3 text-sm text-slate-600">
                            <Building2 className="w-4 h-4 text-slate-400" />
                            <span>ID Doanh nghiệp: <span className="font-mono bg-slate-100 px-1.5 py-0.5 rounded">
                                {formData.id}</span></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default CompanyAvatar;