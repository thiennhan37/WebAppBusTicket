import { Building2, Phone, Mail, FileText, User, Image as ImageIcon } from 'lucide-react';

const DetailedForm = ({formData, isEditing, handleChange}) => {
    return (
        <div className="lg:col-span-2">
            <div className="bg-white rounded-3xl p-6 md:p-8 border border-slate-100 shadow-sm">
              <h3 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
                <FileText className="w-5 h-5 text-blue-500" />
                Chi tiết hồ sơ
              </h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                
                {/* Tên công ty */}
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Tên công ty / Nhà xe *</label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Building2 className="w-4 h-4 text-slate-400" />
                    </div>
                    <input
                      type="text"
                      name="company_name"
                      value={formData.company_name}
                      onChange={handleChange}
                      disabled={true}
                      className={`block w-full pl-10 pr-4 py-2.5 sm:text-sm rounded-xl transition-all 
                       bg-slate-50 border-transparent text-slate-600 cursor-not-allowed`}
                      placeholder="Nhập tên công ty"
                    />
                  </div>
                </div>

                {/* Tên chủ nhà xe */}
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Người đại diện *</label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <User className="w-4 h-4 text-slate-400" />
                    </div>
                    <input
                      type="text"
                      name="host_Name"
                      value={formData.host_Name}
                      onChange={handleChange}
                      disabled={true}
                      className={`block w-full pl-10 pr-4 py-2.5 sm:text-sm rounded-xl transition-all 
                        bg-slate-50 border-transparent text-slate-600 cursor-not-allowed`}
                    />
                  </div>
                </div>

                {/* Hotline */}
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Hotline hỗ trợ *</label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Phone className="w-4 h-4 text-slate-400" />
                    </div>
                    <input
                      type="text"
                      name="hotline"
                      value={formData.hotline}
                      onChange={handleChange}
                      disabled={true}
                      className={`block w-full pl-10 pr-4 py-2.5 sm:text-sm rounded-xl transition-all
                         bg-slate-50 border-transparent text-slate-600 cursor-not-allowed`}
                    /> 
                  </div>
                </div>

                {/* Email */}
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Email liên hệ *</label>
                  <div className="relative">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Mail className="w-4 h-4 text-slate-400" />
                    </div>
                    <input
                      type="email"
                      name="email"
                      value={formData.email}
                      onChange={handleChange}
                      disabled={true}
                      className={`block w-full pl-10 pr-4 py-2.5 sm:text-sm rounded-xl transition-all ${
                          'bg-slate-50 border-transparent text-slate-600 cursor-not-allowed'
                      }`}
                    />
                  </div>
                </div>

                {/* Chính sách */}
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Chính sách nhà xe</label>
                  <textarea
                    name="policy"
                    value={formData.policy}
                    onChange={handleChange}
                    disabled={!isEditing}
                    rows={4}
                    className={`block w-full p-4 sm:text-sm rounded-xl transition-all ${
                      isEditing 
                        ? 'bg-white border-slate-300 border focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 text-slate-900 resize-y' 
                        : 'bg-slate-50 border-transparent text-slate-600 cursor-not-allowed resize-none'
                    }`}
                    placeholder="Nhập chính sách hoàn hủy, quy định hành lý..."
                  />
                </div>
              </div>
            </div>
          </div>
    )
}

export default DetailedForm;