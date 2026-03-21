import VeXeDat_Logo from '../../assets/VeXeDat_Logo.png';
import {ChevronRight } from 'lucide-react';
const HeroSection = ({openModal}) => {

    return (
              <main className="max-w-7xl mx-auto px-6 pt-16 pb-24 flex flex-col md:flex-row items-center">
        <div className="md:w-1/2 space-y-8 animate-in slide-in-from-left duration-700">
          <h1 className="text-3xl md:text-4xl font-extrabold leading-[1.1] tracking-tight text-blue-600">
             HỆ THỐNG WEBSITE NHÀ XE VEXEDAT
          </h1>
          <p className="text-gray-500 text-lg max-w-lg leading-relaxed">
            <span className="text-blue-400 text-2xl max-w-lg leading-relaxed">
              Giúp nhà xe tăng <span className="font-bold">30% doanh thu </span> 
              và <span className="font-bold">giảm 20% chi phí, </span>được 
              <span className="font-bold"> &gt;80%</span> thị phần nhà xe có sử dụng phần mềm tin dùng.
              </span>
              <br /> <br />
            Vexedat là chuyên gia trong lĩnh vực ứng dụng công nghệ, giúp nhà xe bán vé hiệu quả, phát triển thương hiệu và quản lý toàn diện.
          </p>
          <div className="pt-4">
            <button 
              onClick={() => openModal('register')}
              className="px-8 py-4 bg-blue-600 text-white rounded-2xl font-bold flex items-center gap-3 hover:bg-blue-700 transition-all shadow-xl shadow-blue-200 hover:-translate-y-1"
            >
              Register now <ChevronRight size={20} />
            </button>
          </div>
        </div>

        <div className="md:w-1/2 relative flex justify-center mt-16 md:mt-0 animate-in fade-in zoom-in duration-1000">
           {/* Hình ảnh minh họa */}
           <div className="w-full max-w-md aspect-square rounded-full border-[12px] border-blue-50 overflow-hidden shadow-2xl relative z-10">
              <img 
                src={VeXeDat_Logo}
                alt="hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh" 
                className="w-full h-full object-cover"
              />
           </div>
           {/* Họa tiết trang trí */}
           <div className="absolute -top-10 -right-10 text-blue-100 grid grid-cols-5 gap-3 opacity-60">
             {[...Array(25)].map((_, i) => <div key={i} className="w-2.5 h-2.5 bg-current rounded-full"></div>)}
           </div>
           <div className="absolute -bottom-6 -left-6 w-32 h-32 bg-blue-50 rounded-full -z-0 opacity-50"></div>
        </div>
      </main>
    )
}

export default HeroSection;