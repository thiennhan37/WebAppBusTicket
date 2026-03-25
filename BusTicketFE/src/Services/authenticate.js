
import { publicApi } from "./api";

const AuthenticateService = {
    refreshToken({refreshToken}){
        return publicApi.post("/auth/refresh-token", {refreshToken});
    }, 
    loginCompany({email, password}){
        return publicApi.post("/nhaxe/auth/login", {email, password});
    }
    
}

export default AuthenticateService