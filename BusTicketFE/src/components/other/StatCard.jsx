import React from "react";
const StatCard = ({ title, count, icon, colorClass, textColor}) => (
  <div className={`${colorClass} p-4 rounded-2xl shadow-lg shadow-gray-200 flex items-center justify-between relative overflow-hidden group`}>
    <div className="relative z-10">
      <p className={`${textColor} opacity-80 text-xs uppercase tracking-wider font-bold`}>{title}</p>
      <h3 className={`${textColor} text-2xl font-black mt-1`}>{count}</h3>
    </div>
    <div className={`p-3 rounded-xl bg-white/20 ${textColor} relative z-10`}>
      {React.cloneElement(icon, { size: 28 })}
    </div>
    {/* Họa tiết nền trang trí */}
    <div className="absolute -right-4 -bottom-4 w-24 h-24 bg-white/10 rounded-full group-hover:scale-150 transition-transform duration-500"></div>
  </div>
);

export default StatCard;