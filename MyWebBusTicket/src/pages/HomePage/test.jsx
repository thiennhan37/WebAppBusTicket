import React, { useState } from 'react';
import { X, User, Lock, Mail } from 'lucide-react';
import HeroSection from './HeroSection';

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
          <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center shadow-lg shadow-blue-200">
            <span className="text-white font-bold text-xl">T</span>
          </div>
          <span className="font-bold text-xl tracking-tight">VEXEDAT</span>
        </div>
        
        <div className="hidden md:flex items-center gap-10 text-gray-500 font-medium">
          <a href="#" className="hover:text-blue-600 transition-colors">Home</a>
          <a href="#" className="hover:text-blue-600 transition-colors">About</a>
        </div>

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
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Lớp phủ xám (Overlay) */}
          <div 
            className="absolute inset-0 bg-slate-900/40 backdrop-blur-md transition-opacity"
            onClick={() => setShowModal(false)}
          ></div>

          {/* Form Modal */}
          <div className="relative bg-white w-full max-w-md rounded-[2rem] shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-300">
            <button 
              onClick={() => setShowModal(false)}
              className="absolute top-6 right-6 p-2 text-gray-400 hover:text-gray-600 transition-colors"
            >
              <X size={24} />
            </button>

            <div className="p-10">
              <div className="text-center mb-10">
                <h3 className="text-3xl font-bold text-slate-800">
                  {authMode === 'login' ? 'Welcome Back' : 'Get Started'}
                </h3>
                <p className="text-gray-500 mt-2">
                  {authMode === 'login' ? 'Enter your details to access your account' : 'Create an account to join the event'}
                </p>
              </div>

              <form className="space-y-5" onSubmit={(e) => e.preventDefault()}>
                {authMode === 'register' && (
                  <div className="relative">
                    <User className="absolute left-4 top-4 text-gray-400" size={18} />
                    <input 
                      type="text" 
                      placeholder="Full Name"
                      className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                    />
                  </div>
                )}
                
                <div className="relative">
                  <Mail className="absolute left-4 top-4 text-gray-400" size={18} />
                  <input 
                    type="email" 
                    placeholder="Email Address"
                    className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                  />
                </div>

                <div className="relative">
                  <Lock className="absolute left-4 top-4 text-gray-400" size={18} />
                  <input 
                    type="password" 
                    placeholder="Password"
                    className="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                  />
                </div>

                <button className="w-full py-4 bg-blue-600 text-white font-bold rounded-2xl hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all transform active:scale-[0.98] mt-2">
                  {authMode === 'login' ? 'Sign In' : 'Create Account'}
                </button>
              </form>

              <div className="mt-10 text-center text-gray-500">
                {authMode === 'login' ? (
                  <span>
                    New here? {' '}
                    <button onClick={() => setAuthMode('register')} className="text-blue-600 font-bold hover:underline">Register now</button>
                  </span>
                ) : (
                  <span>
                    Already a member? {' '}
                    <button onClick={() => setAuthMode('login')} className="text-blue-600 font-bold hover:underline">Sign in</button>
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default HomePage;