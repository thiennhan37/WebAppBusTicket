import React from 'react';
import { Search, Bell, Handshake } from 'lucide-react';

const CompanyHeader = () => {
  const companyRaw = localStorage.getItem("company");
  const companyName = companyRaw ? JSON.parse(companyRaw).name : "";
  return (
    <header className="h-20 bg-white border-b border-gray-100 flex items-center justify-between px-8">
      {/* Search Bar */}
      <div className="relative w-96">
        <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400">
          <Search size={18} />
        </span>
        <input
          type="text"
          className="block w-full pl-10 pr-3 py-2 border border-gray-200 rounded-xl bg-gray-50 
          focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all text-sm"
          placeholder="Search..."
        />
      </div>

      <div className="flex items-center gap-2 px-4 py-1.5 bg-blue-50 text-blue-600 border border-blue-200 rounded-full w-fit shadow-sm">
          <Handshake size={18} className="text-blue-500" />
          <span className="font-medium text-sm tracking-wide uppercase">
              {companyName}
          </span>
      </div>
      {/* Right Icons */}
      <div className="flex items-center gap-4">
        <button className="relative p-2 text-gray-500 hover:bg-gray-100 rounded-full transition-colors">
          <Bell size={22} />
          {/* Notification Badge */}
          <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full border-2 border-white"></span>
        </button>
      </div>
    </header>
  );
};

export default CompanyHeader;