  const [provinces, setProvinces] = useState([]);
  useEffect(() => {
    const loadProvinces = async() => {
        try{
            const params = {keyword: inputValue};
            const result = (await ProvinceService.getProvinces(params))?.data?.result || [];
            console.log(result);
            setProvinces(result);
        }catch(error){
            console.log(error);
        }
    }
    loadProvinces();
    
  }, [inputValue]);