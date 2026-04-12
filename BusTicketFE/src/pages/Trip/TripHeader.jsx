import React from 'react';
import { Search, Plus, Calendar, Filter, ChevronDown } from 'lucide-react';
import InputGroup from '../../components/other/InputGroup';
import { useState, useEffect } from 'react';
import BusService from '../../Services/BusService';
const TripHeader = ({setIsAddModalOpen, searchParams, updateFilter, dateValue, setDateValue }) => {
  // test = "da thay doi";
  const [busTypeList, setBusTypeList] = useState([]);
  useEffect(() => {
    const fetchData = async() => {
      const result = (await BusService.getBusTypeList()).data.result;
      const busTypeList = result.map((busType) => busType.name);
      setBusTypeList(busTypeList);
    }
    fetchData();
  }, []);
    return (
    <div>
        {/* Header Section */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-2 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Danh sách chuyến đi</h1>
          <p className="text-sm text-slate-500 mt-1">Quản lý lịch trình, xe và giá vé các chuyến đi</p>
        </div>
        <button 
          onClick={() => setIsAddModalOpen(true)}
          className="flex items-center justify-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2.5 rounded-xl font-medium transition-colors shadow-sm shadow-emerald-600/20 active:scale-95"
        >
          <Plus size={20} />
          <span>Thêm chuyến đi</span>
        </button>
      </div>

      {/* Filter & Search Bar - App-like card */}
      <div className="bg-white py-2 px-4 rounded-2xl shadow-sm border border-slate-100 mb-0 flex flex-col sm:flex-row gap-4">
          
          <div className='flex-1'>
            <InputGroup label="Tìm kiếm" placeholder="Tìm kiếm theo chuyến đi, tuyến đường" icon={Search} 
              value={searchParams.get("keyword")} onChange={(e) => updateFilter({field: "keyword", value: e.target.value})} />
          </div>
          
          <div className='flex-1 flex gap-3'>
            <InputGroup label="Thời gian xuất bến" type="date" value={dateValue} 
              onChange={(e) => {
                setDateValue(e.target.value)
                updateFilter({field: "date", value: e.target.value})}} />
            
            <InputGroup label="Trạng thái" type="select" options={['Tất Cả', "Đang mở", 'Đã hủy', "Đang lên lịch", "Đã đóng"]}
              onChange={(e) => updateFilter({field: "status", value: e.target.value})} value={searchParams.get("status")}/>
            
            <InputGroup label="Phương tiện" type="select" options={['Tất Cả', ...busTypeList]} 
              onChange={(e) => updateFilter({field: "busType", value: e.target.value})} value={searchParams.get("busType")}/>
          </div>
          
      </div>
    </div>
          
    )
};

export default TripHeader;
