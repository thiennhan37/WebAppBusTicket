import React, { useState, useEffect } from 'react';
import SeatMap from './SeatMap';
import HistorySidebar from './HistorySidebar';
import UpdateTicket from './UpdateTicket';
import BookingModal from './BookingModal';
import { useSearchParams } from 'react-router-dom';
import TicketHeader from './TicketHeader';
import TimeSlotPicker from './TimeSlotPicker';
import { useQuery, keepPreviousData, useQueryClient } from '@tanstack/react-query';
import TripService from '../../Services/TripService';
import LoadingOverlay from '../../components/other/LoadingOverlay';
import { useMutation } from '@tanstack/react-query';
import OrderService from "../../Services/OrderService";
import StatusModal from '../../components/other/StatusModal';
import ConfirmModal from '../../components/other/ConfirmModal';

const Ticket = () => {
  console.log("reload ticket")
  const queryClient = useQueryClient();
  const [selectedSeat, setSelectedSeat] = useState(null);
  const [isUpdateModalOpen, setIsUpdateModalOpen] = useState(false);
  const [bookingOrderId, setBookingOrderId] = useState(null);
  const [isBookingModalOpen, setIsBookingModalOpen] = useState(false);
  const [mode, setMode] = useState("normal"); // "normal", "book", "cancel"
  const [selectedSeatsList, setSelectedSeatsList] = useState([]);
  const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);

  const [searchParams, setSearchParams] = useSearchParams();
  const [arrival, setArrival] = useState(searchParams.get('arrival') || '') ;
  const [destination, setDestination] = useState(searchParams.get('destination') || '') ;
  const [date, setDate] = useState(searchParams.get("date") || "");

  const updateFilter = (field, value) => {
    if(field === "arrival") setArrival(value.name);
    else if(field === "destination") setDestination(value.name);
  };
  const handleSearchTrip = () => {
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
    if (mode === "normal" && seat.status != "AVAILABLE") {
      setSelectedSeat(seat);
      setIsUpdateModalOpen(true);
    } else if (mode === "book") {
      if (seat.status === 'AVAILABLE') {
        setSelectedSeatsList(prev => {
          if (prev.find(s => s.id === seat.id)) {
            return prev.filter(s => s.id !== seat.id);
          } else {
            return [...prev, seat];
          }
        });
      }
    } else if (mode === "cancel") {
      if (seat.status !== 'AVAILABLE') {
        setSelectedSeatsList(prev => {
          if (prev.find(s => s.id === seat.id)) {
            return prev.filter(s => s.id !== seat.id);
          } else {
            return [...prev, seat];
          }
        });
      }
    }
  };

  useEffect(() => {
    const getSimpleListForFind = async () => {
      if (dataSimpleList?.result?.length > 0) {
        const params = getParams(); 
        const res = await TripService.getSimpleTripList(params);
        if (res.data.result.length > 0) {
          setSelectedTripId(res.data.result[0].id);
        }
      }
    };
    getSimpleListForFind(); 
  }, [searchParams.toString()]);

  const {data: dataSimpleList, onSuccess, onError} = useQuery({
    queryKey: ["simpleTripList", searchParams.toString()],
    queryFn: async () => {
      const params = getParams(); 
      const res = await TripService.getSimpleTripList(params);
      if(!selectedTripId && res.data?.result?.length > 0) setSelectedTripId(res.data.result[0].id);
      return res.data;
    },  
    placeholderData: keepPreviousData,
    staleTime: 0
  })
  console.log("dataSimpleList", dataSimpleList);
  const simpleTripList = dataSimpleList?.result != null ? dataSimpleList.result : null; 

  const [selectedTripId, setSelectedTripId] = useState("");
  const [selectedTrip, setSelectedTrip] = useState({});
  const {data: dataSelectedTrip, isLoading: isLoadingSelectedTrip} = useQuery({
    queryKey: ["selectedTrip", selectedTripId],
    queryFn: async () => {
      if(!selectedTripId) return null;
      const res = await TripService.getTripById(selectedTripId);
      return res.data;
    }, 
    placeholderData: keepPreviousData,
    // refetchOnWindowFocus: false,
    // refetchOnReconnect: false,
    staleTime: 0, 
    refetchInterval: 5000, 
  })
  useEffect(() => {
    if (dataSelectedTrip) {
      setSelectedTrip(dataSelectedTrip.result);
      if(!isBookingModalOpen) setSelectedSeatsList([]);
    }
  }, [dataSelectedTrip]);

  // const selectedTrip = dataSelectedTrip?.result || {};
  const isOpenTrip = selectedTrip.status === "OPEN";

  const {mutate: holdSeats, data} = useMutation({
    mutationFn: async () => {
      const tripSeatIdList = selectedSeatsList.map(seat => seat.id);
      const res = await OrderService.holdSeats({tripId: selectedTripId, tripSeatIdList});
      return res.data;
    },
    onSuccess: (data) => {
      const bookingOrderId = data?.result;
      if(bookingOrderId){
         setBookingOrderId(bookingOrderId);
         setIsBookingModalOpen(true);
      }
    },
    onError: (error) => {
      setReport("error:"+ error.response?.data?.message);
    }
  });
  const {mutate: unHoldSeats} = useMutation({
    mutationFn: async () => {
      const tripSeatIdList = selectedSeatsList.map(seat => seat.id);
      const res = await OrderService.unHoldSeats({tripId: selectedTripId, bookingOrderId, tripSeatIdList});
      setSelectedSeatsList([]);
      queryClient.invalidateQueries({ queryKey: ['selectedTrip'] })
      return res.data;
    },
    onSuccess: () => {
      setReport("success:Đã hủy giữ ghế");
    },
    onError: (error) => {
      setReport("error:"+ error.response?.data?.message);
    }
  });
  // lưu order bởi nhân viên
  const {mutate: bookOrder} = useMutation({
    mutationFn: async (payload) => {
      const res = await OrderService.bookOrderByCompany({tripId: selectedTripId, payload});
      return res.data;
    },
    onSuccess: () => {
      setReport("success:Lưu đơn hàng thành công");
      setIsBookingModalOpen(false);
      setMode("normal");
      setSelectedSeatsList([]);
    },
    onError: (error) => {
      setReport("error:"+ error.response?.data?.message);
    }
  });
  const {mutate: cancelTicketList} = useMutation({
    mutationFn: async () => {
      const ticketIdList = selectedSeatsList.map((seat)=> {
        return seat.ticket.id;
      });
      const res = await OrderService.cancelTicketByCompany({tripId: selectedTripId, ticketIdList});
      return res?.data?.result;
    },
    onSuccess: () => {
      setReport("success:Hủy đặt vé thành công");
    },
    onError: (error) => {
      setReport("error:"+ error.response?.data?.message);
    }
  });
  const {mutate: updateTicket} = useMutation({
    mutationFn: async (payload) => {
      const res = await OrderService.updateTicketByCompany({tripId: selectedTripId, payload});
      setIsUpdateModalOpen(false);
      return res?.data;
    },
    onSuccess: () => {
      setReport("success:Cập nhật vé thành công");
    },
    onError: (error) => {
      setReport("error:"+ error.response?.data?.message);
    }
  });

  const [report, setReport] = useState("");
  const hideReport = () => {setReport("");}
  return (
    <div className="flex h-screen bg-gray-50 p-4 gap-4 font-sans text-gray-800">
      {/* Khối bên trái: Bộ lọc, Thông tin chuyến, Sơ đồ ghế */}
      <div className="flex-1 flex flex-col gap-2 overflow-hidden">

      {/* Khối báo lỗi */}
        {report.startsWith("error") && <StatusModal type="error"  message={report.split(":")[1]}
                  onClose={hideReport}></StatusModal>}
        {report.startsWith("success") && <StatusModal type="success" message={report.split(":")[1]} 
                onClose={hideReport}></StatusModal>}

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
                <p className="text-sm text-gray-500 mt-1">
                  {`Loại xe: `}
                  <span className='text-black font-bold'>{`${selectedTrip?.busType?.name}`}</span>
                  {` | Tổng số vé đã đặt:`} 
                  <span className='text-red-500 font-bold'>{` ${selectedTrip?.bookedSeats + selectedTrip?.heldSeats}`}</span>  
                  {` | Ghế trống: `} 
                  <span className='text-green-500 font-bold'> 
                    {` ${selectedTrip?.busType?.totalSeats - selectedTrip?.bookedSeats - selectedTrip?.heldSeats}`} 
                    </span>
                </p>
              </div>
              <div className={`flex flex-col gap-1 items-end ${!isOpenTrip ? 'opacity-60' : ''}`}>
                <div className="flex gap-2">
                  {/* Nút Xác nhận đặt */}
                  {mode === "book" && selectedSeatsList.length > 0 && (
                    <button 
                      disabled={!isOpenTrip}
                      onClick={() => holdSeats()}
                      className="px-2 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed text-sm font-medium shadow-md">
                      Xác nhận đặt ({selectedSeatsList.length})
                    </button>
                  )}

                  {/* Nút Xác nhận hủy */}
                  {mode === "cancel" && selectedSeatsList.length > 0 && (
                    <button 
                      disabled={!isOpenTrip}
                      onClick={() => {setIsCancelModalOpen(true); 
                        console.log(selectedSeatsList); 
                      }}
                      className="px-2 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed text-sm font-medium shadow-md">
                      Xác nhận hủy ({selectedSeatsList.length})
                    </button>
                  )}

                  {/* Nút Đặt vé */}
                  <button 
                    disabled={!isOpenTrip}
                    onClick={() => { setMode(mode === "book" ? "normal" : "book"); setSelectedSeatsList([]); }}
                    className={`px-2 py-2 rounded-lg text-sm font-medium border border-gray-200 
                      disabled:bg-gray-200 disabled:text-gray-500 disabled:cursor-not-allowed
                      ${mode === "book" ? 'bg-green-600 text-white hover:bg-green-700' : 'bg-green-200 text-black hover:bg-green-400'}`}>
                    {mode === 'book' ? 'Bỏ chọn đặt vé' : 'Đặt vé'}
                  </button>

                  {/* Nút Hủy vé */}
                  <button 
                    disabled={!isOpenTrip}
                    onClick={() => { setMode(mode === "cancel" ? "normal" : "cancel"); setSelectedSeatsList([]); }}
                    className={`px-2 py-2 rounded-lg text-sm font-medium border border-gray-200 
                      disabled:bg-gray-200 disabled:text-gray-500 disabled:cursor-not-allowed
                      ${mode === "cancel" ? 'bg-red-600 text-white hover:bg-red-700' : 'bg-red-200 text-black hover:bg-red-400'}`}>
                    {mode === 'cancel' ? 'Bỏ chọn hủy vé' : 'Hủy vé'}
                  </button>
                </div>
              </div>
              
          </div>

          <div className="bg-gray-50 p-0 rounded-xl shadow-sm border border-gray-100 flex-1 overflow-y-auto">
            <div className="relative min-h-full w-full">
              {!isOpenTrip && (
                <div className="absolute inset-0 z-10 cursor-not-allowed bg-black/10" ></div>
              )}
              <div className={!isOpenTrip ? "pointer-events-none select-none" : ""}>
                <SeatMap 
                  onSeatClick={handleSeatClick} 
                  busType={selectedTrip?.busType} 
                  seatMap={selectedTrip?.seatMap} 
                  mode={mode} 
                  selectedSeatsList={selectedSeatsList} 
                />
              </div>
            </div>
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
      {isUpdateModalOpen && (
        <UpdateTicket 
          seat={selectedSeat} 
          onClose={() => setIsUpdateModalOpen(false)} 
          selectedTrip={selectedTrip}
          onSubmit={updateTicket}
        />
      )}

      {/* Modal đặt vé */}
      {isBookingModalOpen && bookingOrderId &&  (
        <BookingModal
          selectedTrip={selectedTrip}
          selectedSeatsList={selectedSeatsList}
          bookingOrderId={bookingOrderId}
          onClose={() => {
            unHoldSeats(); 
            setIsBookingModalOpen(false); 
          }}
          onConfirm={(payload) => {
            bookOrder(payload);
            
          }}
        />
      )}
      {/* Modal xác nhận hủy vé */}
      <ConfirmModal 
        isOpen={isCancelModalOpen}
        onClose={() => setIsCancelModalOpen(false)}
        onConfirm={cancelTicketList}
        title="Hủy vé cho chuyến đi"
        message={`Bạn có chắc chắn muốn hủy danh sách vé các ghế 
          ${selectedSeatsList.map(seat => seat.seatName).join(", ")} ?`}
      />
    </div>
  );
}

export default Ticket;