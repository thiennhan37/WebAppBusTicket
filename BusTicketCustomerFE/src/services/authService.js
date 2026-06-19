import { publicApi } from "./api";
import api from "./api";

export const sendOtp = (email) => {
  return publicApi.post("/auth/send-otp", { email });
};

export const verifyOtp = (email, otp) => {
  return publicApi.post("/auth/verify-otp", { email, otp });
};

export const initiateRegistration = (data) => {
  return publicApi.post("/register/init", data);
};

export const verifyRegistration = (email, otp) => {
  return publicApi.post("/register/verify", { email, otp });
};

export const getGoogleLoginUrl = () => {
  return publicApi.get("/auth/google/login");
};

export const googleCallback = (code) => {
  return publicApi.get(`/auth/google/callback?code=${code}`);
};

export const logout = (accessToken, refreshToken) => {
  return publicApi.post("/auth/log-out", { token: accessToken, refreshToken });
};

export const updateProfile = (data) => {
  return api.put("/customer/profile", data);
};

export const googleMobileRegister = (idToken, profile) => {
  return publicApi.post("/auth/google/mobile/register", { idToken, profile });
};
