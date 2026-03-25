// import React from 'react';

// const InputGroup = ({ label, placeholder, disabled, type = 'text', options = [], icon: Icon }) => (
//   <div className="w-full">
//     <label className="text-[11px] font-bold text-slate-400 uppercase mb-1.5 block ml-1">
//       {label}
//     </label>
    
//     <div className="relative flex items-center">
//       {/* 1. Hiển thị Icon nếu có */}
//       {Icon && (
//         <div className="absolute left-3 text-slate-400">
//           <Icon size={16} />
//         </div>
//       )}

//       {/* 2. Phần Input / Select */}
//       {type === 'select' ? (
//         <select 
//           className={`w-full bg-slate-50 border border-slate-200 rounded-xl p-1.5 text-sm 
//           focus:ring-2 focus:ring-blue-500 outline-none transition-all appearance-none
//           ${Icon ? 'pl-9' : 'pl-3'}`} // Nếu có icon thì padding-left lớn hơn
//         >
//           {options.map(opt => <option key={opt}>{opt}</option>)}
//         </select>
//       ) : (
//         <input 
//           type={type} 
//           disabled={disabled}
//           className={`w-full border border-slate-200 rounded-xl p-1.5 text-sm 
//           focus:ring-2 focus:ring-blue-500 outline-none transition-all
//           ${disabled ? 'bg-slate-100 cursor-not-allowed text-slate-400' : 'bg-slate-50'} 
//           ${Icon ? 'pl-9' : 'pl-3'}`} // Đẩy chữ sang phải để không đè lên icon
//           placeholder={placeholder} 
//         />
//       )}
//     </div>
//   </div>
// );

// export default InputGroup;


const InputGroup = ({ label, placeholder, disabled, type = 'text', options = [], icon: Icon, value, onChange }) => (
  <div className="w-full">
    <label className="text-[11px] font-bold text-slate-400 uppercase mb-1.5 block ml-1">
      {label}
    </label>
    
    <div className="relative flex items-center">
      {Icon && <div className="absolute left-3 text-slate-400"><Icon size={16} /></div>}

      {type === 'select' ? (
        <select 
          value={value || ''} // Thêm value
          onChange={onChange} // Thêm onChange
          className={`w-full bg-slate-50 border border-slate-200 rounded-xl p-1.5 text-sm outline-none transition-all appearance-none ${Icon ? 'pl-9' : 'pl-3'}`}
        >
          <option value="">Chọn...</option>
          {options.map(opt => <option key={opt} value={opt}>{opt}</option>)}
        </select>
      ) : (
        <input 
          type={type} 
          disabled={disabled}
          value={value || ''} // Thêm value
          onChange={onChange} // Thêm onChange
          className={`w-full border border-slate-200 rounded-xl p-1.5 text-sm outline-none transition-all ${disabled ? 'bg-slate-100 cursor-not-allowed text-slate-400' : 'bg-slate-50'} ${Icon ? 'pl-9' : 'pl-3'}`}
          placeholder={placeholder} 
        />
      )}
    </div>
  </div>
);
export default InputGroup;