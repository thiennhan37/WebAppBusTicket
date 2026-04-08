import {Mail, Lock, User, X, Building2, Building, PhoneCall, Phone} from "lucide-react"
import { useState } from "react";
import validator from 'validator';
const FormRegister = ({setShowModal, setAuthMode}) => {
    const [phone, setPhone] = useState("");
    const [errorPhone, setErrorPhone] = useState("");
    const validatePhone = () =>{
        if(validator.isMobilePhone(phone, "vi-VN") || !phone) setErrorPhone("");
        else setErrorPhone("Số điện thoại không hợp lệ")
    }
    const handlePhoneChange = (e) =>{
        const value = e.target.value.replace(/\D/g, "");
        setPhone(value);
    }

    const [email, setEmail] = useState("");
    const [errorEmail, setErrorEmail] = useState("");
    const validateEmail = () =>{
        if(validator.isEmail(email) || !email) setErrorEmail("");
        else setErrorEmail("Email không hợp lệ")
    }
    const handleEmailChange = (e) =>{
        setEmail(e.target.value);
    }
    // const {mutate: register} = useRegister();
    
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
                <div className="text-center mb-5">
                    <h3 className="text-3xl font-bold text-slate-800">
                    Get Started
                    </h3>
                    <p className="text-gray-500 mt-2">
                    Become a Partner to Sell Bus Tickets
                    </p>
                </div>

                <form className="" onSubmit={(e) => e.preventDefault()}>

                    <div className="relative">
                        <User className="absolute left-4 top-4 text-gray-400" size={18} />
                        <input 
                        type="text" 
                        placeholder="Full Name"
                        className="w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl 
                        focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                        />
                        <div className="min-h-[20px]"></div>
                    </div>
                    

                    <div className="relative">

                        <Building2 className="absolute left-4 top-4 text-gray-400" size={18} />
                        <input 
                            type="text" 
                            placeholder="Company Name"
                            className="w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl 
                            focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                        />
                        <div className="min-h-[20px]"></div>
                    </div>
                    

                    <div className="relative">

                        <Mail className={`absolute left-4 top-4 transition-colors ${errorEmail ? 'text-red-500' : 'text-gray-400'}`} size={18}/>
                        <input 
                            type="text" 
                            placeholder="Email Address"
                            className={`w-full pl-12 pr-4 py-3 bg-gray-50 border rounded-2xl transition-all focus:outline-none 
                                ${errorEmail 
                                ? 'border-red-500 focus:ring-2 focus:ring-red-500 bg-red-50' 
                                : 'border-gray-100 focus:ring-2 focus:ring-blue-500 focus:bg-white'
                                }`}
                            value={email}
                            onBlur={validateEmail}
                            onChange={handleEmailChange}
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

                    <div className="relative">
                        <Phone className={`absolute left-4 top-4 transition-colors ${errorPhone ? 'text-red-500' : 'text-gray-400'}`} size={18}/>
                        <input 
                            type="phone" 
                            placeholder="Phone Number"
                            value={phone}
                            className={`w-full pl-12 pr-4 py-3 bg-gray-50 border rounded-2xl transition-all focus:outline-none 
                                ${errorPhone 
                                ? 'border-red-500 focus:ring-2 focus:ring-red-200 bg-red-50' 
                                : 'border-gray-100 focus:ring-2 focus:ring-blue-500 focus:bg-white'
                                }`}
                            onBlur={validatePhone}
                            onChange={handlePhoneChange}
                            onFocus={() => {setErrorPhone("")}}
                        />
                        <div className="min-h-[26px] pl-4">
                            {errorPhone && (
                                <p className="mt-0 ml-0 text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                {errorPhone}
                                </p>
                            )}
                        </div>
                    </div>


                    <button className="mt-3 w-full py-4 bg-blue-600 text-white font-bold rounded-2xl hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all transform active:scale-[0.98] ">
                    Create Account
                    </button>
                </form>

                <div className="mt-10 text-center text-gray-500">
                    <span>
                        Already a member? {' '}
                        <button onClick={() => setAuthMode('login')} className="text-blue-600 font-bold hover:underline">Sign in</button>
                    </span>
                </div>
                </div>
            </div>
        </div>
    )
}

export default FormRegister;