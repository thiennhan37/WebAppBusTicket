import {React,  useState } from 'react';
import HeroSection from './HeroSection';
import FormLogin from './FormLogin';
import FormRegister from './FormRegister';

const HomePage = () => {
  const [showModal, setShowModal] = useState(false);
  const [authMode, setAuthMode] = useState('login'); 

  const openModal = (mode) => {
    setAuthMode(mode);
    setShowModal(true);
  };

  return (
    <div className="min-h-screen bg-white font-sans text-slate-900">
      {/* --- NAVBAR --- */}
      <nav className="max-w-7xl mx-auto flex justify-between items-center px-6 py-6">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center shadow-lg shadow-blue-200">
            <span className="text-white font-bold text-xl">V</span>
          </div>
          <span className="font-bold text-xl tracking-tight">VEXEDAT</span>
        </div>
        
        {/* <div className="hidden md:flex items-center gap-10 text-gray-500 font-medium">
          <a href="#" className="hover:text-blue-600 transition-colors">Home</a>
          <a href="#" className="hover:text-blue-600 transition-colors">About</a>
        </div> */}

        <div className="flex items-center gap-2">
          <button 
            onClick={() => openModal('login')}
            className="px-5 py-2 text-gray-600 font-semibold hover:text-blue-600 transition"
          >
            Login
          </button>
          <button 
            onClick={() => openModal('register')}
            className="px-6 py-2.5 bg-blue-600 text-white rounded-xl font-semibold hover:bg-blue-700 transition shadow-lg shadow-blue-100"
          >
            Register
          </button>
        </div>
      </nav>

      {/* --- HERO SECTION --- */}
      <HeroSection openModal={openModal}></HeroSection>

      {/* --- MODAL LOGIN/REGISTER --- */}
      {showModal && (
        authMode === "login" ? <FormLogin setShowModal={setShowModal} setAuthMode={setAuthMode}></FormLogin>
        : <FormRegister setShowModal={setShowModal} setAuthMode={setAuthMode}></FormRegister>
      )} 
          


    </div>
  );
};

export default HomePage;