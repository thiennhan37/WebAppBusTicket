import React, { useState, useEffect, useRef } from 'react';

const ProvinceSearch = () => {
  const [inputValue, setInputValue] = useState('');
  const [suggestions, setSuggestions] = useState([]);
  const [isOpen, setIsOpen] = useState(false);
  const wrapperRef = useRef(null);

  // Danh sách mẫu
  const provinces = [
    "Quảng Bình", "Quảng Nam", "Quảng Ngãi", "Quảng Ninh", "Quảng Trị",
    "Hà Nội", "TP. Hồ Chí Minh", "Đà Nẵng", "Hải Phòng", "Cần Thơ"
  ];

  // Xử lý khi nhập text
  const handleInputChange = (e) => {
    const value = e.target.value;
    setInputValue(value);

    if (value.length > 0) {
      const filtered = provinces.filter(p =>
        p.toLowerCase().includes(value.toLowerCase())
      );
      setSuggestions(filtered);
      setIsOpen(true);
    } else {
      setSuggestions([]);
      setIsOpen(false);
    }
  };

  // Đóng dropdown khi click ra ngoài
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const selectProvince = (name) => {
    setInputValue(name);
    setIsOpen(false);
  };

  return (
    <div className="p-10 bg-gray-100 min-h-screen">
      <div className="relative w-80 mx-auto" ref={wrapperRef}>
        {/* Input Field */}
        <div className="flex items-center border-2 border-blue-500 rounded-md bg-white p-2 shadow-sm">
          <div className="text-blue-500 mr-2">
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11H9v2H7v2h2v2h2v-2h2V9h-2V7z"/></svg>
          </div>
          <div className="flex-1">
            <p className="text-xs text-gray-400">Nơi xuất phát</p>
            <input
              type="text"
              className="w-full outline-none text-lg font-semibold"
              value={inputValue}
              onChange={handleInputChange}
              onFocus={() => inputValue && setIsOpen(true)}
            />
          </div>
        </div>

        {/* Dropdown Suggestions */}
        {isOpen && suggestions.length > 0 && (
          <div className="absolute w-full mt-1 bg-white border border-gray-200 rounded-md shadow-lg z-10 max-h-60 overflow-y-auto">
            {/* Note Section */}
            <div className="p-3 bg-orange-50 border-b border-orange-100">
              <p className="text-sm text-gray-700">
                <span className="text-red-500 font-bold">*Lưu ý:</span> Sử dụng tên địa phương trước sáp nhập
              </p>
            </div>

            {/* Header */}
            <div className="p-2 text-sm text-gray-400 bg-gray-50">
              Tỉnh - Thành Phố
            </div>

            {/* List */}
            <ul>
              {suggestions.map((item, index) => (
                <li
                  key={index}
                  className="px-4 py-3 hover:bg-blue-50 cursor-pointer text-gray-700 border-b border-gray-50 last:border-none"
                  onClick={() => selectProvince(item)}
                >
                  {item}
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
};

export default ProvinceSearch;