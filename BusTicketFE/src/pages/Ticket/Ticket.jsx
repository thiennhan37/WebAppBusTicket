import React, { useState } from 'react';
import SeatMap from './SeatMap';
import HistorySidebar from './HistorySidebar';
import UpdateTicket from './UpdateTicket';
import BookingModal from './BookingModal';
import { useSearchParams } from 'react-router-dom';
import TicketHeader from './TicketHeader';
import TimeSlotPicker from './TimeSlotPicker';
import { useQuery, keepPreviousData } from '@tanstack/react-query';
import TripService from '../../Services/TripService';
import LoadingOverlay from '../../components/other/LoadingOverlay';
import { useMutation } from '@tanstack/react-query';
import OrderService from "../../Services/OrderService";

const Ticket = () => {
  console.log("reload ticket")
  const [selectedSeat, setSelectedSeat] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isBookingModalOpen, setIsBookingModalOpen] = useState(false);
  const [mode, setMode] = useState("normal"); // "normal", "book", "cancel"
  const [selectedSeatsList, setSelectedSeatsList] = useState([]);

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
    if (mode === "normal") {
      setSelectedSeat(seat);
      setIsModalOpen(true);
    } else if (mode === "book") {
      if (seat.status === 'AVAILABLE') {
        setSelectedSeatsList(prev => {
          if (prev.find(s => s.seatName === seat.seatName)) {
            return prev.filter(s => s.seatName !== seat.seatName);
          } else {
            return [...prev, seat];
          }
        });
      }
    } else if (mode === "cancel") {
      if (seat.status !== 'AVAILABLE') {
        setSelectedSeatsList(prev => {
          if (prev.find(s => s.seatName === seat.seatName)) {
            return prev.filter(s => s.seatName !== seat.seatName);
          } else {
            return [...prev, seat];
          }
        });
      }
    }
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

  const {mutate: holdSeats} = useMutation({
    mutationFn: async () => {
      const tricketIdList = selectedSeatsList.map(seat => seat.id);
      const res = await OrderService.holdSeats({tripId: selectedTripId, tricketIdList});
      return res.data;
    },
    onSuccess: () => {
      // onSuccess();
    },
    onError: (error) => {
      // onError(error);
    }
  });
  return (
    <div className="flex h-screen bg-gray-50 p-4 gap-4 font-sans text-gray-800">
      {/* Khối bên trái: Bộ lọc, Thông tin chuyến, Sơ đồ ghế */}
      <div className="flex-1 flex flex-col gap-2 overflow-hidden">
        
        <TicketHeader updateFilter={updateFilter} dateValue={date} setDateValue={setDate} handleSearchTrip={handleSearchTrip}
          arrival={arrival} destination={destination}> </TicketHeader>

        <div className='relative flex-1 flex flex-col min-h-0'> 
          {isLoadingSelectedTrip ? <LoadingOverlay/>  : <></>}  
            
        {simpleTripList === null ? <div className="px-4 py-2 text-gray-500 italic">Vui lòng chọn tuyến đường và thời gian</div>
        : simpleTripList.length === 0 ? <div className="px-4 py-2 text-gray-500 italic">Không có chuyến nào</div>
        : <div className='flex-1 flex flex-col min-h-0'>
            <div className="w-full"> 
              <TimeSlotPicker simpleTripList={simpleTripList} setSelectedTripId={setSelectedTripId} selectedTripId={selectedTripId}/>
            </div> 

            <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex justify-between items-center">
              <div>
                <h3 className="font-semibold text-blue-800">{`Chuyến ${selectedTrip?.departureTime?.split("T")[1].slice(0, 5)} 
                  ngày ${selectedTrip?.departureTime?.split("T")[0]} 
                   | Mã chuyến: ${selectedTrip?.id}`} </h3> 
                  <h3 className="font-semibold text-blue-800"> {`Tuyến: ${selectedTrip?.route?.name}`}</h3>
                <p className="text-sm text-gray-500 mt-1">{`Loại xe: ${selectedTrip?.busType?.name} | 
                  Tổng số vé đã đặt: ${selectedTrip?.bookedSeats} | Ghế trống: ${selectedTrip?.busType?.totalSeats}`}</p>
              </div>
              <div className="flex flex-col gap-1 items-end">
                  <button className="px-4 py-2 bg-gray-200 text-black rounded-lg hover:bg-gray-400 text-sm font-medium border border-gray-200">
                    Sơ đồ xe
                  </button>
                  <div className="flex gap-2">
                  {mode === "book" && selectedSeatsList.length > 0 && (
                    <button 
                      onClick={() => setIsBookingModalOpen(true)}
                      className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 text-sm font-medium shadow-md">
                      Xác nhận đặt ({selectedSeatsList.length})
                    </button>
                  )}
                  {mode === "cancel" && selectedSeatsList.length > 0 && (
                    <button className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 text-sm font-medium shadow-md">
                      Xác nhận hủy ({selectedSeatsList.length})
                    </button>
                  )}
                  <button 
                    onClick={() => { setMode(mode === "book" ? "normal" : "book"); setSelectedSeatsList([]); }}
                    className={`px-4 py-2 ${mode === "book" ? 'bg-green-600 text-white' : 'bg-green-200 text-black'} rounded-lg hover:bg-green-400 text-sm font-medium border border-gray-200`}>
                    {mode === 'book' ? 'Bỏ chọn đặt vé' : 'Đặt vé'}
                  </button>
                  <button 
                    onClick={() => { setMode(mode === "cancel" ? "normal" : "cancel"); setSelectedSeatsList([]); }}
                    className={`px-4 py-2 ${mode === "cancel" ? 'bg-red-600 text-white' : 'bg-red-200 text-black'} rounded-lg hover:bg-red-400 text-sm font-medium border border-gray-200`}>
                    {mode === 'cancel' ? 'Bỏ chọn hủy vé' : 'Hủy vé'}
                  </button>
                  
                </div>
              </div>
              
          </div>

          <div className="bg-gray-50 p-0 rounded-xl shadow-sm border border-gray-100 flex-1 overflow-y-auto">
            <SeatMap onSeatClick={handleSeatClick} busType={selectedTrip?.busType} seatMap={selectedTrip?.seatMap} mode={mode} selectedSeatsList={selectedSeatsList} />
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
        <UpdateTicket 
          seat={selectedSeat} 
          onClose={() => setIsModalOpen(false)} 
        />
      )}

      {/* Modal đặt vé */}
      {isBookingModalOpen && (
        <BookingModal
          selectedTrip={selectedTrip}
          selectedSeatsList={selectedSeatsList}
          onClose={() => setIsBookingModalOpen(false)}
          onConfirm={(payload) => {
            console.log("Xác nhận đặt vé:", payload);
            // holdSeats({tripId: selectedTripId, tricketIdList: ...}) can be called here
            setIsBookingModalOpen(false);
            setMode("normal");
            setSelectedSeatsList([]);
          }}
        />
      )}
    </div>
  );
}

export default Ticket;