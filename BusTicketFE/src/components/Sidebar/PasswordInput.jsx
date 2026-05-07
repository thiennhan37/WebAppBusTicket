import {Eye, EyeOff, Lock} from "lucide-react";

const PasswordInput = ({ showPwd, setShowPwd, label, value, onChange, placeholder }) => (
    <div className="flex flex-col space-y-1.5">
      <label className="text-sm font-medium text-slate-700 ml-1">
        {label}
      </label>
      <div className="relative group">
        <div className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-emerald-600 transition-colors">
          <Lock size={18} />
        </div>
        <input type={showPwd ? "text" : "password"} value={value} required
          onChange={e => onChange(e.target.value)} placeholder={placeholder}
          className="w-full pl-10 pr-10 py-2.5 bg-white border border-slate-200 rounded-xl text-sm shadow-sm 
                     focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 
                     transition-all placeholder:text-slate-400"
        />
        <button
          type="button"
          onClick={() => setShowPwd(!showPwd)}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors"
        >
          {showPwd ? <EyeOff size={18} /> : <Eye size={18} />}
        </button>
      </div>
    </div>
);
export default PasswordInput;