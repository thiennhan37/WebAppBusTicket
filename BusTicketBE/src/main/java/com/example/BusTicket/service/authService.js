import axios from 'axios';

const API_URL = 'http://localhost:8080/api/v1/auth'; // Điều chỉnh port backend của bạn

export const getGoogleLoginUrl = async () => {
    // Gọi endpoint gọi đến AuthenticationService.buildGoogleLoginUrl()
    const response = await axios.get(`${API_URL}/google-url`);
    return response.data; // Giả định backend trả về chuỗi URL trực tiếp
};

export const loginWithGoogle = async (code) => {
    // Gọi endpoint gọi đến AuthenticationService.loginCustomerWithGoogle(code)
    const response = await axios.post(`${API_URL}/google-login`, null, {
        params: { code }
    });
    return response.data; 
};