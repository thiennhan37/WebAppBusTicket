import { BarChart, ResponsiveContainer, CartesianGrid, XAxis, YAxis, Tooltip, Legend, Bar } from "recharts";
import { Tooltip as RechartsTooltip } from 'recharts';

const RateTrip = ({fillRateData}) => {
    return (
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm">
            <div className="flex justify-between items-center mb-6">
            <h2 className="text-base font-bold text-slate-800">Tỉ lệ lấp đầy (Top tuyến)</h2>
            </div>
            <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
                <BarChart data={fillRateData} layout="vertical" margin={{ top: 0, right: 0, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#e2e8f0" />
                <XAxis type="number" hide />
                <YAxis dataKey="route" type="category" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: '#475569' }} width={90} />
                <RechartsTooltip cursor={{ fill: 'transparent' }} />
                <Legend iconType="circle" wrapperStyle={{ fontSize: '12px' }}/>
                <Bar dataKey="booked" name="Đã đặt" stackId="a" fill="#10b981" radius={[0, 0, 0, 0]} barSize={16} />
                <Bar dataKey="total" name="Trống" stackId="a" fill="#e2e8f0" radius={[0, 4, 4, 0]} barSize={16} />
                </BarChart>
            </ResponsiveContainer>
            </div>
        </div>
    )
}
export default RateTrip;