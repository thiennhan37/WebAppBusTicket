import React from "react";
import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function ProtectedRoute({ children }) {
  const { isAuthenticated, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="page-loader" style={{ minHeight: "100vh" }}>
        <div className="brutal-spinner"></div>
        <p>Đang tải thông tin tài khoản...</p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to={`/khachhang/dang-nhap?redirect=${encodeURIComponent(location.pathname)}`} replace />;
  }

  return children;
}
