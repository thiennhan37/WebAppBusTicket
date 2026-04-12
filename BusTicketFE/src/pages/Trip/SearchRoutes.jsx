import React, { useState, useRef, useEffect } from 'react';
import ProvinceService from "../../Services/ProvinceService";
import RouteService from '../../Services/routeService';

const SearchRoutes = ({ onChange, field, label, placeholder, initialValue, disabled }) => {
  const [inputValue, setInputValue] = useState(initialValue || "");
  const [isOpen, setIsOpen] = useState(false);
  const [routes, setRoutes] = useState([]);
  const searchRef = useRef(null);
  // if(initialValue) setInputValue(initialValue);
  // Fetch provinces with a small debounce while typing
  useEffect(() => {
    const controller = new AbortController();
    const handle = setTimeout(async () => {
      try {
        const params = { keyword: inputValue };
        const result = (await RouteService.getRoutes({ filterParams: params }))?.data?.result?.content || [];
        setRoutes(result);
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
  const handleSelect = (routeObj) => {
    const name = routeObj && routeObj.name ? routeObj.name : '';
    setInputValue(name);
    setIsOpen(false);
    if (onChange){
      // console.log(routeObj);
      onChange(field, routeObj);
    } 
  };

  // Click outside: if list has items and inputValue non-empty, commit first; else clear
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (isOpen && searchRef.current && !searchRef.current.contains(event.target)) {
        if (routes.length && inputValue) {
          handleSelect(routes[0]);
        } else {
          handleSelect({id: "", name: '' });
        }
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [routes, inputValue, isOpen, searchRef]);

  return (
    <div className="flex flex-col items-center max-h-[70px]">
      <div ref={searchRef} className="relative w-full max-w-md min-h-[200px]">
        <label className="text-[11px] font-bold text-slate-700 uppercase mb-1.5 block ml-1">
          {label}
        </label>

        <div className="relative">
          <input
            type="text"
            className="w-full rounded-xl p-2 text-sm outline-none transition-all border border-slate-200 bg-slate-50 
              focus:border-blue-400 disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed"
            placeholder={placeholder}
            value={inputValue}
            disabled={disabled}
            onChange={(e) => {
              setInputValue(e.target.value.split("(")[0]);
              setIsOpen(true);
            }}
            onFocus={() => setIsOpen(true)}
          />
        </div>

        {isOpen && (
          <ul className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">
            {routes.length > 0 ? (
              routes.map((route) => (
                <li
                  key={route.id ?? route.name}
                  className="px-4 py-2 hover:bg-blue-50 cursor-pointer text-gray-700 border-b last:border-none border-gray-100 text-sm"
                  onMouseDown={(e) => { e.preventDefault(); e.stopPropagation(); handleSelect(route); }}
                >
                  {`${route.name} (${route.arrivalProvince.name}-${route.destinationProvince.name})`}
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

export default SearchRoutes;