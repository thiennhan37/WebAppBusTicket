import SearchProvinces from "../../components/generalComponent/SearchProvinces"
import InputGroup from "../../components/other/InputGroup";


const TicketHeader = ({updateFilter, dateValue, setDateValue, handleSearchTrip, arrival, destination}) => {
    const isDisabled = !(arrival && destination && dateValue);
    return (
        <div className="flex bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex gap-4 items-end">
            <div className="flex-1">
                <SearchProvinces onChange={updateFilter} field={"arrival"} label={"Điểm xuất phát"} placeholder={"Tỉnh/Thành phố"}
                    initial={arrival}/>
            </div>
            <div className="flex-1">
                <SearchProvinces onChange={updateFilter} field={"destination"} label={"Điểm đến"} placeholder={"Tỉnh/Thành phố"}
                     initial={destination}/>
            </div>
            <div className="flex-1">
                <InputGroup label="Thời điểm khởi hành" type="date" value={dateValue} 
                    
                    onChange={(e) => {
                        setDateValue(e.target.value)
                        updateFilter("date", e.target.value)}} />
            </div>
            <button onClick={handleSearchTrip} disabled={isDisabled}
                    className={` px-6 py-2 rounded-lg font-medium 
                    ${isDisabled ? 'bg-slate-100 cursor-not-allowed text-slate-400' : 'bg-teal-500 text-white hover:bg-teal-600 transition'} `}>
                
                Tìm chuyến
            </button>
            
        </div>
    )
};

export default TicketHeader