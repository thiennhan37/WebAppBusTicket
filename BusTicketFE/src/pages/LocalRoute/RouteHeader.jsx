import React from 'react';
import { Search, User, Award, Calendar, UserPlus, MapPinPlus } from 'lucide-react';
import InputGroup from '../../components/other/InputGroup';
import SearchProvinces from "../../components/generalComponent/SearchProvinces"
const RouteHeader = ({filterParams, onChangeFilter, setOpenCreate}) => {
  console.log("reload routeHeader")
  return (
    <div className="px-6 border-b border-slate-100 pb-5 pt-3">
      {/* Hàng 1: Tiêu đề và Nút Thêm */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-0 mb-2 py-0">
        <div>
          <h2 className="text-lg font-bold text-slate-800">Danh sách tuyến đường</h2>
          <p className="text-sm text-slate-500">Quản lý tuyến đường và điểm đón trả khách</p>
        </div>
        <button className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2.5 
          rounded-xl font-medium transition-all shadow-lg shadow-emerald-100 text-sm"
        onClick={() => setOpenCreate(true)}
        >
          <MapPinPlus size={18} /> Thêm tuyến đường
        </button>
      </div>

      {/* Hàng 2: Thanh công cụ Filter */}
        <div className="flex  items-end justify-between gap-4">
            <div className="flex items-end gap-4">
                {/* Ô Search */}
                <div className="w-50"> {/* Thiết lập độ rộng cố định hoặc max-width */}
                    <InputGroup label="Tìm kiếm" placeholder="Tìm kiếm" icon={Search} 
                        value={filterParams?.keyword || ""} onChange={(e) => onChangeFilter("keyword", e.target.value)} />
                </div>

                {/* Ô Tìm kiếm tỉnh thành */}
                <SearchProvinces onChange={onChangeFilter} field={"arrival"} label={"Điểm xuất phát"} placeholder={"Tỉnh/Thành phố"}/>
                <SearchProvinces onChange={onChangeFilter} field={"destination"} label={"Điểm đến"} placeholder={"Tỉnh/Thành phố"}/>
            </div>
        </div>
    </div>
  );
};

export default RouteHeader;