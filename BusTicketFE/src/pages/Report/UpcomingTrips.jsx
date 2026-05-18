import { ArrowRight, Clock, Tag } from 'lucide-react';
const UpcomingTrips = ({upcomingTrips}) => {
  const formatter = new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  });

    return (
        <div className="bg-yellow-50 p-6 rounded-2xl border border-slate-200 shadow-sm lg:col-span-2 overflow-hidden">
          <div className="flex justify-between items-center mb-8"> 
            <h2 className="text-base font-bold text-slate-800">Chuyến sắp khởi hành</h2>
            {/* <button className="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1">
              Xem tất cả <ArrowRight size={16} />
            </button> */}
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="text-xs text-slate-500 border-b border-slate-100">
                  <th className="pb-3 font-medium">Chuyến</th>
                  <th className="pb-3 font-medium">Tuyến đường</th>
                  <th className="pb-3 font-medium">Loại xe</th>
                  <th className="pb-3 font-medium text-center">Giá vé</th>
                </tr>
              </thead>
              <tbody>
                {upcomingTrips.map((trip, idx) => (
                  <tr key={idx} className="border-b border-slate-50 hover:bg-yellow-100 transition-colors">
                    <td className="py-3">
                      <div className="flex items-center gap-2">
                        <Clock size={16} className="text-slate-400" />
                        <span className="font-semibold text-red-500 text-sm">{trip.departureTime.replace("T", " ").substring(0, 19)}</span>
                      </div> 
                      <span className="text-xs text-blue-500 font-bold ml-6">{trip.id}</span>
                    </td>
                    <td className="py-3 text-sm text-slate-700 font-medium">{trip.route?.name}</td>
                    <td className="py-3 text-sm text-slate-600">{trip.busType?.name}</td>
                    <td className="py-3 flex items-center gap-2 text-emerald-600 font-semibold">
                      <Tag size={16} />
                      <span>{trip?.price ? formatter.format(trip.price): "Chưa có"}</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
    )
}

export default UpcomingTrips;