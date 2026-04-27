import React, { useState } from 'react';
import SeatMap from './SeatMap';
import HistorySidebar from './HistorySidebar';
import BookingModal from './BookingModal';
import { useSearchParams } from 'react-router-dom';
import TicketHeader from './TicketHeader';
import TimeSlotPicker from './TimeSlotPicker';
import { useQuery, keepPreviousData } from '@tanstack/react-query';
import TripService from '../../Services/TripService';
import LoadingOverlay from '../../components/other/LoadingOverlay';

const Ticket = () => {
  console.log("reload ticket")
  const [selectedSeat, setSelectedSeat] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const [searchParams, setSearchParams] = useSearchParams();
  const [arrival, setArrival] = useState(searchParams.get('arrival') || '') ;
  const [destination, setDestination] = useState(searchParams.get('destination') || '') ;
  const [date, setDate] = useState(searchParams.get("date") || "");

  const updateFilter = (field, value) => {
    if(field === "arrival") setArrival(value.name);
    else if(field === "destination") setDestination(value.name);
  };
  const handleSearchTrip = () => {
    console.log("search");
    const currentParams = new URLSearchParams(searchParams);
    if(arrival) currentParams.set("arrival", arrival);
    else currentParams.delete("arrival");
    if(destination) currentParams.set("destination", destination);
    else currentParams.delete("destination");
    if(date) currentParams.set("date", date);
    else currentParams.delete("date");
    setSearchParams(currentParams);
  }
  const getParams = () => {
    const params = {
      arrival: searchParams.get("arrival"),
      destination: searchParams.get("destination"),
      date: searchParams.get("date")
    };
    return params;
  }
  // Giả lập dữ liệu lịch sử
  const historyLogs = [
    { id: 1, action: 'đặt vé', user: 'nhân viên A', seat: 'B1', customer: 'khách hàng C', time: '10:45 30/04/2021', type: 'book' },
    { id: 2, action: 'hủy vé', user: 'khách hàng A', seat: 'B2', customer: 'khách hàng A', time: '09:30 30/04/2021', type: 'cancel' },
  ];

  const handleSeatClick = (seat) => {
    setSelectedSeat(seat);
    setIsModalOpen(true);
  };
  const {data: dataSimpleList, onSuccess, onError} = useQuery({
    queryKey: ["simpleTripList", searchParams.toString()],
    queryFn: async () => {
      const params = getParams(); 
      const res = await TripService.getSimpleTripList(params);
      if(res.data.result.length > 0) setSelectedTripId(res.data.result[0].id);
      return res.data;
    }, 
    placeholderData: keepPreviousData,
    staleTime: 0
  })
  const simpleTripList = dataSimpleList?.result || null;

  const [selectedTripId, setSelectedTripId] = useState("");
  const {data: dataSelectedTrip, isLoading: isLoadingSelectedTrip} = useQuery({
    queryKey: ["selectedTrip", selectedTripId],
    queryFn: async () => {
      if(!selectedTripId) return null;
      const res = await TripService.getTripById(selectedTripId);
      return res.data;
    }, 
    placeholderData: keepPreviousData,
    staleTime: 0
  })
  const selectedTrip = dataSelectedTrip?.result || {};
  return (
    <div className="flex h-screen bg-gray-50 p-4 gap-4 font-sans text-gray-800">
      {/* Khối bên trái: Bộ lọc, Thông tin chuyến, Sơ đồ ghế */}
      <div className="flex-1 flex flex-col gap-2 overflow-hidden">
        
        {/* Bộ lọc Header (Rút gọn) */}
        <TicketHeader updateFilter={updateFilter} dateValue={date} setDateValue={setDate} handleSearchTrip={handleSearchTrip}
          arrival={arrival} destination={destination}> </TicketHeader>

        <div className='relative w-full h-full'>
          {isLoadingSelectedTrip ? <LoadingOverlay/>  : <></>}  
            
        {simpleTripList === null ? <div className="px-4 py-2 text-gray-500 italic">Vui lòng chọn tuyến đường và thời gian</div>
        : simpleTripList.length === 0 ? <div className="px-4 py-2 text-gray-500 italic">Không có chuyến nào</div>
        : <div>
            <div className="w-full"> 
              <TimeSlotPicker simpleTripList={simpleTripList} setSelectedTripId={setSelectedTripId} selectedTripId={selectedTripId}/>
            </div> 

            <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center">
              <div>
                <h3 className="font-semibold text-blue-800">{`Chuyến ${selectedTrip?.departureTime?.split("T")[1].slice(0, 5)} 
                  ngày ${selectedTrip?.departureTime?.split("T")[0]} 
                  tuyến ${selectedTrip?.route?.name}`} </h3>
                  <h3 className="font-semibold text-blue-800"> {`Mã chuyến: ${selectedTrip?.id}`}</h3>
                <p className="text-sm text-gray-500 mt-1">{`Loại xe: ${selectedTrip?.busType?.name} | 
                  Tổng số vé đã đặt: ${selectedTrip?.bookedSeats} | Ghế trống: ${selectedTrip?.busType?.totalSeats}`}</p>
              </div>
              <div className="flex gap-2">
                <button className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 text-sm font-medium border border-gray-200">Xuất bến</button>
                <button className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 text-sm font-medium border border-gray-200">Sơ đồ xe</button>
              </div>
          </div>
          {/* Sơ đồ ghế */}
          <div className="bg-white p-0 rounded-xl shadow-sm border border-gray-100 flex-1 overflow-auto">
            <SeatMap onSeatClick={handleSeatClick} />
          </div>
        </div>
        }
        </div>
        
      </div>

      {/* Khối bên phải: Lịch sử đặt vé */}
      <div className="w-[300px] bg-white rounded-xl shadow-sm border border-gray-100 p-4 flex flex-col">
        <HistorySidebar logs={historyLogs} />
      </div>

      {/* Modal cập nhật vé */}
      {isModalOpen && (
        <BookingModal 
          seat={selectedSeat} 
          onClose={() => setIsModalOpen(false)} 
        />
      )}
    </div>
  );
}

export default Ticket;