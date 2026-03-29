import { toVN } from "../../utils/translate";
import {X } from 'lucide-react';
import InputGroup from "./InputGroup";

const StaffCreate = ({newStaff, setNewStaff, setRightPanelMode, handleCreateStaff, rightPanelMode}) => {
    const handleInputChange = (field, value) => {
    setNewStaff(prev => ({ ...prev, [field]: value }));
  };

  return (
    <div className={`w-full xl:w-[400px] ${rightPanelMode === 'create' ? "" : "hidden"}`}>
      <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-200 sticky top-6">
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2">
            <span className="w-1 h-6 bg-emerald-500 rounded-full"></span>
            Thêm nhân viên mới
          </h3>
          <button onClick={() => setRightPanelMode('none')} className="p-1.5 hover:bg-slate-100 rounded-lg"><X size={20} /></button>
        </div>

        <div className="space-y-3">
          <InputGroup label="Họ và Tên" value={newStaff.fullName} onChange={(e) => handleInputChange('fullName', e.target.value)} />
          <InputGroup label="Email" value={newStaff.email} onChange={(e) => handleInputChange('email', e.target.value)} />
          <div className="grid grid-cols-2 gap-4">
             <InputGroup label="Số điện thoại" value={newStaff.phone} onChange={(e) => handleInputChange('phone', e.target.value)} />
             <InputGroup label="Chức vụ" type="select" options={["QUẢN LÍ", "NHÂN VIÊN"]} value={newStaff.role} onChange={(e) => handleInputChange('role', e.target.value)} />
          </div>
          {/* Thêm các field khác tương tự... */}
          <div className="grid grid-cols-2 gap-4">
            <InputGroup label="Giới tính" type="select" options={["MALE", "FEMALE"]} 
                value={newStaff.gender} onChange={(e) => handleInputChange("gender", e.target.value)}/>
            <InputGroup label="Ngày sinh" type="date" value={newStaff.dob}
              onChange={(e) => handleInputChange("dob", e.target.value)}/>   
        </div>
          
          <div className="pt-4 flex gap-3">
            <button className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-3 rounded-xl transition-all shadow-lg shadow-emerald-100"
                onClick={() => handleCreateStaff()}
            >
              Tạo nhân viên
            </button>
            <button onClick={() => setRightPanelMode('none')} className="w-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold py-3 rounded-xl">
              Hủy
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StaffCreate;