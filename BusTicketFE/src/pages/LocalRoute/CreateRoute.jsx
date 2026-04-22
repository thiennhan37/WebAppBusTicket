import React, { useState, useEffect } from 'react';
import { Navigation, CheckCircle2, Circle, X } from 'lucide-react';
import SearchProvinces from "../../components/generalComponent/SearchProvinces"
import InputGroup from '../../components/other/InputGroup';
import ProvinceService from '../../Services/ProvinceService';

const CreateRoute = ({ crRoute, onChangeCrRoute, setOpen, handleCreateRoute }) => {

  const [upList, setUpList] = useState([]);
  const [downList, setDownList] = useState([]);
  // const onChangeRouteName = (value) => { 
  //   setRouteName(value.trim());
  //   onChangeCrRoute("name", value.trim());
  // };

  useEffect(() => {
    const loadUpStops = async () => {
      try {
        if (crRoute?.arrival) {
          const params = { province: crRoute.arrival.name};
          const result = (await ProvinceService.getStops({ filterParams: params }))?.data?.result || [];
          setUpList(result);
        }
      } catch (error) {
        console.log("Error loading up stops: ", error);
      }
    }
    loadUpStops();
  }, [crRoute?.arrival]);

  useEffect(() => {
    const loadDownStops = async () => {
      try {
        if (crRoute?.destination) {
          const params = { province: crRoute.destination.name};
          const result = (await ProvinceService.getStops({ filterParams: params }))?.data?.result || [];
          setDownList(result);
        }
      } catch (error) {
        console.log(error);
      }
    }
    loadDownStops();
  }, [crRoute?.destination]);

  const togglePoint = (point, list, field) => {
    const isExist = list.some(p => p.id === point.id); 
    if (isExist) {
      onChangeCrRoute(field, list.filter(p => p.id !== point.id));
    } else {
      onChangeCrRoute(field, [...list, point]);
    }
  };

  return (
    <div className="bg-white p-4 rounded-xl shadow-2xl border border-gray-100 w-full max-w-2xl ml-4 h-fit animate-in fade-in slide-in-from-right-4 duration-300">
      <div className="flex items-center justify-between gap-2 mb-6 border-b pb-2">
        <div className="flex items-center gap-2">
          <div className="p-2 bg-emerald-100 text-emerald-600 rounded-lg">
            <Navigation size={20} />
          </div>
          <h2 className="text-xl font-bold text-gray-800">Cấu hình tuyến đường</h2>
        </div>
        <button className="p-2 bg-emerald-100 text-emerald-600 rounded-lg hover:bg-emerald-200 transition-colors" onClick={() => setOpen(false)}>
          <X size={20} />
        </button>
      </div>
      <InputGroup value={crRoute.name} 
        onChange={(e) => {onChangeCrRoute("name", e.target.value.trimStart()); }} 
        label={"Tên tuyến đường"} placeholder={"Nhập tên tuyến đường"} />
      <div className="flex gap-x-4 pt-2">
        {/* PHẦN 1: TỈNH BẮT ĐẦU & ĐIỂM ĐÓN */}
        <section className="flex-1 space-y-3">
          <SearchProvinces onChange={onChangeCrRoute} field={"arrival"} label={"Điểm xuất phát"} placeholder={"Tỉnh/Thành phố"}  />

          <div className="pl-3 border-l-2 border-emerald-200 py-1">
            <p className="text-[11px] font-bold text-emerald-600 uppercase mb-2">Điểm đón ({crRoute?.arrival?.name || '...'}):</p>
            
            {/* KHUNG CỐ ĐỊNH CHIỀU CAO VÀ TRƯỢT DỌC */}
            <div className="h-48 overflow-y-auto pr-2 space-y-2 scrollbar-thin scrollbar-thumb-gray-200">
              {crRoute?.arrival?.name ? (
                upList.map(point => {
                  const selected = crRoute.upStopList.some(p => p.id === point.id);
                  return (
                    <button
                      key={point.id}
                      onClick={() => togglePoint(point, crRoute.upStopList, "upStopList")}
                      className={`flex items-start justify-between w-full px-3 py-2.5 rounded-lg text-sm transition-all border text-left ${
                        selected
                          ? 'bg-emerald-50 border-emerald-200 text-emerald-700 font-medium'
                          : 'bg-gray-50 border-transparent text-gray-600 hover:bg-white hover:border-emerald-300'
                      }`}
                    >
                      <span className="whitespace-normal break-words leading-tight flex-1 mr-2">{point.name}</span>
                      {selected ? <CheckCircle2 size={16} className="shrink-0" /> : <Circle size={16} className="text-gray-300 shrink-0" />}
                    </button>
                  );
                })
              ) : (
                <p className="text-xs text-gray-400 italic">Vui lòng chọn tỉnh...</p>
              )}
            </div>
          </div>
        </section>

        {/* PHẦN 2: TỈNH ĐẾN & ĐIỂM TRẢ */}
        <section className="flex-1 space-y-3">
          <SearchProvinces onChange={onChangeCrRoute} field={"destination"} label={"Điểm đến"} placeholder={"Tỉnh/Thành phố"} />

          <div className="pl-3 border-l-2 border-emerald-200 py-1">
            <p className="text-[11px] font-bold text-emerald-600 uppercase mb-2">Điểm trả ({crRoute?.destination?.name || '...'}):</p>
            
            {/* KHUNG CỐ ĐỊNH CHIỀU CAO VÀ TRƯỢT DỌC */}
            <div className="h-48 overflow-y-auto pr-2 space-y-2 scrollbar-thin scrollbar-thumb-gray-200">
              {crRoute?.destination?.name ? (
                downList.map(point => {
                  const selected = crRoute.downStopList.some(p => p.id === point.id);
                  return (
                    <button
                      key={point.id}
                      onClick={() => togglePoint(point, crRoute.downStopList, "downStopList")}
                      className={`flex items-start justify-between w-full px-3 py-2.5 rounded-lg text-sm transition-all border text-left ${
                        selected
                          ? 'bg-emerald-50 border-emerald-200 text-emerald-700 font-medium'
                          : 'bg-gray-50 border-transparent text-gray-600 hover:bg-white hover:border-emerald-300'
                      }`}
                    >
                      <span className="whitespace-normal break-words leading-tight flex-1 mr-2">{point.name}</span>
                      {selected ? <CheckCircle2 size={16} className="shrink-0" /> : <Circle size={16} className="text-gray-300 shrink-0" />}
                    </button>
                  );
                })
              ) : (
                <p className="text-xs text-gray-400 italic">Vui lòng chọn tỉnh...</p>
              )}
            </div>
          </div>
        </section>
      </div>

      <div className="pt-6 flex flex-col gap-3">
        <button
          disabled={!crRoute?.arrival || !crRoute?.destination || crRoute?.upStopList.length === 0 || crRoute?.downStopList.length === 0 || !crRoute.name}
          className="w-full py-3 bg-emerald-600 text-white rounded-xl font-bold hover:bg-emerald-700 disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed transition-all shadow-lg shadow-emerald-100"
          onClick={handleCreateRoute}
        >
          Xác nhận tạo tuyến đường
        </button>
        <p className="text-[10px] text-center text-gray-400 italic">
          * Vui lòng nhập tên và chọn ít nhất 1 điểm đón/trả để hoàn tất
        </p>
      </div>
    </div>
  );
};

export default CreateRoute;