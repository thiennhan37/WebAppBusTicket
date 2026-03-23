import React, { useEffect, useState } from 'react';
import { UserPlus, Award, ShieldCheck, LockKeyhole, Tickets, Users, UserCog, Search, ChevronDown, Calendar } from 'lucide-react';
import StatCards from './StatCards';
import StaffListHeader from './StaffListHeader';
import InputGroup from './InputGroup';
import Pagination from './Pagination';
import StaffService from '../../Services/StaffService';
const StaffManagement = () => {
  // const [staffList] = useState([
  //   { id: 'TX01', name: 'Nguyễn Tran Thien Nhan', role: 'Tài xế', phone: '0905123456', license: 'Bằng E (02/2026)', status: 'active' },
  //   { id: 'TX02', name: 'Trần Văn B', role: 'Tài xế', phone: '0905654321', license: 'Bằng D (12/2025)', status: 'active' },
  //   { id: 'NV01', name: 'Lê Thị C', role: 'NV Bán vé', phone: '0914111222', license: '-', status: 'banned' },
  //   { id: 'TX03', name: 'Hoàng Văn D', role: 'Tài xế', phone: '0988777888', license: 'Bằng E (05/2027)', status: 'banned' },
  //   { id: 'TX04', name: 'Hoàng Văn R', role: 'Tài xế', phone: '0911777888', license: 'Bằng E (05/2027)', status: 'banned' },
  // ]);
  
  const [currentPage, setCurrentPage] = useState(1);
  const handleSetCurrentPage = (page) => {
    setCurrentPage(page);
  }

  const [staffList, setStaffList] = useState([]);
  const loadStaff = async () =>{
    try {
      const res = await StaffService.getAllStaff();
      setStaffList(res.data.result);
      // console.log(res.data.result);
    } catch (error) {
      console.error("Lỗi load staff", error);
    }
  }
  useEffect(() =>{
    // eslint-disable-next-line
    loadStaff(); 
  }, [])

  return (

    // Sử dụng w-full và min-h-screen để tràn hết màn hình
    <div className="w-full max-h-screen overflow-auto bg-slate-50 p-4 lg:p-4">
      
      {/* 1. Stats Panels - Thêm màu nền rực rỡ */}
      <StatCards></StatCards>

      <div className="flex flex-col xl:flex-row gap-6"> 
        {/* 2. Bảng Danh Sách - Chiếm không gian lớn */}
        <div className="flex-1 flex flex-col min-h-[494px] bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <StaffListHeader></StaffListHeader>
          
          <div className="flex-1 overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50/80 text-slate-500 text-[11px] uppercase tracking-widest font-bold">
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
                  <tr key={staff.id} className="hover:bg-slate-50/50 transition-colors">
                    <td className="px-4 py-2 font-bold text-slate-700 text-center">{staff.id}</td>
                    <td className="px-1 py-2 font-medium text-slate-800">{staff.fullName}</td>
                    <td className="px-4 py-2 text-slate-600 text-ms">{staff.role}</td>
                    <td className="px-4 py-2 text-slate-500  text-ms">{staff.phone}</td>
                    <td className="px-4 py-2 text-center">
                      <StatusBadge type={staff.status.toLowerCase()} />
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

        {/* 3. Form nhập liệu - Thiết kế gọn gàng bên phải */}
        <div className="w-full xl:w-[400px]">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 sticky top-6">
            <h3 className="text-lg font-bold text-slate-800 mb-6 flex items-center gap-2">
              <span className="w-1 h-6 bg-blue-600 rounded-full"></span>
              Thông tin nhân sự
            </h3>
            <div className="space-y-5">
              <div className="grid grid-cols-2 gap-4">
                <InputGroup label="Mã NV" placeholder="Auto..." disabled={true} />
                <InputGroup label="Họ và Tên" placeholder="VD: Nguyễn Văn A" />
              </div>
              
              <InputGroup label="Chức vụ" type="select" options={['Tài xế', 'Phụ xe', 'NV Bán vé']} />

              <div className="grid grid-cols-2 gap-4">
                <InputGroup label="Bằng lái" type="select" options={['Bằng D', 'Bằng E', 'Khác']} />
                <InputGroup label="Hạn bằng" type="date" />
              </div>

              <div className="pt-4 flex gap-3">
                <button className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-xl transition-all shadow-lg shadow-blue-100">
                  Lưu thông tin
                </button>
                <button className="w-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold py-3 rounded-xl transition-all">
                  Hủy bỏ
                </button>
              </div>
            </div>
          </div>
        </div>  
      </div>
    </div>
  );
};

// --- Sub-Components ---



const StatusBadge = ({ type }) => {
  const styles = {
    active: { bg: 'bg-emerald-50', text: 'text-emerald-600', label: 'Đang hoạt động' },
    banned: { bg: 'bg-rose-50', text: 'text-rose-600', label: 'Đã khóa' },
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