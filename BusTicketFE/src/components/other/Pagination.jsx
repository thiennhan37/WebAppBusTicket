import React, { useState, useEffect } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

const Pagination = ({ page, totalPages = 10, onPageChange }) => {
  const [inputValue, setInputValue] = useState(page);

  // Sync input khi page thay đổi từ parent
  useEffect(() => {
    setInputValue(page);
  }, [page]);

  const handleSubmit = (newPage) => {
    if (isNaN(newPage) || newPage < 1) newPage = 1;
    if (newPage > totalPages) newPage = totalPages;
    onPageChange?.(newPage);
    setInputValue(newPage);
    console.log(newPage);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter'){
        handleSubmit(Number(inputValue));
        
    }
  };

  const handleBlur = () => handleSubmit(Number(inputValue));

  return (
    <div className="flex items-center justify-center gap-2 pt-2">
      {/* Previous */}
      <button
        onClick={() => handleSubmit(page - 1)}
        disabled={page <= 1}
        className="p-2 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 disabled:opacity-30 transition-colors"
      >
        <ChevronLeft size={18} strokeWidth={2.5} />
      </button>

      {/* Input */}
      <input
        type="text"
        onChange={(e) => setInputValue(Number(e.target.value))}
        value={String(inputValue)}
        onKeyDown={handleKeyDown}
        onBlur={handleBlur}
        className="w-10 h-7 text-center font-bold text-blue-600 bg-white border-2 border-blue-100 rounded-lg 
        focus:border-blue-500 focus:ring-4 focus:ring-blue-50/50 outline-none transition-all
        [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
      />

      <span className="text-slate-400 font-medium mx-1">/ {totalPages}</span>

      {/* Next */}
      <button
        onClick={() => handleSubmit(page + 1)}
        disabled={page >= totalPages}
        className="p-2 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 disabled:opacity-30 transition-colors"
      >
        <ChevronRight size={18} strokeWidth={2.5} />
      </button>
    </div>
  );
};

export default Pagination;