
import { publicApi } from "./api";

const AuthenticateService = {
    refreshToken({refreshToken}){
        return publicApi.post("/auth/refresh-token", {refreshToken});
    }, 
    loginCompany({email, password}){
        return publicApi.post("/nhaxe/auth/login", {email, password});
    }, 
    registerCompany({email, hostName, companyName, hotline}){
        return publicApi.post("/nhaxe/auth/register", {email, hostName, companyName, hotline});
    }
    
}

export default AuthenticateService