import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import MainLayout from "./layouts/MainLayout";
import HomePage from "./pages/HomePage/HomePage";
import SearchResultsPage from "./pages/SearchResults/SearchResultsPage";
import SeatSelectionPage from "./pages/SeatSelection/SeatSelectionPage";
import BookingPage from "./pages/Booking/BookingPage";
import OrderHistoryPage from "./pages/OrderHistory/OrderHistoryPage";
import OrderDetailPage from "./pages/OrderDetail/OrderDetailPage";
import LoginPage from "./pages/Login/LoginPage";
import RegisterPage from "./pages/Register/RegisterPage";
import ProfilePage from "./pages/Profile/ProfilePage";
import ProtectedRoute from "./components/ProtectedRoute";
import AuthProvider from "./context/AuthContext";
import { Toaster } from "sonner";

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Main Layout containing Header and Footer */}
          <Route path="/khachhang" element={<MainLayout />}>
            <Route index element={<HomePage />} />
            <Route path="ket-qua" element={<SearchResultsPage />} />
            <Route path="chon-ghe/:tripId" element={<SeatSelectionPage />} />
            <Route path="dat-ve/:tripId" element={<BookingPage />} />
            <Route
              path="don-hang"
              element={<OrderHistoryPage />}
            />
            <Route
              path="don-hang/:orderId"
              element={
                <ProtectedRoute>
                  <OrderDetailPage />
                </ProtectedRoute>
              }
            />
            <Route
              path="tai-khoan"
              element={
                <ProtectedRoute>
                  <ProfilePage />
                </ProtectedRoute>
              }
            />
            <Route path="dang-nhap" element={<LoginPage />} />
            <Route path="dang-ky" element={<RegisterPage />} />
          </Route>

          {/* Catch-all fallback redirect to main customer page */}
          <Route path="*" element={<Navigate to="/khachhang" replace />} />
        </Routes>
      </BrowserRouter>
      {/* Toast Alert popup notification provider */}
      <Toaster position="top-center" expand={false} richColors closeButton />
    </AuthProvider>
  );
}
