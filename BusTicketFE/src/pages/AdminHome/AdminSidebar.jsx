import {LayoutDashboard,Users,Bus,BarChart3,LogOut,ClipboardList} from "lucide-react";

import { NavLink, useNavigate } from "react-router-dom";
import AuthContext from "../../context/AuthContext";
import AuthenticateService from "../../Services/authenticate";
import { toast } from "sonner";
import { useContext } from "react";

const menus = [
  {title: "Dashboard", icon: LayoutDashboard, path: "/admin/dashboard"},
  {title: "Nhà xe", icon: Bus, path: "/admin/companies"},
  {title: "Yêu cầu đăng ký", icon: ClipboardList, path: "/admin/register-company"},
  {title: "Người dùng", icon: Users, path: "/admin/users"},
  {title: "Báo cáo", icon: BarChart3, path: "/admin/reports"},
]; 

export default function Sidebar() {
  const {logout} = useContext(AuthContext);
  const navigate = useNavigate();

  const handleLogout = () => {
    const accessToken = localStorage.getItem("accessToken");
    const response = AuthenticateService.logout({accessToken});
    logout();
    // navigate("/admin");
  }

  return (
    <div className="w-[280px] bg-slate-950 border-r border-white/10 flex flex-col">
      {/* Logo */}
      <div className="h-20 flex items-center px-6 border-b border-white/10">
        <div>
          <h1 className="text-white font-bold text-2xl">
            Bus Admin
          </h1>

          <p className="text-slate-400 text-sm">
            Management System
          </p>
        </div>
      </div>

      {/* Menu */}
      <div className="flex-1 p-4 space-y-2">
        {menus.map((item) => {
          const Icon = item.icon;

          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) =>
                `flex items-center gap-4 px-4 py-4 rounded-2xl transition-all ${
                  isActive
                    ? "bg-blue-600 text-white"
                    : "text-slate-400 hover:bg-white/5 hover:text-white"
                }`
              }
            >
              <Icon size={22} />

              <span className="font-medium">
                {item.title}
              </span>
            </NavLink>
          );
        })}
      </div>

      {/* Logout */}
      <div className="p-4 border-t border-white/10">
        <button
          className="w-full flex items-center gap-3 px-4 py-4 rounded-2xl text-red-400 hover:bg-red-500/10 transition"
          onClick={handleLogout}
        >
          <LogOut size={20} />

          Đăng xuất
        </button>
      </div>
    </div>
  );
}