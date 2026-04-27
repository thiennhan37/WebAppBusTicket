import React, { useState, useRef, useEffect } from 'react';
import ProvinceService from "../../Services/ProvinceService";

const SearchProvinces = ({ onChange, field, label, placeholder, initial }) => {
  const [inputValue, setInputValue] = useState(initial || "");
  const [isOpen, setIsOpen] = useState(false);
  const [provinces, setProvinces] = useState([]);
  const searchRef = useRef(null);

  // Fetch provinces with a small debounce while typing
  useEffect(() => {
    const controller = new AbortController();
    const handle = setTimeout(async () => {
      try {
        const params = { keyword: inputValue };
        const result = (await ProvinceService.getProvinces({ filterParams: params }))?.data?.result || [];
        setProvinces(result);
      } catch (err) {
        if (err.name !== 'AbortError') console.error(err);
      }
    }, 250);

    return () => {
      clearTimeout(handle);
      controller.abort();
    };
  }, [inputValue]);

  // Select and notify parent. We only send { name } (no id) per request.
  const handleSelect = (provinceOrObj) => {
    const name = provinceOrObj && provinceOrObj.name ? provinceOrObj.name : '';
    setInputValue(name);
    setIsOpen(false);
    if (onChange) onChange(field, provinceOrObj);
  };

  // Click outside: if list has items and inputValue non-empty, commit first; else clear
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (isOpen && searchRef.current && !searchRef.current.contains(event.target)) {
        if (provinces.length && inputValue) {
          handleSelect(provinces[0]);
        } else {
          handleSelect({name: '' });
        }
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [provinces, inputValue, isOpen, searchRef]);

  return (
    <div className="flex flex-col max-h-[70px]">
      <div ref={searchRef} className="relative w-full max-w-md">
        <label className="text-[11px] font-bold text-slate-400 uppercase mb-1.5 block ml-1">
          {label}
        </label>

        <div className="relative">
          <input
            type="text"
            className="w-full rounded-[10px] p-2 text-sm outline-none transition-all 
              border border-slate-200 bg-white-100 focus:border-blue-400"
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
            {provinces.length > 0 ? (
              provinces.map((province) => (
                <li
                  key={province.id ?? province.name}
                  className="px-4 py-2 hover:bg-blue-50 cursor-pointer text-gray-700 border-b last:border-none border-gray-100"
                  onMouseDown={(e) => { e.preventDefault(); e.stopPropagation(); handleSelect(province); }}
                >
                  {province.name}
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

export default SearchProvinces;