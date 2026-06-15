import React, { useEffect, useContext, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import AuthContext from '../../context/AuthContext';
import { getGoogleLoginUrl, loginWithGoogle } from '../../services/authService';

const Login = () => {
    const [searchParams] = useSearchParams();
    const { login } = useContext(AuthContext); // Giả định AuthContext có hàm login để lưu token
    const navigate = useNavigate();
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        const code = searchParams.get('code');
        if (code) {
            handleGoogleCallback(code);
        }
    }, [searchParams]);

    const handleGoogleCallback = async (code) => {
        setLoading(true);
        try {
            const data = await loginWithGoogle(code);
            // data bao gồm: accessToken, refreshToken, customerInfo
            login(data); // Lưu vào context/localStorage
            navigate('/customer/home');
        } catch (err) {
            setError("Đăng nhập Google thất bại. Vui lòng thử lại.");
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const onGoogleLoginClick = async () => {
        try {
            const url = await getGoogleLoginUrl();
            window.location.href = url; // Chuyển hướng sang trang chọn tài khoản Google
        } catch (err) {
            setError("Không thể kết nối với dịch vụ Google.");
        }
    };

    return (
        <div className="login-container">
            <h2>Đăng nhập khách hàng</h2>
            
            {error && <div className="error-message" style={{color: 'red'}}>{error}</div>}
            
            {loading ? (
                <p>Đang xử lý đăng nhập...</p>
            ) : (
                <button 
                    onClick={onGoogleLoginClick}
                    className="google-login-btn"
                    style={{
                        display: 'flex',
                        alignItems: 'center',
                        padding: '10px 20px',
                        backgroundColor: '#fff',
                        border: '1px solid #ddd',
                        borderRadius: '4px',
                        cursor: 'pointer',
                        fontWeight: 'bold'
                    }}
                >
                    <img 
                        src="https://developers.google.com/identity/images/g-logo.png" 
                        alt="Google" 
                        style={{width: '20px', marginRight: '10px'}}
                    />
                    Tiếp tục với Google
                </button>
            )}
        </div>
    );
};

export default Login;