import React, { useState, useEffect } from 'react';
import { Navigation, CheckCircle2, Circle, X, CheckSquare, Clock } from 'lucide-react';
import InputGroup from '../../components/other/InputGroup';
import ProvinceService from '../../Services/ProvinceService';
import {useQuery} from '@tanstack/react-query'
import { useMemo } from 'react';
import RouteService from '../../Services/routeService';

const UpdateRoute = ({ selectedRoute, setSelectedRoute, handleViewUpdate, handleUpdateRoute,
  upStopList, setUpStopList,
  downStopList, setDownStopList
 }) => {
  const routeId = selectedRoute?.id;
  const [upList, setUpList] = useState([]);
  const [downList, setDownList] = useState([]);
  const { data, isLoading } = useQuery({
    queryKey: ['routeStops', routeId],
    queryFn: async () => {
      const upResponse = (await RouteService.getRouteStop({ routeId, params: { type: "UP" } }))?.data?.result;
      const downResponse = (await RouteService.getRouteStop({ routeId, params: { type: "DOWN" } }))?.data?.result;
      
      return {upResponse, downResponse};
    },
    enabled: !!selectedRoute,
    staleTime: Infinity,
  });
  // Lưu lại danh sách các điểm đón/trả ban đầu để không cho phép xóa
  const originalUpIds = useMemo(() => data?.upResponse?.map(p => p?.stop?.id) || [], [data?.upResponse]);
  const originalDownIds = useMemo(() => data?.downResponse?.map(p => p?.stop?.id) || [], [data?.downResponse]);

  // Lấy tên tỉnh cho an toàn, hỗ trợ cả 2 trường hợp (arrival/arrivalProvince)
  const arrivalName = selectedRoute?.arrivalProvince?.name || selectedRoute?.arrival?.name;
  const destinationName = selectedRoute?.destinationProvince?.name || selectedRoute?.destination?.name;

  const onChangeSelectedRoute = (field, value) => {
    setSelectedRoute(prev => ({ ...prev, [field]: value }));
  };
  const duration = selectedRoute?.durationMinutes || 0;
  const displayHours = Math.floor(duration / 60);
  const displayMinutes = duration % 60;

  const handleDurationChange = (type, value) => {
    const numValue = parseInt(value) || 0;
    let newTotal = 0;
    
    if (type === 'hours') {
      newTotal = (numValue * 60) + displayMinutes;
    } else {
      newTotal = (displayHours * 60) + numValue;
    }
    
    onChangeSelectedRoute("durationMinutes", newTotal);
  };

  useEffect(() => {
    const loadUpStops = async () => {
      try {
        if (arrivalName) {
          const params = { province: arrivalName };
          const result = (await ProvinceService.getStops({ filterParams: params }))?.data?.result || [];
          setUpList(result);
        }
      } catch (error) {
        console.log("Error loading up stops: ", error);
      }
    }
    loadUpStops();
  }, [arrivalName]);

  useEffect(() => {
    const loadDownStops = async () => {
      try {
        if(destinationName){
          const params = { province: destinationName };
          const result = (await ProvinceService.getStops({ filterParams: params }))?.data?.result || [];
          setDownList(result);
        }
      } catch (error) {
        console.log(error);
      }
    }
    loadDownStops();
  }, [destinationName]);  

  const togglePoint = (point, field) => {
    if (field === "upStopList") {
      if (originalUpIds.includes(point.id)) return;
      setUpStopList((prev) => {
        const isExist = prev.some((p) => p.id === point.id);
        if (isExist) {
          return prev.filter((p) => p.id !== point.id);
        } else {
          return [...prev, point];
        }
      });
    }
    if (field === "downStopList") {
      if (originalDownIds.includes(point.id)) return;
      setDownStopList((prev) => {
        const isExist = prev.some((p) => p.id === point.id);
        if (isExist) {
          return prev.filter((p) => p.id !== point.id);
        } else {
          return [...prev, point];
        }
      });
    }
  };

  return (
    <div className="bg-white p-4 rounded-xl shadow-2xl border border-gray-100 w-full max-w-2xl h-fit animate-in fade-in slide-in-from-right-4 duration-300">
      <div className="flex items-center justify-between gap-2 mb-6 border-b pb-2">
        <div className="flex items-center gap-2">
          <div className="p-2 bg-emerald-100 text-emerald-600 rounded-lg">
            <Navigation size={20} />
          </div>
          <h2 className="text-xl font-bold text-gray-800">Cập nhật tuyến đường</h2>
        </div>
        <button className="p-2 bg-emerald-100 text-emerald-600 rounded-lg hover:bg-emerald-200 transition-colors" 
          onClick={() => handleViewUpdate(null, false)}>
          <X size={20} />
        </button>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
        {/* Tên tuyến đường */}
        <InputGroup 
          value={selectedRoute?.name || ""} 
          onChange={(e) => {onChangeSelectedRoute("name", e.target.value.trimStart()); }} 
          label={"Tên tuyến đường"} 
          placeholder={"Nhập tên tuyến đường"} 
        />
        {/* Thời gian di chuyển */}
        <div className="w-full">
          <label className="text-[11px] font-bold text-slate-700 uppercase mb-1.5 block ml-1">
            Thời gian di chuyển (dự kiến)
          </label>
          
          <div className="flex items-center gap-2">
            {/* Ô nhập Giờ */}
            <div className="flex-1 relative flex items-center bg-slate-50 border border-slate-200 rounded-xl p-1.5 focus-within:border-blue-400 transition-all">
              <input type="text" min="0" value={String(displayHours)} onChange={(e) => handleDurationChange('hours', e.target.value)} className="w-full bg-transparent outline-none text-sm text-slate-700 pl-1.5 font-medium"/>
              <span className="text-[10px] font-bold text-slate-400 uppercase pr-1 select-none">Giờ</span>
            </div>

            {/* Ô nhập Phút */}
            <div className="flex-1 relative flex items-center bg-slate-50 border border-slate-200 rounded-xl p-1.5 focus-within:border-blue-400 transition-all">
              <input type="text" min="0" max="59" value={String(displayMinutes)} onChange={(e) => handleDurationChange('minutes', e.target.value)} className="w-full bg-transparent outline-none text-sm text-slate-700 pl-1.5 font-medium"/>
              <span className="text-[10px] font-bold text-slate-400 uppercase pr-1 select-none">Phút</span>
            </div>
            <div className="flex items-center justify-center bg-slate-100 text-slate-500 rounded-xl p-1.5 border border-slate-200 aspect-square">
              <Clock size={16} />
            </div>
          </div>
        </div>
      </div>
      
      
      <div className="flex gap-x-4 pt-2 mt-4">
        {/* PHẦN 1: TỈNH BẮT ĐẦU & ĐIỂM ĐÓN */}
        <section className="flex-1 space-y-3">
          <div>
            <label className="block text-[13px] font-semibold text-gray-700 mb-1">Điểm xuất phát (Cố định)</label>
            <div className="w-full px-3 py-2 border rounded-lg bg-gray-100 text-gray-600 font-medium cursor-not-allowed">
               {arrivalName || '...'}
            </div>
          </div>

          <div className="pl-3 border-l-2 border-emerald-200 py-1">
            <p className="text-[11px] font-bold text-emerald-600 uppercase mb-2">Điểm đón ({arrivalName || '...'}):</p>
            
            <div className="h-48 overflow-y-auto pr-2 space-y-2 scrollbar-thin scrollbar-thumb-gray-200">
              {arrivalName ? (
                upList.map(point => {
                  const isOriginal = originalUpIds.includes(point.id);
                  const selected = upStopList?.some(p => p.id === point.id);
                  return (
                    <button
                      key={point.id}
                      onClick={() => togglePoint(point, "upStopList")}
                      className={`flex items-start justify-between w-full px-3 py-2.5 rounded-lg text-sm transition-all border text-left ${
                        isOriginal 
                          ? 'bg-emerald-100 border-emerald-300 text-emerald-800 cursor-not-allowed opacity-80'
                          : selected
                            ? 'bg-emerald-50 border-emerald-200 text-emerald-700 font-medium'
                            : 'bg-gray-50 border-transparent text-gray-600 hover:bg-white hover:border-emerald-300'
                      }`}
                      disabled={isOriginal}
                      title={isOriginal ? "Điểm đón cũ không thể xóa" : ""}
                    >
                      <span className="whitespace-normal break-words leading-tight flex-1 mr-2">{point.name}</span>
                      {isOriginal ? (
                        <CheckSquare size={16} className="text-emerald-700 shrink-0" />
                      ) : selected ? (
                        <CheckCircle2 size={16} className="shrink-0 text-emerald-600" />
                      ) : (
                        <Circle size={16} className="text-gray-300 shrink-0" />
                      )}
                    </button>
                  );
                })
              ) : (
                <p className="text-xs text-gray-400 italic">Đang tải...</p>
              )}
            </div>
          </div>
        </section>

        {/* PHẦN 2: TỈNH ĐẾN & ĐIỂM TRẢ */}
        <section className="flex-1 space-y-3">
          <div>
            <label className="block text-[13px] font-semibold text-gray-700 mb-1">Điểm đến (Cố định)</label>
            <div className="w-full px-3 py-2 border rounded-lg bg-gray-100 text-gray-600 font-medium cursor-not-allowed">
               {destinationName || '...'}
            </div>
          </div>

          <div className="pl-3 border-l-2 border-emerald-200 py-1">
            <p className="text-[11px] font-bold text-emerald-600 uppercase mb-2">Điểm trả ({destinationName || '...'}):</p>
            
            <div className="h-48 overflow-y-auto pr-2 space-y-2 scrollbar-thin scrollbar-thumb-gray-200">
              {destinationName ? (
                downList.map(point => {
                  const selected = downStopList?.some(p => p.id === point.id);
                  const isOriginal = originalDownIds.includes(point.id);
                  return (
                    <button
                      key={point.id}
                      onClick={() => togglePoint(point, "downStopList")}
                      className={`flex items-start justify-between w-full px-3 py-2.5 rounded-lg text-sm transition-all border text-left ${
                        isOriginal 
                          ? 'bg-emerald-100 border-emerald-300 text-emerald-800 cursor-not-allowed opacity-80'
                          : selected
                            ? 'bg-emerald-50 border-emerald-200 text-emerald-700 font-medium'
                            : 'bg-gray-50 border-transparent text-gray-600 hover:bg-white hover:border-emerald-300'
                      }`}
                      disabled={isOriginal}
                      title={isOriginal ? "Điểm trả cũ không thể xóa" : ""}
                    >
                      <span className="whitespace-normal break-words leading-tight flex-1 mr-2">{point.name}</span>
                      {isOriginal ? (
                        <CheckSquare size={16} className="text-emerald-700 shrink-0" />
                      ) : selected ? (
                        <CheckCircle2 size={16} className="shrink-0 text-emerald-600" />
                      ) : (
                        <Circle size={16} className="text-gray-300 shrink-0" />
                      )}
                    </button>
                  );
                })
              ) : (
                <p className="text-xs text-gray-400 italic">Đang tải...</p>
              )}
            </div>
          </div>
        </section>
      </div>

      <div className="pt-6 flex flex-col gap-3">
        <button
          disabled={(!selectedRoute?.name || selectedRoute?.name.trim() === "")}
          className="w-full py-3 bg-emerald-600 text-white rounded-xl font-bold hover:bg-emerald-700 disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed transition-all shadow-lg shadow-emerald-100"
          onClick={handleUpdateRoute}
        >
          Xác nhận cập nhật tuyến đường
        </button>
        <p className="text-[10px] text-center text-gray-400 italic">
          * Bạn chỉ có thể sửa tên tuyến đường và thêm mới điểm đón/trả. Các điểm đã có sẽ được giữ nguyên.
        </p>
      </div>
    </div>
  );
};

export default UpdateRoute;