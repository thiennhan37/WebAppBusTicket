import {useParams, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import PaymentService from "../../Services/PaymentService"
import { useMutation } from "@tanstack/react-query";
const RedirectPayment = () => {
    const {paymentId} = useParams();
    const [report, setReport] = useState("payment")
    const {mutate: getPayUrl} = useMutation({
        mutationFn: async () => {
            const result = await PaymentService.getPayUrlForCustomer(paymentId);
            console.log(result.data.result.payUrl);
            if(result?.data?.result?.payUrl){
              window.location.href = result.data.result.payUrl;
            } 
            else setReport("Thanh toán thất bại!");
            return result.data;
        },
        onSuccess: (data) => {
          // setReport("success:Lưu đơn hàng thành công");
        },
        onError: (error) => {
          setReport(error.response?.data?.message);
        }
      });

      useEffect(() => {
        console.log("do useEffect", paymentId);
        if(paymentId){
          getPayUrl();
        } 
      }, [paymentId])

    return (
        <>
            <p>{report}</p>
        </>
    )
}

export default RedirectPayment;