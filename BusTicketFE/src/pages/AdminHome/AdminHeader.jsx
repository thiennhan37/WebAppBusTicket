import { Bell, Search } from "lucide-react";

export default function AdminHeader() {
  return (
    <div className="h-20 border-b border-white/10 bg-slate-900 px-8 flex items-center justify-end">
      {/* Right */}
      <div className="flex items-center gap-5 mr-8">
        <button className="relative w-12 h-12 rounded-2xl bg-slate-800 flex items-center justify-center text-slate-300">
          <Bell size={20} />

          <div className="absolute top-2 right-2 w-2 h-2 rounded-full bg-red-500" />
        </button>

        <div className="flex items-center gap-3">
          <img
            src="https://i.pravatar.cc/100"
            className="w-12 h-12 rounded-2xl object-cover"
          />

          <div>
            <h3 className="text-white font-semibold">
              Admin
            </h3>

            <p className="text-slate-400 text-sm">
              Super Administrator
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}