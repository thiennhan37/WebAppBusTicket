import {Routes, BrowserRouter, Route} from 'react-router-dom'
import './App.css'
import CompanyLayout from './layout/CompanyLayout'
import HomePage from './pages/HomePage/HomePage'
import AuthProvider from './Provider/AuthProvider'
import ProtectedRoute from './routes/ProtectedRoute' 
import Overview from './pages/Overview/Overview'
import Trips from "./pages/Trip/Trips"
import Ticket from './pages/Ticket/Ticket'
import LocalRoutes from './pages/LocalRoute/LocalRoutes'
import Report from './pages/Report/Report'
import Rating from './pages/Rating'
import StaffManagement from './pages/StaffManagement/StaffManagement'
import PaymentSuccess from './components/generalComponent/PaymentSuccess'
import RedirectPayment from './pages/Payment/RedirectPayment'
import { Toaster } from 'sonner'
import AdminHome from './pages/AdminHome/AdminHome'
import AdminLayout from './layout/AdminLayout'
import AdminDashboard from './pages/AdminDashBoard/AdminDashBoard'
import AdminManageCompany from './pages/AdminManageCompany/AdminManageCompany'
import AdminRegisterCompany from './pages/AdminRegisterCompany/AdminRegisterCompany'

function App() { 
  return (
    <AuthProvider>
      <BrowserRouter>
      
        <Toaster position="top-right" richColors />

        <Routes>
          <Route path='/payment-success' element={<PaymentSuccess/>}></Route>
          <Route path='/redirect-momo/payment/:paymentId' element={<RedirectPayment/>}></Route>
          <Route path='/nhaxe' element={<HomePage/>}></Route>
          <Route path='/admin' element={<AdminHome/>}></Route>

          <Route element={<ProtectedRoute type="company"/>}>
              <Route element={<CompanyLayout/>}>
                <Route path="/nhaxe/overview" element={<Overview/>}></Route>
                <Route path="/nhaxe/trips" element={<Trips/>}></Route>
                <Route path="/nhaxe/ticket" element={<Ticket/>}></Route>
                <Route path="/nhaxe/local-routes" element={<LocalRoutes/>}></Route>
                <Route path="/nhaxe/staff" element={<StaffManagement/>}></Route>
                <Route path="/nhaxe/report" element={<Report/>}></Route>
                <Route path="/nhaxe/rating" element={<Rating/>}></Route>
            </Route>
          </Route>

          <Route element={<ProtectedRoute type="admin" />}>
            <Route element={<AdminLayout />}>
              <Route path="/admin/dashboard" element={<AdminDashboard />} />
              {/* <Route path="/admin/users" element={<UsersPage />} /> */}
              <Route path="/admin/companies" element={<AdminManageCompany />} />
              <Route path="/admin/register-company" element={<AdminRegisterCompany />} />
              {/* <Route path="/admin/reports" element={<AdminReportsPage />} /> */}
            </Route>
          </Route>

          <Route path="*" element={<div>Trang không tồn tại</div>} />

        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}

export default App
