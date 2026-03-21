import React from "react";
import { Users, Tickets, UserCog, LockKeyhole } from "lucide-react";
const StatCards = () =>{
    return (
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-10 mb-4">
        <StatCard title="Tổng Nhân viên" count={25} icon={<Users />} colorClass="bg-blue-600" textColor="text-white" />
        <StatCard title="Nhân viên bán vé" count="18" icon={<Tickets />} colorClass="bg-emerald-500" textColor="text-white" />
        <StatCard title="Quản lí" count="5" icon={<UserCog />} colorClass="bg-amber-500" textColor="text-white" />
        <StatCard title="Tài khoản bị khóa" count="3" icon={<LockKeyhole />} colorClass="bg-rose-500" textColor="text-white"/>
      </div>
    )
}
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
export default StatCards