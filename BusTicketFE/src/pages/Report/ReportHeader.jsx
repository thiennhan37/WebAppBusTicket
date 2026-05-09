import { motion } from "framer-motion";
import { CalendarDays, CreditCard, PlusCircle } from "lucide-react";

const ReportHeader = ({ itemVariants }) => {
{/* --- HEADER & SHORTCUTS --- */ }
    return(
      <motion.div variants={itemVariants} className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Thống kê hệ thống</h1>
          <p className="text-sm text-slate-500 mt-1">Hôm nay: {new Date().toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
        </div>
        <div className="flex gap-3">
          <button className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 text-slate-700 rounded-lg hover:bg-slate-50 transition-colors text-sm font-medium shadow-sm">
            <CalendarDays size={18} />
            Chuyến hôm nay
          </button>
          <button className="flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors text-sm font-medium shadow-sm">
            <CreditCard size={18} />
            Bán vé nhanh
          </button>
          <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium shadow-sm">
            <PlusCircle size={18} />
            Tạo chuyến
          </button>
        </div>
      </motion.div>
    );
}
export default ReportHeader;