import { ArrowRight, Clock } from 'lucide-react';
const UpcomingTrips = ({upcomingTrips}) => {
    return (
        <div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm lg:col-span-2 overflow-hidden">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-base font-bold text-slate-800">Chuyến sắp khởi hành</h2>
            <button className="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1">
              Xem tất cả <ArrowRight size={16} />
            </button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="text-xs text-slate-500 border-b border-slate-100">
                  <th className="pb-3 font-medium">Chuyến</th>
                  <th className="pb-3 font-medium">Tuyến đường</th>
                  <th className="pb-3 font-medium">Loại xe</th>
                  <th className="pb-3 font-medium text-center">Tỉ lệ ghế</th>
                  <th className="pb-3 font-medium">Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                {upcomingTrips.map((trip, idx) => (
                  <tr key={idx} className="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                    <td className="py-4">
                      <div className="flex items-center gap-2">
                        <Clock size={16} className="text-slate-400" />
                        <span className="font-semibold text-slate-800 text-sm">{trip.time}</span>
                      </div>
                      <span className="text-xs text-slate-500 ml-6">{trip.id}</span>
                    </td>
                    <td className="py-4 text-sm text-slate-700 font-medium">{trip.route}</td>
                    <td className="py-4 text-sm text-slate-600">{trip.type}</td>
                    <td className="py-4 text-center">
                      <span className="inline-block px-2 py-1 bg-slate-100 text-slate-700 rounded text-xs font-medium">
                        {trip.fill}
                      </span>
                    </td>
                    <td className="py-4">
                      <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium
                        ${trip.status === 'Sắp khởi hành' ? 'bg-amber-100 text-amber-700' : 
                          trip.status === 'Đang đón khách' ? 'bg-emerald-100 text-emerald-700' : 
                          'bg-blue-100 text-blue-700'}`}
                      >
                        {trip.status}
                      </span>
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