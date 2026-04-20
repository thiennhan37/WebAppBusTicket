import React, { useState, useEffect, useRef } from 'react';
import { MapPin } from 'lucide-react';
import RouteService from '../../Services/routeService';
import { useQuery } from '@tanstack/react-query';

const RouteStops = ({ routeId }) => {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  const { data, isLoading } = useQuery({
    queryKey: ['routeStops', routeId],
    queryFn: async () => {
      const upResponse = (await RouteService.getRouteStop({ routeId, params: { type: "UP" } }))?.data?.result;
      const downResponse = (await RouteService.getRouteStop({ routeId, params: { type: "DOWN" } }))?.data?.result;
      
      return { upResponse, downResponse};
    },
    enabled: !!isOpen,
    staleTime: Infinity,
  });

  const upRouteStop = data?.upResponse || [];
  const downRouteStop = data?.downResponse || [];


  // Đóng dropdown khi click ra ngoài
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    if (isOpen) document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen]);
  return (
    <div className="relative inline-block" ref={dropdownRef}>

      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`p-2 transition-all duration-200 rounded-full hover:bg-blue-50 focus:outline-none ring-offset-2 ${
          isOpen ? 'bg-blue-100 ring-2 ring-blue-500' : 'text-blue-600'
        }`}
      >
        <MapPin size={24} />
      </button>

      {/* Dropdown Menu */}
      {isOpen && (
        <div 
          className="absolute left-0 bottom-full mb-3 w-[350px] md:w-[450px] bg-white rounded-xl shadow-2xl border border-gray-100 ring-1 ring-black ring-opacity-5 focus:outline-none z-[999]"
          style={{ filter: 'drop-shadow(0 10px 15px rgba(0, 0, 0, 0.1))' }}
        >
          {/* Mũi tên nhỏ (Tooltip Arrow) */}
          <div className="absolute -bottom-1.5 left-4 w-3 h-3 bg-white border-b border-r border-gray-100 rotate-45 transform"></div>

          <div className="relative p-4 overflow-y-auto">
            {isLoading ? (
              <div className="flex items-center justify-center py-4 space-x-2">
                <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce [animation-delay:-0.3s]"></div>
                <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce [animation-delay:-0.15s]"></div>
                <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce"></div>
              </div>
            ) : (
              <div className="flex w-full gap-2">
                {/* Nhóm Điểm Đón */}
                <section className="flex-1">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="w-2.5 h-2.5 rounded-full bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]" />
                    <h4 className="text-xs font-bold uppercase tracking-wider text-emerald-700">Điểm đón khách</h4>
                  </div>
                  <ul className="space-y-2 ml-1.5 border-l-2 border-emerald-50 border-dashed pl-4">
                    {upRouteStop.map((routeStop) => (
                      <li key={`up-${routeStop.stop.id}`} className="text-sm text-gray-700 hover:text-blue-600 transition-colors cursor-default">
                        {routeStop.stop.name}
                      </li>
                    ))}
                    {upRouteStop.length === 0 && <li className="text-xs text-gray-400 italic">Không có dữ liệu</li>}
                  </ul>
                </section>

                <div className="border-t border-gray-50" />

                {/* Nhóm Điểm Trả */}
                <section className="flex-1">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="w-2.5 h-2.5 rounded-full bg-rose-500 shadow-[0_0_8px_rgba(244,63,94,0.5)]" />
                    <h4 className="text-xs font-bold uppercase tracking-wider text-rose-700">Điểm trả khách</h4>
                  </div>
                  <ul className="space-y-2 ml-1.5 border-l-2 border-rose-50 border-dashed pl-4">
                    {downRouteStop.map((routeStop) => (
                      <li key={`down-${routeStop.stop.id}`} className="text-sm text-gray-700 hover:text-blue-600 transition-colors cursor-default">
                        {routeStop.stop.name}
                      </li>
                    ))}
                    {downRouteStop.length === 0 && <li className="text-xs text-gray-400 italic">Không có dữ liệu</li>}
                  </ul>
                </section>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default RouteStops;