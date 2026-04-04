import {Routes, BrowserRouter, Route} from 'react-router-dom'
import './App.css'
import CompanyLayout from './layout/CompanyLayout'
import HomePage from './pages/HomePage/HomePage'
import AuthProvider from './Provider/AuthProvider'
import ProtectedRoute from './routes/ProtectedRoute'
import Overview from './pages/Overview'
import Trips from './pages/Trips'
import Tickets from './pages/Tickets'
import LocalRoutes from './pages/LocalRoute/LocalRoutes'
import Report from './pages/Report'
import Rating from './pages/Rating'
import StaffManagement from './pages/StaffManagement/StaffManagement'
function App() { 
              {/* <div className="mb-8">
              <h2 className="text-2xl font-bold text-gray-800">Dashboard Overview</h2>
              <p className="text-gray-500">Welcome back! Here's what's happening today.</p>
            </div> */}
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>

          <Route path='/nhaxe' element={<HomePage/>}></Route>
          <Route element={<ProtectedRoute type="company"/>}>
              <Route element={<CompanyLayout/>}>
                <Route path="/nhaxe/overview" element={<Overview/>}></Route>
                <Route path="/nhaxe/trips" element={<Trips/>}></Route>
                <Route path="/nhaxe/tickets" element={<Tickets/>}></Route>
                <Route path="/nhaxe/local-routes" element={<LocalRoutes/>}></Route>
                <Route path="/nhaxe/staff" element={<StaffManagement/>}></Route>
                <Route path="/nhaxe/report" element={<Report/>}></Route>
                <Route path="/nhaxe/rating" element={<Rating/>}></Route>
            </Route>
          </Route>
          <Route path="*" element={<div>Trang không tồn tại</div>} />

        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}

export default App
