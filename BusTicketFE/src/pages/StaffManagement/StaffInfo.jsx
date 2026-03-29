import { toVN } from "../../utils/translate";
import {X } from 'lucide-react';
import InputGroup from "./InputGroup";
const StaffInfo = ({selectedStaff, setSelectedStaff, rightPanelMode, setRightPanelMode, handleUpdateStaff }) => {
    const handleInputChange = (field, value) => {
        setSelectedStaff(prev => ({ ...prev, [field]: value }));
    };
    const isManager = (selectedStaff.role === "MANAGER" ? true: false);
    return (
        <>
            <div className={`w-full xl:w-[400px] ${rightPanelMode === 'view' ? "" : "hidden"}`}>
                <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-200 sticky top-6">
                    <div className="flex items-center justify-between mb-6">
                        <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                            <span className="w-1 h-6 bg-blue-600 rounded-full"></span>
                            Thông tin nhân sự
                        </h3>
                        
                        <button 
                            onClick={() => {setRightPanelMode("none")}}
                            className="p-1.5 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-rose-500 transition-colors"
                            title="Đóng"
                        >
                            <X size={20} />
                        </button>
                    </div>
                    <div className="space-y-3">
                        <div className="grid grid-cols-2 gap-4">
                            <InputGroup label="Mã NV" value={selectedStaff.id}  disabled={true} />
                            <InputGroup label="Chức vụ" type="text" value={toVN(selectedStaff.role)} disabled={true}/>
                            
                        </div>
                    
                        <InputGroup label="Email" type="text" value={selectedStaff.email} disabled={true}/>
                        <InputGroup label="Họ và Tên" value={selectedStaff.fullName} 
                        onChange={(e) => handleInputChange('fullName', e.target.value)} disabled={isManager}/>
                        <div className="grid grid-cols-2 gap-4">
                            <InputGroup label="Số điện thoại" type="text" value={selectedStaff.phone} 
                            onChange={(e) => handleInputChange('phone', e.target.value)} disabled={isManager}/>
                            <InputGroup label="Giới tính" type="select" options={["MALE", "FEMALE"]} 
                            value={selectedStaff.gender} onChange={(e) => handleInputChange("gender", e.target.value)} disabled={isManager}/>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <InputGroup label="Ngày sinh" type="date" value={selectedStaff.dob} 
                            onChange={(e) => handleInputChange('dob', e.target.value)} disabled={isManager}/>
                            <InputGroup label="Thời điểm đăng kí" type="datetime-local" value={selectedStaff.createdAt} disabled={true}/>
                        </div>

                        <div className={`pt-4 flex gap-3 ${isManager ? "opacity-0 pointer-events-none" : ""}`}>
                            <button className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-xl transition-all shadow-lg shadow-blue-100"
                                onClick={handleUpdateStaff}
                            >
                            Lưu thông tin
                            </button>
                            <button className="w-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold py-3 rounded-xl transition-all">
                            Hủy bỏ
                            </button>
                        </div>
                    </div>
                </div>
            </div> 
        </>
    )
}

export default StaffInfo;