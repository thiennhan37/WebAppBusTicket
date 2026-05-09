import { AreaChart, ResponsiveContainer, CartesianGrid, XAxis, YAxis, Tooltip, Area } from "recharts";
import { Tooltip as RechartsTooltip } from 'recharts';

const RevenueChart = ({revenueData}) => {
    return (    
    <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm lg:col-span-2">
        <div className="flex justify-between items-center mb-6">
        <div>
            <h2 className="text-base font-bold text-slate-800">Doanh thu 7 ngày gần nhất</h2>
            <p className="text-xs text-slate-500">Đơn vị: Triệu VNĐ</p>
        </div>
        <div className="flex gap-2">
            <button className="px-3 py-1 bg-slate-100 text-xs font-medium rounded-lg hover:bg-slate-200 transition-colors">Tuần</button>
        </div>
        </div>
        <div className="h-72 w-full">
        <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={revenueData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
            <defs>
                <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
            <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#64748b' }} dy={10} />
            <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#64748b' }} />
            <RechartsTooltip 
                contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                cursor={{ stroke: '#94a3b8', strokeWidth: 1, strokeDasharray: '4 4' }}
            />
            <Area type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
            </AreaChart>
        </ResponsiveContainer>
        </div>
    </div>
    )
}
export default RevenueChart;