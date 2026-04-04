const InputGroup = ({ label, placeholder, disabled, type = 'text', options = [], icon: Icon, value, onChange, error}) => {
  // console.log("reload inputgroup")
  return (
    
    <div className="w-full">
      {/* {console.log("quynh ", error)} */}
      <label className="text-[11px] font-bold text-slate-400 uppercase mb-1.5 block ml-1">
        {label}
      </label>
      
      <div className="relative flex items-center">
        {Icon && <div className="absolute left-3 text-slate-400"><Icon size={16} /></div>}

        {type === 'select' ? (
          <select 
            value={value || ''} 
            onChange={onChange || (() => {})} // 
            disabled={disabled}
            className={`w-full bg-slate-50 border border-slate-200 rounded-xl p-1.5 text-sm outline-none transition-all appearance-none 
              ${Icon ? 'pl-9' : 'pl-3'}`}
          >
            {options.map(opt => <option key={opt} value={opt}>{opt}</option>)}
          </select>
        ) : (
          <input 
            type={type} 
            value={value || ''} 
            onChange={onChange || (() => {})}
            readOnly={!onChange}              
            disabled={disabled}
            placeholder={placeholder}
            className={`w-full rounded-xl p-1.5 text-sm outline-none transition-all 
                ${error 
                  ? 'border border-red-500 bg-red-50 focus:ring-1 focus:ring-red-200' 
                  : 'border border-slate-200 bg-slate-50 focus:border-blue-400'} 
                ${disabled ? 'bg-slate-100 cursor-not-allowed text-slate-400' : ''} 
                ${Icon ? 'pl-9' : 'pl-3'}`}
          />
        )}
      </div>
    </div>
  );
}


export default InputGroup;