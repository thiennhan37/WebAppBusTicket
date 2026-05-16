
import { Outlet } from "react-router-dom";
import AdminHeader from "../pages/AdminHome/AdminHeader";
import AdminSidebar from "../pages/AdminHome/AdminSidebar";


export default function AdminLayout() {
  return (
    <div className="flex h-screen bg-slate-950 overflow-hidden">
      <AdminSidebar />

      <div className="flex-1 flex flex-col">
        <AdminHeader />

        <main className="flex-1 overflow-y-auto p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}