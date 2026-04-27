import React, { useState } from 'react';


const  TimeSlotPicker = ({simpleTripList, selectedTripId, setSelectedTripId}) =>  {
  return (
    <div className="w-full bg-white px-4 rounded-xl shadow-sm border border-gray-100">
      {/* Container trượt ngang */}
      <div className="flex flex-nowrap overflow-x-auto p-1 gap-3 scrollbar-hide select-none">
        {simpleTripList.map((slot) => {
          const isSelected = (selectedTripId === slot.id);
          return (
            <div
              key={slot.id}
              onClick={() => {setSelectedTripId(slot.id);}}
              className={`
                flex-shrink-0 w-28 p-3 rounded-lg border-2 cursor-pointer transition-all duration-200
                ${isSelected 
                  ? 'border-blue-500 bg-blue-50 shadow-md transform scale-105' 
                  : 'border-gray-100 bg-white hover:border-gray-300 hover:shadow-sm'
                }
              `}
            >
              <div className={`text-base font-bold ${isSelected ? 'text-blue-700' : 'text-gray-800'}`}>
                {slot.departureTime.split("T")[1].slice(0, 5)}
              </div>
              
              <div className="mt-1 flex items-center justify-between">
                <div className="h-1 w-8 bg-gray-200 rounded-full overflow-hidden">
                   <div 
                    className="h-full bg-blue-500" 
                    style={{ width: `${(slot.bookedSeats / slot.totalSeats) * 100}%` }}
                   ></div>
                </div>
                <div className={`text-xs font-medium ${isSelected ? 'text-blue-600' : 'text-gray-500'}`}>
                  {slot.bookedSeats}/{slot.totalSeats}
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default TimeSlotPicker;