import { useState, useEffect } from "react";
import AuthContext from "../context/AuthContext";

const AuthProvider = ({children}) => {
    // can xem xet độ dư thừa
    const [user, setUser] = useState(null);
    const [company, setCompany] = useState(null);
    const [loading, setLoading] = useState(true);
    useEffect(() =>{
        const savedUser = localStorage.getItem("user");
        if(savedUser){
            //eslint-disable-next-line
            setUser(JSON.parse(savedUser));
        }
        const savedCompany = localStorage.getItem("company");
        if(savedCompany){
            //eslint-disable-next-line
            setCompany(JSON.parse(savedCompany));
        }
        setLoading(false);
    }, [])

    const login = (data) => {
        localStorage.setItem("accessToken", data.accessToken);
        localStorage.setItem("user", JSON.stringify(data.user));
        localStorage.setItem("company", JSON.stringify(data.company));
        setUser(data.user);
        setCompany(data.company);
    }
    const logout = () => {
        localStorage.clear();
        setUser(null);
        setCompany(null);
    }
    return <AuthContext.Provider value={{user, login, logout, loading, company}}> 
        {!loading && children}
    </AuthContext.Provider>
}

export default AuthProvider;