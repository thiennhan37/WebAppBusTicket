import {Mail, Lock, X, Eye, EyeOff, ArrowLeft} from "lucide-react"
import { useState } from "react";
import validator from 'validator';
import authenticate from "../../Services/authenticate"
import { useContext } from "react";
import AuthContext from "../../context/AuthContext";
import { useNavigate } from "react-router-dom";
import { useMutation } from "@tanstack/react-query";
import StatusModal from "../../components/other/StatusModal";

const FormLogin = ({setShowModal, setAuthMode}) => {
    const [showPassword, setShowPassword] = useState(false);
    const [showForgotPassword, setShowForgotPassword] = useState(false);
    const [email, setEmail] = useState("");
    const [errorEmail, setErrorEmail] = useState("");
    const validateEmail = () =>{
        let message = "";
        if(validator.isEmail(email)) message = "";
        else message = "Email không hợp lệ";
        setErrorEmail(message);
        return message;
    }

    const [password, setPassword] = useState("");
    const[errorLogin, setErrorLogin] = useState("");
    const [forgotReport, setForgotReport] = useState("");
    const [errorForgot, setErrorForgot] = useState("");
    
    
    const {login} = useContext(AuthContext);
    const navigate = useNavigate();
    const {mutate: handleLogin} = useMutation({
        mutationFn: async () => {
            const errorEmail = validateEmail();
            if(errorEmail)  return;
            const response = await authenticate.loginCompany({email, password});
            return response;
        },
        onSuccess: (response) => {
            login(response.data.result);
            navigate("/nhaxe/overview"); 
        },
        onError: (error) => {
            const statusCode = error.response?.status;
            let message;
            if(statusCode === 401) message = "Email hoặc mật khẩu không chính xác";
            else if(statusCode === 403) message = "Tài khoản của bạn đã bị khóa";
            else if(statusCode === 500) message = "Đã có lỗi xảy ra, vui lòng thử lại sau";
            
            setErrorLogin(error.response?.data?.message || message || "Đã có lỗi xảy ra, vui lòng thử lại sau");
        } 
    });

    const {mutate: handleForgotPassword, isPending: isForgotPending} = useMutation({
        mutationFn: async () => {
            const errorEmail = validateEmail();
            if(errorEmail) return;
            const response = await authenticate.forgotPassword({email});
            return response;
        },
        onSuccess: () => {
            setForgotReport("success");
        },
        onError: (error) => {
            const statusCode = error.response?.status;
            let message;
            if(statusCode === 403) message = "Tài khoản của bạn đã bị khóa";
            else message = error.response?.data?.message || "Đã có lỗi xảy ra, vui lòng thử lại sau";
            setErrorForgot(message);
        }
    });

    const handleBackToLogin = () => {
        setShowForgotPassword(false);
        setErrorForgot("");
        setForgotReport("");
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div 
                className="absolute inset-0 bg-slate-900/40 backdrop-blur-md transition-opacity"
                onClick={() => setShowModal(false)}
            ></div>
            <div className="relative bg-white w-full max-w-md rounded-[2rem] shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-300">
                <button 
                    onClick={() => setShowModal(false)}
                    className="absolute top-6 right-6 p-2 text-gray-400 hover:text-gray-600 transition-colors"
                >
                    <X size={24} />
                </button>
                <div className="p-10">
                {showForgotPassword ? (
                    <>
                        <button
                            type="button"
                            onClick={handleBackToLogin}
                            className="flex items-center gap-2 text-gray-500 hover:text-gray-700 transition-colors mb-6"
                        >
                            <ArrowLeft size={18} />
                            <span className="text-sm font-medium">Quay lại đăng nhập</span>
                        </button>

                        <div className="text-center mb-10">
                            <h3 className="text-3xl font-bold text-slate-800">
                                Quên mật khẩu
                            </h3>
                            <p className="text-gray-500 mt-2">
                                Nhập email đã đăng ký, chúng tôi sẽ gửi mật khẩu mới về hộp thư của bạn
                            </p>
                        </div>

                        <form onSubmit={(e) => {e.preventDefault(); handleForgotPassword()}}>
                            <div className="relative">
                                <Mail className={`absolute left-4 top-4 transition-colors ${errorEmail ? 'text-red-500' : 'text-gray-400'}`} size={18}/>
                                <input 
                                    type="email"
                                    name="forgot-email"
                                    autoComplete="email"
                                    placeholder="Email Address"
                                    className={`w-full pl-12 pr-4 py-3 bg-gray-50 border rounded-2xl transition-all focus:outline-none 
                                        ${errorEmail 
                                        ? 'border-red-500 focus:ring-2 focus:ring-red-500 bg-red-50' 
                                        : 'border-gray-100 focus:ring-2 focus:ring-blue-500 focus:bg-white'
                                        }`}
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    onFocus={() => {setErrorEmail(""); setErrorForgot("");}}
                                />
                                <div className="min-h-[26px] pl-4">
                                    {errorEmail && (
                                        <p className="text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                            {errorEmail}
                                        </p>
                                    )}
                                </div>
                            </div>

                            <div className="min-h-[30px] pl-1 mb-2">
                                {errorForgot && (
                                    <p className="text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                        {errorForgot}
                                    </p>
                                )}
                            </div>

                            <button
                                className="w-full py-4 bg-blue-600 text-white font-bold rounded-2xl 
                                    hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all transform active:scale-[0.98] disabled:opacity-60 disabled:cursor-not-allowed"
                                type="submit"
                                disabled={isForgotPending}
                            >
                                {isForgotPending ? "Đang gửi..." : "Gửi mật khẩu mới"}
                            </button>
                        </form>
                    </>
                ) : (
                    <>
                        <div className="text-center mb-10">
                            <h3 className="text-3xl font-bold text-slate-800">
                            Welcome Back
                            </h3>
                            <p className="text-gray-500 mt-2">
                            Enter your details to access your account
                            </p>
                        </div>

                        <form className="" onSubmit={(e) => {e.preventDefault(); handleLogin()}}>

                            <div className="relative">
                                <Mail className={`absolute left-4 top-4 transition-colors ${errorEmail ? 'text-red-500' : 'text-gray-400'}`} size={18}/>
                                <input 
                                    type="text"
                                    name="email"
                                    autoComplete="username"
                                    placeholder="Email Address"
                                    className={`w-full pl-12 pr-4 py-3 bg-gray-50 border rounded-2xl transition-all focus:outline-none 
                                        ${errorEmail 
                                        ? 'border-red-500 focus:ring-2 focus:ring-red-500 bg-red-50' 
                                        : 'border-gray-100 focus:ring-2 focus:ring-blue-500 focus:bg-white'
                                        }`}
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    onFocus={() => {setErrorEmail("")}}
                                />
                                <div className="min-h-[26px] pl-4">
                                    {errorEmail && (
                                        <p className="text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                            {errorEmail}
                                        </p>
                                    )}
                                </div>
                            </div>

                            <div className="relative pb-4">
                                <Lock className="absolute left-4 top-4 text-gray-400" size={18} />
                                <input 
                                    required
                                    type={showPassword ? "text" : "password"} 
                                    name="password"
                                    autoComplete="current-password"
                                    placeholder="Password"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    className="w-full pl-12 pr-12 py-3 bg-gray-50 border border-gray-100 rounded-2xl 
                                    focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                                />

                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute right-4 top-3.5 text-gray-400 hover:text-gray-600 transition-colors"
                                >
                                    {showPassword ? (<EyeOff size={20} />) : (<Eye size={20} />)}
                                </button>
                                <div className="flex justify-end mt-2">
                                    <button
                                        type="button"
                                        onClick={() => {
                                            setShowForgotPassword(true);
                                            setErrorLogin("");
                                        }}
                                        className="text-sm text-blue-600 font-medium hover:underline"
                                    >
                                        Quên mật khẩu?
                                    </button>
                                </div>
                                <div className="min-h-[30px] pl-5 pt-3">
                                    {errorLogin && (
                                        <p className="text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                            {errorLogin}
                                        </p>
                                    )}
                                </div>
                            </div>

                            <button className="w-full py-4 bg-blue-600 text-white font-bold rounded-2xl 
                                hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all transform active:scale-[0.98] mt-2" 
                            type="submit">
                                Sign In
                            </button>
                        </form>

                        <div className="mt-10 text-center text-gray-500">
                            <span>
                                New here? {' '}
                                <button onClick={() => setAuthMode('register')} className="text-blue-600 font-bold hover:underline">Register now</button>
                            </span>
                        </div>
                    </>
                )}
                </div>
            </div>

            {forgotReport === "success" && (
                <StatusModal
                    type="success"
                    message="Mật khẩu mới đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư và đăng nhập lại."
                    onClose={() => {
                        setForgotReport("");
                        handleBackToLogin();
                    }}
                />
            )}
        </div>
    )
}

export default FormLogin;
