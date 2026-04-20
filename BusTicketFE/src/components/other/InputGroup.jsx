import { ChevronDown } from "lucide-react";

const InputGroup = ({ label, placeholder, disabled, type = 'text', options = [], icon: Icon, value, onChange, error}) => {
  // console.log("reload inputgroup")

  return (
    
    <div className="w-full">
      <label className="text-[11px] font-bold text-slate-700 uppercase mb-1.5 block ml-1">
        {label}
      </label>
      
      <div className="relative flex items-center">
        {Icon && <div className="absolute left-3 text-slate-400"><Icon size={16} /></div>}

        {type === 'select' ? (
          <div className="relative w-full">
            <select 
              value={value || ''} 
              onChange={onChange || (() => {})} 
              disabled={disabled}
              className={`w-full bg-slate-50 border rounded-xl p-2 text-sm outline-none transition-all appearance-none 
                ${error 
                  ? 'border-red-500 bg-red-50' 
                  : 'border-slate-200 focus:border-blue-400 focus:ring-2 focus:ring-blue-50'} 
                ${disabled ? 'bg-slate-200 cursor-not-allowed text-slate-400' : 'cursor-pointer text-slate-700'} 
                ${Icon ? 'pl-9' : 'pl-3'} pr-10`} // pr-10 để không bị chữ đè lên Chevron
            >
              {/* Nếu có placeholder cho select */}
              {placeholder && <option value="" disabled>{placeholder}</option>}
              {options.map(opt => {
                const isObject = typeof opt === 'object';

                const optionValue = isObject ? opt.id : opt;
                const optionLabel = isObject ? opt.name : opt;

                return (
                  <option key={optionValue} value={optionLabel}>
                    {optionLabel}
                  </option>
                );
              })}
            </select>
            
            {/* Icon ChevronDown ở cuối */}
            <div className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400">
              <ChevronDown size={16} />
            </div>
          </div>
        ) : (
          <input 
            type={type} 
            value={value || ''} 
            lang="vi-VN"
            onChange={onChange || (() => {})}
            readOnly={!onChange}              
            disabled={disabled}
            placeholder={placeholder}
            className={`w-full rounded-xl p-1.5 text-sm outline-none transition-all 
                ${error 
                  ? 'border border-red-500 bg-red-50 focus:ring-1 focus:ring-red-200' 
                  : 'border border-slate-200 bg-slate-50 focus:border-blue-400'} 
                ${disabled ? 'bg-slate-200 cursor-not-allowed text-slate-400' : ''} 
                ${Icon ? 'pl-9' : 'pl-3'}`}
          />
        )}
      </div>
    </div>
  );
}


export default InputGroup;