
import { 
  LayoutDashboard, Users, Tickets, Route, 
  BarChart3, BusFront, ChartNoAxesCombined , Star 
} from 'lucide-react';
import { NavLink } from "react-router-dom";
import AuthContext from "../../context/AuthContext";
import UserProfile from "./UserProfile";
const menuItems = [
  { icon: LayoutDashboard, label: 'Tổng quan', link:'overview', active: true },
  { icon: BusFront, label: 'Chuyến đi', link:'trips', active: false },
  { icon: Tickets, label: 'Vé', link:'ticket', active: false },
  { icon: Route, label: 'Tuyến đường', link:'local-routes', active: false },
  { icon: Users, label: 'Nhân sự', link:'staff', active: false },
  { icon: ChartNoAxesCombined, label: 'Thống kê', link:'report', active: false },
  { icon: Star, label: 'Đánh giá', link:'rating', active: false },
];
const SideBar = () =>{
    // const [activeTab, setActiveTab] = useState("");
    // const handleNavClick = (e, navName) => {
    //     e.preventDefault(); 
    //     setActiveTab(navName);
    // };
    // const {user} = useContext(AuthContext)
    return (
    <div className="w-64 h-screen bg-white border-r border-gray-200 flex flex-col">
      {/* Logo Section */}
      <div className="p-6 border-b-2 border-slate-200">
        <h1 className="text-2xl font-bold text-slate-800">VEXEDAT</h1>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 px-4 space-y-1">
        {menuItems.map((item) => (
          <NavLink
            key={item.link}
            to={`/nhaxe/${item.link}`}
            // onClick={(e) => handleNavClick(e, item.link)}
            
            className={({isActive}) =>
                `flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 ${isActive 
                  ? 'bg-blue-50 text-blue-600 shadow-sm' 
                  : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'}`
            }
          >
            {({isActive}) =>(
              <>
                <item.icon 
                  size={20} 
                  strokeWidth={isActive ? 3 : 2} 
                />
                <span className={`text-[15px] ${isActive ? 'font-bold' : 'font-medium'}`}>
                  {item.label}
                </span>
              </>
            )}
          </NavLink>
        ))}
      </nav>
      <UserProfile></UserProfile>
      
    </div>
  );
}

export default SideBar;