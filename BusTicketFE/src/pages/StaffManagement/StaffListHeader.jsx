import React from 'react';
import { Search, User, Award, Calendar, UserPlus, ChevronDown } from 'lucide-react';
import InputGroup from '../../components/other/InputGroup';

const StaffListHeader = ({setRightPanelMode, filterParams, setFilterParams}) => {
  console.log("reload listHeader")
  const onChangeRole = (e) => {
    const newParams = {...filterParams, role: e.target.value}
    setFilterParams(newParams)
  }
  const onChangeStatus = (e) => {
    const newParams = {...filterParams, status: e.target.value}
    setFilterParams(newParams)
  }
  const onChangeKeyword = (e) => {
    console.log(e.target.value);
    const newParams = {...filterParams, keyword: e.target.value}
    console.log(newParams);
    setFilterParams(newParams)
  }
  return (
    <div className="px-6 border-b border-slate-100 pb-5 pt-3">
      {/* Hàng 1: Tiêu đề và Nút Thêm */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-0 mb-2 py-0">
        <div>
          <h2 className="text-lg font-bold text-slate-800">Danh sách nhân sự</h2>
          <p className="text-sm text-slate-500">Quản lý đội ngũ tài xế và nhân viên nhà xe</p>
        </div>
        <button className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2.5 
        rounded-xl font-medium transition-all shadow-lg shadow-emerald-100 text-sm"
        onClick={() => setRightPanelMode("create")}
        >
          <UserPlus size={18} /> Thêm nhân viên
        </button>
      </div>

      {/* Hàng 2: Thanh công cụ Filter */}
      <div className="flex flex-wrap items-center gap-3 justify-between">
        {/* Ô Search */}
        <div className="flex-1 relative min-w-[100px] max-w-[300px]">
          {/* <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={18} /> */}
          <InputGroup label="Họ và Tên" placeholder="Tìm kiếm" icon={Search} value={filterParams.keyword}
            onChange={(e) => onChangeKeyword(e)}/>
        </div>
        
        <div className="flex-1 flex gap-8">
            <InputGroup label="Chức vụ" type="select" options={['Tất Cả', 'Quản lí', 'Nhân viên']} onChange={onChangeRole} value={filterParams.role}/>
            <InputGroup label="Trạng thái" type="select" options={['Tất Cả', 'Đang hoạt động', 'Đã khóa']} 
              onChange={onChangeStatus} value={filterParams.status}/>
        </div>

      </div>
    </div>
  );
};

export default StaffListHeader;