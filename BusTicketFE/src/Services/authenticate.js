
import { publicApi } from "./api";

const AuthenticateService = {
    refreshToken(){
        return publicApi.post("/auth/refresh-token", {});
    }, 
    loginCompany({email, password}){
        return publicApi.post("/nhaxe/auth/login", {email, password});
    }, 
    logout({accessToken}){
        return publicApi.post("/auth/logout", {accessToken});
    }, 
    registerCompany({email, hostName, companyName, hotline}){
        return publicApi.post("/nhaxe/auth/register", {email, hostName, companyName, hotline});
    }
}

export default AuthenticateService