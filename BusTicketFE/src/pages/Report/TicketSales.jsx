import { BarChart, ResponsiveContainer, CartesianGrid, XAxis, YAxis, Tooltip, Bar, Cell } from "recharts";

const TicketSales = ({ routesData }) => {
  // salesData dự kiến có cấu trúc: [{ route: "Hà Nội - Hải Phòng", soldCount: 150 }, ...]

  return (
    <div className="bg-green-50 p-6 rounded-2xl border border-slate-100 shadow-sm">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-base font-bold text-slate-800">Hiệu suất bán vé theo tuyến</h2>
          <p className="text-xs text-slate-500">Tổng số vé bán được trong tháng này</p>
        </div>
      </div>

      <div className="h-80 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={routesData}
            layout="vertical"
            margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
          >
            <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f1f5f9" />
            
            {/* Trục X hiển thị số lượng vé */}
            <XAxis type="number" hide />
            
            {/* Trục Y hiển thị tên tuyến đường */}
            <YAxis 
              dataKey="route" 
              type="category" 
              axisLine={false} 
              tickLine={false} 
              tick={{ fontSize: 12, fill: '#64748b', fontWeight: 500 }} 
              width={100}
            />

            <Tooltip 
              cursor={{ fill: 'none' }}
              contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
              formatter={(value) => [`${value} vé`, 'Số lượng bán']}
            />

            {/* Thanh Bar hiển thị hiệu suất */}
            <Bar 
              dataKey="soldCount" 
              fill="#3b82f6" 
              radius={[0, 4, 4, 0]} 
              barSize={20}
              label={{ position: 'right', fill: '#648b70ff', fontSize: 12, offset: 10 }}
            >
              {/* Bạn có thể đổi màu sắc khác nhau cho mỗi thanh nếu muốn */}
              {routesData?.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={index === 0 ? '#2563eb' : '#3b82f6'} opacity={1 - index * 0.1} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default TicketSales;