import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip as RechartsTooltip, Legend } from 'recharts';
import { MousePointer2, PhoneCall, Globe, Store, CheckCircle2, Clock3, AlertCircle } from 'lucide-react';



const SalesChannel = ({TicketStatus, channelData}) => {
  return (
    <div className="bg-red-50 p-6 rounded-2xl border border-slate-100 shadow-sm h-full flex flex-col">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-base font-bold text-slate-700">Trạng thái thanh toán</h2>
        <button className="px-3 py-1 bg-slate-300 text-xs font-medium rounded-lg hover:bg-slate-400 
          transition-colors hover:cursor-pointer">Tháng</button>
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
              <div className="w-full bg-slate-300 h-1.5 rounded-full overflow-hidden">
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