import React from "react";
import { Outlet } from "react-router-dom";
import Header from "../components/Header";
import Footer from "../components/Footer";

export default function MainLayout() {
  return (
    <>
      <Header />
      <main style={{ flex: 1, minHeight: "calc(100vh - var(--header-height) - 150px)" }}>
        <Outlet />
      </main>
      <Footer />
    </>
  );
}
