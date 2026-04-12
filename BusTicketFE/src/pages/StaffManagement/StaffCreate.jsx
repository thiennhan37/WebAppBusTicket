import ConfirmModal from '../../components/other/ConfirmModal';
import {X } from 'lucide-react';
import InputGroup from "../../components/other/InputGroup";
import validator from 'validator';
import { useState } from "react";

const StaffCreate = ({newStaff, setNewStaff, setRightPanelMode, handleCreateStaff, rightPanelMode}) => {
  // console.log("load staffCreate")
  
  const handleInputChange = (field, value) => {
    setNewStaff(prev => ({ ...prev, [field]: value }));
  };
  const [showConfirm, setShowConfirm] = useState(false);
  
  const [errorPhone, setErrorPhone] = useState("");
  const [errorEmail, setErrorEmail] = useState("");
  const [errorName, setErrorName] = useState("");
  const [errorDob, setErrorDob] = useState("");

  const onCLickCreate = () =>{
    const isEmailValid = validator.isEmail(newStaff.email || "");
    const isPhoneValid = validator.isMobilePhone(newStaff.phone || "", "vi-VN");
    const isNameValid = !!newStaff.fullName;
    const isDobValid = !!newStaff.dob;

    setErrorEmail(isEmailValid ? "" : "Email không hợp lệ");
    setErrorPhone(isPhoneValid ? "" : "Số điện thoại không hợp lệ");
    setErrorName(isNameValid ? "" : "Tên không hợp lệ");
    setErrorDob(isDobValid ? "" : "Ngày sinh không hợp lệ");

    if (isEmailValid && isPhoneValid &&  isNameValid && isDobValid) {
      setShowConfirm(true);
    } 
  }

  return (
    <div className={`w-full xl:w-[400px] ${rightPanelMode === 'create' ? "" : "hidden"}`}>
        <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-200 sticky top-6 overflow-hidden">
            <div className="flex items-center justify-between mb-6">
                <h3 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                    <span className="w-1 h-6 bg-blue-600 rounded-full"></span>
                    Thêm nhân viên mới
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
              <InputGroup label="Họ và Tên" value={newStaff.fullName} 
                onChange={(e) => handleInputChange('fullName', e.target.value)} error={errorName}/>
              <InputGroup label="Email" value={newStaff.email} 
                  onChange={(e) => handleInputChange('email', e.target.value)} error={errorEmail} />

              <div className="grid grid-cols-2 gap-4">
                  <InputGroup label="Số điện thoại" value={newStaff.phone}  
                    onChange={(e) => handleInputChange("phone", e.target.value.replace(/\D/g, ""))} error={errorPhone}/>

                  <InputGroup label="Chức vụ" type="select" options={["Quản lí", "Nhân viên"]} value={newStaff.role} onChange={(e) => handleInputChange('role', e.target.value)} />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <InputGroup label="Giới tính" type="select" options={["Nam", "Nữ", "Khác"]} 
                    value={newStaff.gender} onChange={(e) => handleInputChange("gender", e.target.value)}/>
                <InputGroup label="Ngày sinh" type="date" value={newStaff.dob}
                  onChange={(e) => handleInputChange("dob", e.target.value)} error={errorDob}/>   
              </div>

              <div className="pt-3 flex gap-3">
                <button className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-3 rounded-xl transition-all shadow-lg shadow-emerald-100"
                    onClick={() => onCLickCreate()}
                >
                  Tạo nhân viên
                </button>
                <button onClick={() => setRightPanelMode('none')} className="w-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold py-3 rounded-xl">
                  Hủy
                </button>
              </div> 
            </div>
            {/* Sử dụng Component ConfirmModal */}
            <ConfirmModal 
              view={"absolute"}
              isOpen={showConfirm}
              onClose={() => setShowConfirm(false)}
              onConfirm={handleCreateStaff}
              title="Thêm nhân viên mới"
              message={`Bạn có chắc chắn muốn đăng ký nhân viên ${newStaff.fullName} vào hệ thống?`}
            />
        </div>
        
    </div> 
    )
};

export default StaffCreate;