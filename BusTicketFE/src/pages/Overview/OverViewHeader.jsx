import { Edit2, Loader2, Save, X } from "lucide-react";

const OverviewHeader = ({isEditing, handleEdit, handleCancel, handleUpdate}) =>{
    return( 
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-slate-900">Tổng quan doanh nghiệp</h1>
            <p className="text-slate-500 text-sm mt-1">Quản lý thông tin và hồ sơ nhà xe của bạn</p>
          </div>

          <div className="flex items-center gap-3">
            {!isEditing ? (
              <button 
                onClick={handleEdit}
                className="flex items-center gap-2 px-4 py-2 bg-slate-900 text-white rounded-lg hover:bg-slate-800 transition-colors shadow-sm font-medium"
              >
                <Edit2 className="w-4 h-4" />
                Chỉnh sửa hồ sơ
              </button>
            ) : (
              <>
                <button 
                  onClick={handleCancel}
                  className="flex items-center gap-2 px-4 py-2 bg-white text-slate-700 
              border border-slate-200 rounded-lg hover:bg-slate-50 transition-colors 
              disabled:opacity-50 font-medium"
                >
                  <X className="w-4 h-4" />
                  Hủy
                </button>
                <button 
                  onClick={handleUpdate}
                  className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-sm disabled:opacity-70 font-medium"
                > 
                  <Save className="w-4 h-4" />
                  Lưu thay đổi
                </button>
              </>
            )}
          </div>
        </div>
    )
}

export default OverviewHeader;