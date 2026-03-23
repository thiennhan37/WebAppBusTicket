import axios from "axios";
import { useEffect, useState } from "react";

const Overview = () =>{
    const [product, setProduct] = useState(null);
    const handleProduct = (data) => {
        setProduct(data);
    }
    useEffect(() =>{
        axios.get("https://fakestoreapi.com/products/1")
        .then((data) =>{
            handleProduct(data);
        })
    }, [])
    return(
        <>
            <p>Overview</p>
            {console.log(typeof product)}
        </>
    )
}
export default Overview;