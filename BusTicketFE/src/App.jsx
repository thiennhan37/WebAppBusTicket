import {Routes, BrowserRouter, Route} from 'react-router-dom'
import './App.css'
import CompanyHeader from './components/CompanyHeader'
import SideBar from './components/SideBar'
import Trips from './pages/Trips'
import Overview from './pages/Overview'
import Tickets from './pages/Tickets'
import LocalRoutes from './pages/LocalRoutes'
import Report from './pages/Report'
import Rating from './pages/Rating'
import StaffManagement from './pages/StaffManagement/StaffManagement'
import HomePage from './pages/HomePage/HomePage'
import FormLogin from './pages/HomePage/FormLogin'
function App() {

  return (
    
    <BrowserRouter>
      <HomePage></HomePage>
      <div className="flex h-screen overflow-hidden bg-white hidden">
        
        <SideBar></SideBar>

        <div className="flex-1 flex flex-col min-w-0">
          <CompanyHeader />
          
          {/* Phần main: 
            - flex-1: chiếm hết phần còn lại
            - overflow-y-auto: chỉ cho phép cuộn bên trong vùng này nếu nội dung quá dài
            - scrollbar-hide: (tùy chọn) ẩn thanh cuộn nhưng vẫn cuộn được
          */}

          <main className="flex-1 p-0 bg-gray-50/30 overflow-y-auto scrollbar-hide">
            <div className="mb-8">
              <h2 className="text-2xl font-bold text-gray-800">Dashboard Overview</h2>
              <p className="text-gray-500">Welcome back! Here's what's happening today.</p>
            </div>
            
              

            <Routes>
              <Route path="/" element={<Overview/>}></Route>
              <Route path="/trips" element={<Trips/>}></Route>
              <Route path="/tickets" element={<Tickets/>}></Route>
              <Route path="/local-routes" element={<LocalRoutes/>}></Route>
              <Route path="/staff" element={<StaffManagement/>}></Route>
              <Route path="/report" element={<Report/>}></Route>
              <Route path="/rating" element={<Rating/>}></Route>
            </Routes>
            
          </main>
        </div>
      </div>
    </BrowserRouter>
  )
}

export default App
