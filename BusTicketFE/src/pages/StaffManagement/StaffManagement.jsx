import React, { useEffect, useState } from 'react';
import { UserPlus, Award, ShieldCheck, LockKeyhole, Tickets, Users, UserCog, Search, ChevronDown, Calendar } from 'lucide-react';
import StatCards from './StatCards';
import StaffListHeader from './StaffListHeader';
import InputGroup from './InputGroup';
import Pagination from './Pagination';
import StaffService from '../../Services/StaffService';
import { toVN } from '../../utils/translate';
import StaffInfo from './StaffInfo';
import StaffCreate from './StaffCreate';
const StaffManagement = () => {
  const [rightPanelMode, setRightPanelMode] = useState('none');

  const [selectedStaff, setSelectedStaff] = useState({
      id: '',
      fullName: '',
      role: '',
      phone: '',
      email: '',
      dob: '',
      gender: '',
      createdAt: '',
  });
  const handleRowClick = (staff) => {
    setRightPanelMode("view");
    setSelectedStaff(staff);
  };

  const [currentPage, setCurrentPage] = useState(1);
  const handleSetCurrentPage = (page) => {
    setCurrentPage(page);
  }

  const [staffList, setStaffList] = useState([]);
  const loadStaff = async () =>{
    try {
      const res = await StaffService.getAllStaff();
      setStaffList(res.data.result);
    } catch (error) { 
      console.error("Lỗi load staff", error);
    }
  }
  useEffect(() =>{
    // eslint-disable-next-line
    loadStaff();  
  }, [])

  const [newStaff, setNewStaff] = useState({fullName: '',role: '',phone: '',email: '',dob: '', gender: ''});
  const handleCreateStaff = (e) => {
    // setRightPanelMode('create');
  }
  // const [updatedStaff, setUpdatedStaff] = 
  return (

    // Sử dụng w-full và min-h-screen để tràn hết màn hình
    <div className="w-full max-h-screen overflow-auto bg-slate-50 p-4 lg:p-4">
      
      {/* 1. Stats Panels - Thêm màu nền rực rỡ */}
      <StatCards></StatCards>

      <div className="flex flex-col xl:flex-row gap-6"> 
        {/* 2. Bảng Danh Sách - Chiếm không gian lớn */}
        <div className="flex-1 flex flex-col min-h-[494px] bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <StaffListHeader setRightPanelMode={setRightPanelMode}></StaffListHeader>
          
          <div className="flex-1 overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50/80 text-slate-500 text-[11px] uppercase tracking-widest font-bold"
                  
                >
                  <th className="px-4 py-2 ">Mã NV</th>
                  <th className="px-4 py-2 ">Họ Tên</th>
                  <th className="px-4 py-2 ">Chức vụ</th>
                  <th className="px-4 py-2 ">Số điện thoại</th>
                  <th className="px-4 py-2  text-center">Trạng thái</th>
                  <th className="px-4 py-2  text-center">Hành động</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {staffList.map((staff) => (
                  <tr key={staff.id} className="hover:bg-slate-50/50 transition-colors" onClick={() => handleRowClick(staff)}>
                    <td className="px-4 py-2 font-bold text-slate-700 text-center">{staff.id}</td>
                    <td className="px-1 py-2 font-medium text-slate-800">{staff.fullName}</td>
                    <td className="px-4 py-2 text-slate-600 text-ms">{toVN(staff.role)}</td>
                    <td className="px-4 py-2 text-slate-500  text-ms">{staff.phone}</td>
                    <td className="px-4 py-2 text-center">
                      <StatusBadge type={staff.status} />
                    </td>
                    <td className="px-4 py-2">
                      <div className="flex justify-center gap-1">
                        <button className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"><ShieldCheck size={21}/></button>
                        <button className="p-2 text-rose-600 hover:bg-rose-50 rounded-lg transition-colors"><LockKeyhole size={21}/></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
            
          <Pagination page={currentPage} totalPages={10} onPageChange={handleSetCurrentPage}/>
        </div>

        <div className="w-full xl:w-[400px] relative">
            
            {/* Component Xem/Sửa: Luôn trong DOM, ẩn bằng CSS */}
            <div className={rightPanelMode === 'view' ? "block" : "hidden"}>
              <StaffInfo 
                selectedStaff={selectedStaff} 
                setSelectedStaff={setSelectedStaff}
                setRightPanelMode={setRightPanelMode}
                rightPanelMode = {rightPanelMode}
              />
            </div>

            {/* Component Tạo mới: Luôn trong DOM, ẩn bằng CSS */}
            <div className={rightPanelMode === 'create' ? "block" : "hidden"}>
              <StaffCreate 
                newStaff={newStaff} 
                setNewStaff={setNewStaff}
                setRightPanelMode={setRightPanelMode}
                rightPanelMode = {rightPanelMode}
                handleCreateStaff = {handleCreateStaff}
                
              />
            </div>

            {/* Placeholder (Tùy chọn): Hiển thị khi không có mode nào để vùng 400px không bị trống trải */}
            {rightPanelMode === 'none' && (
              <div className="h-[500px] border-2 border-dashed border-slate-200 rounded-2xl flex items-center justify-center text-slate-400">
                Chọn một nhân viên để xem chi tiết
              </div>
            )}
        </div>
         
      </div>
    </div>
  );
};

// --- Sub-Components ---



const StatusBadge = ({ type }) => {
  const styles = {
    ACTIVE: { bg: 'bg-emerald-50', text: 'text-emerald-600', label: 'Đang hoạt động' },
    BLOCKED: { bg: 'bg-rose-50', text: 'text-rose-600', label: 'Đã khóa' },
    // pending: { bg: 'bg-slate-100', text: 'text-slate-600', label: 'Đang chờ' },
  };
  const s = styles[type] || styles.pending;
  return (
    <span className={`px-4 py-1.5 rounded-lg text-xs font-bold ${s.bg} ${s.text} border border-current/10`}>
      {s.label}
    </span>
  );
};





export default StaffManagement;