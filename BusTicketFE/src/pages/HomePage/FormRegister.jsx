import {Mail, Lock, User, X, Building2, Building, PhoneCall, Phone} from "lucide-react"
import { useState } from "react";
import validator from 'validator';
import { useMutation } from "@tanstack/react-query";
import AuthenticateService from "../../Services/authenticate";
import LoadingOverlay from "../../components/other/LoadingOverlay";
import StatusModal from "../../components/other/StatusModal";
const FormRegister = ({setShowModal, setAuthMode}) => {
    const [phone, setPhone] = useState("");
    const [errorPhone, setErrorPhone] = useState("");
    const validatePhone = () =>{
        let message = "";
        if(validator.isMobilePhone(phone, "vi-VN")) message = "";
        else message = "Số điện thoại không hợp lệ";
        setErrorPhone(message);
        return message;
    }
    const handlePhoneChange = (e) =>{
        const value = e.target.value.replace(/\D/g, "");
        setPhone(value);
    }

    const [email, setEmail] = useState("");
    const [errorEmail, setErrorEmail] = useState("");
    const validateEmail = () =>{
        let message = "";
        if(validator.isEmail(email)) message = "";
        else message = "Email không hợp lệ";
        setErrorEmail(message);
        return message;
    }
    const handleEmailChange = (e) =>{
        setEmail(e.target.value);
    }
    const [hostName, setHostName] = useState("");
    const [errorHostName, setErrorHostName] = useState("");
    const validateHostName = () =>{
        let message = "";
        if(hostName && validator.isLength(hostName, { min: 2, max: 100 })) message = "";
        else message = "Tên không hợp lệ";
        setErrorHostName(message);
        return message;
    }
    const [companyName, setCompanyName] = useState("");
    const [errorCompanyName, setErrorCompanyName] = useState("");
    const validateCompanyName = () =>{
        let message = "";
        if(companyName && validator.isLength(companyName, { min: 2, max: 100 })) message = "";
        else message = "Tên công ty không hợp lệ";
        setErrorCompanyName(message);
        return message;
    }
    const [reportRegister, setReportRegister] = useState("");
    const hideReportRegister = () =>  setReportRegister("");
    const [errorRegister, setErrorRegister] = useState("");
    const handleErrorRegister = (message) => {
        setErrorRegister(message);
        setTimeout(() => {
            setErrorRegister("");
        }, 3000);
    }
    const handleRegister = () => {
        const errorHostName = validateHostName();
        const errorCompanyName = validateCompanyName();
        const errorEmail = validateEmail();
        const errorPhone = validatePhone();

        if(errorHostName || errorCompanyName || errorEmail || errorPhone){
            // console.log("validation errors", {errorHostName, errorCompanyName, errorEmail, errorPhone});
            return;
        }
        // console.log("registering with", {email, phone, companyName, hostName});
        register({email, hotline:phone, companyName, hostName});
    }
    const {mutate: register, } = useMutation({
        mutationFn: async (data) => {
            const result = await AuthenticateService.registerCompany(data);
            return result;
        }, 
        onMutate: () => {
            setReportRegister("pending");
        },
        onError: () => {
            hideReportRegister();
            handleErrorRegister('Thông tin đăng ký không hợp lệ hoặc đã tồn tại');
        }, 
        onSuccess: () => {
            setEmail("");
            setPhone("");
            setCompanyName("");
            setHostName("");
            setReportRegister("success");
        }
    });
    

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

                <form className="" onSubmit={(e) => {
                    e.preventDefault();
                    handleRegister();
                }}>
                    <div className="relative">
                        <User className={`absolute left-4 top-4 transition-colors ${errorHostName ? 'text-red-500' : 'text-gray-400'}`} size={18} />
                        <input 
                            type="text" 
                            placeholder="Host Name"
                            className={`w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl 
                            focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all
                            ${errorHostName 
                                ? 'border-red-500 focus:ring-2 focus:ring-red-500 bg-red-50' 
                                : 'border-gray-100 focus:ring-2 focus:ring-blue-500 focus:bg-white'
                                }`}
                            value={hostName}
                            onChange={(e) => setHostName(e.target.value)}
                            onFocus={() => {setErrorHostName("")}}
                        />
                        <div className="min-h-[26px] pl-4">
                            {errorHostName && (
                                <p className="text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                    {errorHostName}
                                </p>
                            )}
                        </div>
                    </div>
                    

                    <div className="relative">

                        <Building2 className={`absolute left-4 top-4 transition-colors ${errorCompanyName ? 'text-red-500' : 'text-gray-400'}`} size={18} />
                        <input 
                            type="text" 
                            placeholder="Company Name"
                            className={`w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl 
                            focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all
                            ${errorCompanyName 
                                ? 'border-red-500 focus:ring-2 focus:ring-red-500 bg-red-50' 
                                : 'border-gray-100 focus:ring-2 focus:ring-blue-500 focus:bg-white'
                                }`}
                            value={companyName}
                            onChange={(e) => setCompanyName(e.target.value)}
                            onFocus={() => {setErrorCompanyName("")}}
                        />
                        <div className="min-h-[26px] pl-4">
                            {errorCompanyName && (
                                <p className="text-sm text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                    {errorCompanyName}
                                </p>
                            )}
                        </div>
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

                    <div className="min-h-[30px] pt-3">
                        {errorRegister && (
                            <p className="text-sm text-left text-red-500 font-medium animate-in fade-in slide-in-from-top-1">
                                {errorRegister}
                            </p>
                        )}
                    </div>
                    <button className="mt-3 w-full py-4 bg-blue-600 text-white font-bold rounded-2xl hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all transform active:scale-[0.98] "
                    >
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

          {/* {reportRegister === "pending" && <LoadingOverlay ></LoadingOverlay>} */}
          {reportRegister === "success" && <StatusModal type="success" message={"Đăng ký thành công"} 
            onClose={() => {hideReportRegister(); setShowModal(false)}}></StatusModal>}
        </div>
    )
}

export default FormRegister;