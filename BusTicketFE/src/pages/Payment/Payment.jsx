import { useParams } from "react-router-dom";

const Payment = () => {
    const {bookingOrderId} = useParams();
    console.log(bookingOrderId);
    return (
        <>
        </>
    )
}

export default Payment;