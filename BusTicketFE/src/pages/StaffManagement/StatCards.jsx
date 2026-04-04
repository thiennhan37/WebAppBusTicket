import React from "react";
import { Users, Tickets, UserCog, LockKeyhole } from "lucide-react";
import StatCard from "../../components/other/StatCard";
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

export default StatCards