import React, { useState, useRef, useEffect } from 'react';
import ProvinceService from "../../Services/ProvinceService"
const SearchStops = ({onChange, field,  label, placeholder}) => {
  

  const [inputValue, setInputValue] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  // 1. Tạo một Ref để tham chiếu đến toàn bộ component search
  const searchRef = useRef(null);
  const handleSelect = (stop) => {
    if(onChange){ 
      onChange(field, stop);
      setInputValue(stop.name);
      setIsOpen(false);
    }
  };
const [stops, setStops] = useState([]);
  useEffect(() => {
    const loadStops = async() => {
        try{
            const params = {keyword: inputValue};
            const result = (await ProvinceService.getStops({filterParams: params}))?.data?.result || [];
            setStops(result);
        }catch(error){
            console.log(error);
        }
    }
    loadStops();
    
  }, [inputValue]);
  // 2. Xử lý logic khi click ra ngoài
  useEffect(() => {
    const handleClickOutside = (event) => {
      // Nếu click KHÔNG nằm trong vùng của searchRef
      if (searchRef.current && !searchRef.current.contains(event.target)) {

        if(stops.length && inputValue) handleSelect(stops[0]);
        else handleSelect({id:"", name:""});
        setIsOpen(false);
      }
    };

    // Đăng ký sự kiện click toàn trang
    document.addEventListener("mousedown", handleClickOutside);
    
    // Hủy đăng ký khi component bị gỡ bỏ để tránh rò rỉ bộ nhớ
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [stops, inputValue, searchRef]); // Dependency là filteredProvinces để lấy được giá trị mới nhất

  

  return (
    <div className="flex flex-col items-center max-h-[70px]">
      {/* Gán Ref vào thẻ div bao ngoài cùng */}
      <div ref={searchRef} className="relative w-full max-w-md">
        <label className="text-[11px] font-bold text-slate-400 uppercase mb-1.5 block ml-1">
          {label}
        </label>
        
        <div className="relative">
          <input
            type="text"
            className="w-full rounded-xl p-1.5 text-sm outline-none transition-all border border-slate-200 bg-slate-50 focus:border-blue-400"
            placeholder={placeholder}
            value={inputValue}
            onChange={(e) => {
              setInputValue(e.target.value);
              setIsOpen(true);
            }}
            onFocus={() => setIsOpen(true)}
          />
        </div>

        {isOpen && (
          <ul className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">
            {stops.length > 0 ? (
              stops.map((stop) => (
                <li
                  key={stop.id}
                  className="px-4 py-2 hover:bg-blue-50 cursor-pointer text-gray-700 border-b last:border-none border-gray-100"
                  onClick={() => handleSelect(stop)}
                >
                  {stop.name}
                </li>
              ))
            ) : (
              <li className="px-4 py-2 text-gray-500 italic">Không tìm thấy kết quả</li>
            )}
          </ul>
        )}
      </div>
    </div>
  );
};

export default SearchStops;