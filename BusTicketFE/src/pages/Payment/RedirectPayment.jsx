import { useParams, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import PaymentService from "../../Services/PaymentService";
import { useMutation } from "@tanstack/react-query";

const RedirectPayment = () => {
    const { paymentId } = useParams();
    const navigate = useNavigate(); // Dùng để điều hướng khi bấm nút
    const [report, setReport] = useState("payment");

    const { mutate: getPayUrl } = useMutation({
        mutationFn: async () => {
            const result = await PaymentService.getPayUrlForCustomer(paymentId);
            console.log(result.data.result.payUrl);
            
            // Trường hợp API trả về 200 OK nhưng chứa mã code báo lỗi 7007
            if (result?.data?.code === 7007 || result?.code === 7007) {
                setReport("ALREADY_PAID");
                return result.data;
            }

            if (result?.data?.result?.payUrl) {
                window.location.href = result.data.result.payUrl;
            } else {
                setReport("Thanh toán thất bại!");
            }
            return result.data;
        },
        onSuccess: (data) => {
            // setReport("success:Lưu đơn hàng thành công");
        },
        onError: (error) => {
            // Trường hợp API ném lỗi HTTP (4xx, 5xx) chứa mã code 7007
            if (error.response?.data?.code === 7007) {
                setReport("ALREADY_PAID");
            } else {
                setReport(error.response?.data?.message || "Đã xảy ra lỗi trong quá trình xử lý");
            }
        }
    });

    useEffect(() => {
        console.log("do useEffect", paymentId);
        if (paymentId) {
            getPayUrl();
        }
    }, [paymentId]);

    // ==================== GIAO DIỆN THEO TỪNG TRẠNG THÁI ====================

    // 1. TRẠNG THÁI ĐANG TẢI / CHUYỂN HƯỚNG CỔNG THANH TOÁN
    if (report === "payment") {
        return (
            <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4">
                <div className="flex flex-col items-center space-y-4 text-center">
                    <div className="w-12 h-12 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
                    <p className="text-slate-600 font-medium animate-pulse">
                        Đang kiểm tra đơn hàng và chuyển hướng đến cổng thanh toán...
                    </p>
                </div>
            </div>
        );
    }

    // 2. TRẠNG THÁI LỖI 7007: ĐƠN HÀNG ĐÃ ĐƯỢC THANH TOÁN
    if (report === "ALREADY_PAID") {
        return (
            <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4 antialiased font-sans">
                <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-6 md:p-8 text-center border border-slate-100 transform transition-all duration-300">
                    <div className="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center mx-auto mb-5 text-blue-500 animate-pulse">
                        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                    </div>
                    
                    <h1 className="text-2xl font-bold text-slate-800 mb-2">
                        Đơn Hàng Đã Thanh Toán
                    </h1>
                    <p className="text-sm text-slate-500 mb-6 leading-relaxed">
                        Hệ thống ghi nhận hóa đơn này đã được hoàn tất giao dịch trước đó. Bạn không cần thực hiện lại bước thanh toán này nữa.
                    </p>
                    
                    <button 
                        onClick={() => navigate("/nhaxe/overview")}
                        className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-xl transition-colors duration-200 shadow-lg shadow-blue-100"
                    >
                        Quay lại trang chủ 
                    </button>
                </div>
            </div>
        );
    }

    // 3. TRẠNG THÁI CÁC LỖI KHÁC (HIỂN THỊ LỖI CHI TIẾT)
    return (
        <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4 antialiased font-sans">
            <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-6 md:p-8 text-center border border-slate-100">
                <div className="w-20 h-20 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-5 text-red-500">
                    <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                    </svg>
                </div>
                
                <h1 className="text-2xl font-bold text-slate-800 mb-2">
                    Yêu Cầu Thất Bại
                </h1>
                
                <div className="bg-red-50 rounded-xl p-4 mb-6 border border-red-100">
                    <p className="text-sm text-red-600 font-medium break-words">
                        {report}
                    </p>
                </div>
                
                <button 
                    onClick={() => navigate("/nhaxe/overview")}
                    className="w-full bg-slate-800 hover:bg-slate-900 text-white font-semibold py-3 px-4 rounded-xl transition-colors duration-200"
                >
                    Quay lại trang chủ
                </button>
            </div>
        </div>
    );
};

export default RedirectPayment;