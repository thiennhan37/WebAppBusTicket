import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip as RechartsTooltip, Legend } from 'recharts';
import { MousePointer2, PhoneCall, Globe, Store, CheckCircle2, Clock3, AlertCircle } from 'lucide-react';

// Mock data cho các kênh bán vé
const TicketStatus = [
  { name: 'Đã thanh toán', value: 450, color: '#3b82f6' },   // Blue
  { name: 'Đang xử lí', value: 300, color: '#8b5cf6' },  // Violet
  { name: 'Đã hủy', value: 200, color: '#10b981' },  // Emerald
  { name: 'Đã hết hạn', value: 150, color: '#f59e0b' },    // Amber
];

const channelData = [
  { label: 'Qua tổng đài', count: 850, percent: 75, icon: CheckCircle2, color: 'text-emerald-500', bg: 'bg-emerald-50' },
  { label: 'Qua app', count: 210, percent: 18, icon: Clock3, color: 'text-amber-500', bg: 'bg-amber-50' },
];

const SalesChannel = () => {
  return (
    <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm h-full flex flex-col">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-base font-bold text-slate-800">Trạng thái thanh toán</h2>
        <span className="text-[11px] font-medium bg-slate-100 text-slate-500 px-2 py-1 rounded">Hôm nay</span>
      </div>

      {/* Biểu đồ tròn Donut */}
      <div className="h-48 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={TicketStatus}
              innerRadius={60}
              outerRadius={80}
              paddingAngle={5}
              dataKey="value"
            >
              {TicketStatus.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={entry.color} />
              ))}
            </Pie>
            <RechartsTooltip 
               contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>

      {/* Chi tiết kênh bán (Dạng List) */}
      <div className="grid grid-cols-2 gap-3 mb-6">
        {TicketStatus.map((item, idx) => (
          <div key={idx} className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full" style={{ backgroundColor: item.color }}></div>
            <span className="text-xs text-slate-600 font-medium">{item.name}:</span>
            <span className="text-xs text-slate-900 font-bold">{item.value}</span>
          </div>
        ))}
      </div>

      <div className="border-t border-slate-50 pt-6 mt-auto">
        <h3 className="text-sm font-bold text-slate-800 mb-4">Phân bổ nguồn vé </h3>
        <div className="space-y-4">
          {channelData.map((status, idx) => (
            <div key={idx}>
              <div className="flex justify-between items-center mb-1.5">
                <div className="flex items-center gap-2">
                  {/* <div className={`p-1 rounded ${status.bg}`}>
                    <status.icon size={14} className={status.color} />
                  </div> */}
                  <span className="text-xs font-medium text-slate-600">{status.label}</span>
                </div>
                <span className="text-xs font-bold text-slate-800">{status.count} vé</span>
              </div>
              <div className="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden">
                <div 
                  className={`h-full rounded-full ${status.color.replace('text', 'bg')}`} 
                  style={{ width: `${status.percent}%` }}
                ></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default SalesChannel;