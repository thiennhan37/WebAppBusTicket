
import { publicApi} from "./api";
import api from "./api";

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
    }, 
    changePassword({oldPassword, newPassword}){
        return api.put("/auth/change-password", {oldPassword, newPassword});
    },
    loginAdmin({email, password}){
        return publicApi.post("/admin/auth/login", {email, password});
    }
}

export default AuthenticateService