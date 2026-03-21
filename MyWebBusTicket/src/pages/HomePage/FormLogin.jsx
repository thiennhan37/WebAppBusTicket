import {Mail, Lock, X} from "lucide-react"
const FormLogin = ({setShowModal, setAuthMode}) => {
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
                <div className="text-center mb-10">
                    <h3 className="text-3xl font-bold text-slate-800">
                    Welcome Back
                    </h3>
                    <p className="text-gray-500 mt-2">
                    Enter your details to access your account
                    </p>
                </div>

                <form className="space-y-5" onSubmit={(e) => e.preventDefault()}>

                    <div className="relative">
                    <Mail className="absolute left-4 top-4 text-gray-400" size={18} />
                    <input 
                        type="email" 
                        placeholder="Email Address"
                        className="w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                    />
                    </div>

                    <div className="relative">
                    <Lock className="absolute left-4 top-4 text-gray-400" size={18} />
                    <input 
                        type="password" 
                        placeholder="Password"
                        className="w-full pl-12 pr-4 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all"
                    />
                    </div>

                    <button className="w-full py-4 bg-blue-600 text-white font-bold rounded-2xl 
                    hover:bg-blue-700 shadow-xl shadow-blue-100 transition-all transform active:scale-[0.98] mt-2">
                        Sign In
                    </button>
                </form>

                <div className="mt-10 text-center text-gray-500">
                    <span>
                        New here? {' '}
                        <button onClick={() => setAuthMode('register')} className="text-blue-600 font-bold hover:underline">Register now</button>
                    </span>
                </div>
                </div>
            </div>
        </div>
    )
}

export default FormLogin;