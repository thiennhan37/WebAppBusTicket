import React, { useState, useContext } from "react";
import {Mail,Lock,Eye,EyeOff,ShieldCheck,BusFront,} from "lucide-react";
import { useNavigate } from "react-router-dom";
import AuthContext from "../../context/AuthContext";
import validator from "validator"
import { useMutation } from "@tanstack/react-query";
import AuthenticateService from "../../Services/authenticate";
import { toast } from 'sonner';

export default function AdminHome() { 
//   const { user, signIn } = useContext(AuthContext);
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const {loginAdmin} = useContext(AuthContext);

  const {mutate: handleLogin} = useMutation({
    mutationFn: async (e) => {
      e.preventDefault();
      let message = ""
        if(!password || password.length < 6) message += " Mật khẩu phải có ít nhất 6 ký tự!"
        else if(!validator.isEmail(email)) message += " Email không hợp lệ!"
        if(message !== "") {
            throw new Error(message); 
        }
        const response = await AuthenticateService.loginAdmin({email, password});
        if(loginAdmin) loginAdmin(response.data.result);  
        return response.data; 
    },
    onSuccess: (data) => {
      toast.success("Đăng nhập thành công!");
      navigate("/admin/dashboard");
    }, 
    onError: (error) => {
      toast.error(error?.response?.data?.message || error?.message || "Đăng nhập thất bại!");
    }
  })

  return (
    <div className="min-h-screen bg-slate-950 flex items-center justify-center px-4 relative overflow-hidden">
      {/* Background Glow */}
      <div className="absolute w-[500px] h-[500px] bg-blue-600/20 blur-3xl rounded-full top-[-100px] left-[-100px]" />
      <div className="absolute w-[400px] h-[400px] bg-cyan-500/20 blur-3xl rounded-full bottom-[-100px] right-[-100px]" />

      <div className="w-full max-w-6xl grid lg:grid-cols-2 rounded-3xl overflow-hidden shadow-2xl border border-white/10 backdrop-blur-xl bg-white/5">
        
        {/* Left Side */}
        <div className="hidden lg:flex flex-col justify-between p-12 bg-gradient-to-br from-blue-700 via-slate-900 to-slate-950 text-white relative">
          <div>
            <div className="flex items-center gap-3 mb-8">
              <div className="w-14 h-14 rounded-2xl bg-white/10 flex items-center justify-center backdrop-blur-md">
                <BusFront size={30} />
              </div>

              <div>
                <h1 className="text-2xl font-bold">Bus Admin</h1>
                <p className="text-slate-300 text-sm">Hệ thống quản lý đặt vé xe</p>
              </div>
            </div>

            <h2 className="text-4xl font-bold leading-tight mb-6">Quản lý hệ thống vận tải thông minh</h2>

            <p className="text-slate-300 leading-relaxed">
              Theo dõi chuyến xe, quản lý tài khoản, doanh thu và toàn bộ hoạt
              động đặt vé trên một nền tảng hiện đại.
            </p>
          </div>

          <div className="grid grid-cols-2 gap-4 mt-10">
            <div className="bg-white/5 border border-white/10 rounded-2xl p-5">
              <h3 className="text-3xl font-bold">24/7</h3>
              <p className="text-slate-300 text-sm mt-2">Giám sát hệ thống liên tục</p>
            </div>

            <div className="bg-white/5 border border-white/10 rounded-2xl p-5">
              <h3 className="text-3xl font-bold">99%</h3>
              <p className="text-slate-300 text-sm mt-2">Độ ổn định hệ thống</p>
            </div>
          </div>
        </div>

        {/* Right Side */}
        <div className="p-8 sm:p-12 bg-slate-900/80 backdrop-blur-xl">
          <div className="max-w-md mx-auto">
            <div className="flex justify-center lg:hidden mb-8">
              <div className="w-16 h-16 rounded-2xl bg-blue-600 flex items-center justify-center shadow-lg">
                <BusFront className="text-white" size={30} />
              </div>
            </div>

            <div className="text-center lg:text-left mb-8">
              <div className="inline-flex items-center gap-2 bg-blue-500/10 border border-blue-500/20 text-blue-400 px-4 py-2 rounded-full text-sm font-medium mb-5">
                <ShieldCheck size={18} />Admin Portal
              </div>
              <h2 className="text-3xl font-bold text-white mb-2">Đăng nhập quản trị</h2>
              <p className="text-slate-400">Vui lòng đăng nhập để truy cập hệ thống quản lý</p>
            </div>

            <form className="space-y-5" onSubmit={(e)=> handleLogin(e)}>
              <div>
                <label className="block text-slate-300 mb-2 text-sm font-medium">Email</label>
                <div className="relative">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" size={20} />
                  <input type="email" placeholder="admin@gmail.com" 
                    value={email} onChange={e => setEmail(e.target.value)}
                    className="w-full bg-slate-800/80 border border-slate-700 focus:border-blue-500 outline-none rounded-2xl py-4 pl-12 pr-4 text-white transition-all"
                  />
                </div>
              </div>

              <div>
                <label className="block text-slate-300 mb-2 text-sm font-medium">Mật khẩu</label>
                <div className="relative">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-500" size={20}/>
                  <input
                    type={showPassword ? "text" : "password"} 
                    value={password} onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••"
                    className="w-full bg-slate-800/80 border border-slate-700 focus:border-blue-500 outline-none rounded-2xl py-4 pl-12 pr-14 text-white transition-all"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white transition"
                  >
                    {showPassword ? (<EyeOff size={20} />) : (<Eye size={20} />)}
                  </button>
                </div>
              </div>

              {/* Remember */}
              <div className="flex items-center justify-between text-sm">
                <label className="flex items-center gap-2 text-slate-400">
                  <input type="checkbox" className="w-4 h-4 rounded border-slate-600 bg-slate-800"/>
                  Ghi nhớ đăng nhập
                </label>
                <button type="button" className="text-blue-400 hover:text-blue-300 transition">
                  Quên mật khẩu?
                </button>
              </div>

              {/* Button */}
              <button type="submit"
                className="w-full bg-gradient-to-r from-blue-600 to-cyan-500 hover:opacity-90 transition-all text-white font-semibold py-4 rounded-2xl shadow-lg shadow-blue-500/20"
              >
                Đăng nhập
              </button>
            </form>

            {/* Footer */}
            <div className="mt-10 text-center text-slate-500 text-sm">
              © 2026 Bus Ticket Admin System
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}