import { useState } from "react";
import { Armchair, LifeBuoy } from "lucide-react";

const SeatDiagram = ({ diagram }) => {
  const [selectedSeats, setSelectedSeats] = useState([]);

  const toggleSeat = (seat) => {
    if (!seat) return;

    setSelectedSeats((prev) =>
      prev.includes(seat)
        ? prev.filter((s) => s !== seat)
        : [...prev, seat]
    );
  };

  return (
    <div className="flex">
      {/* FLOOR */}
      {diagram.seatList.map((floor, floorIndex) => (
        <div key={floorIndex} className="bg-white shadow-lg rounded-2xl p-4 border">
            
          <div className="flex justify-between items-center mb-4">
            <div className="flex items-center gap-2 text-sm text-gray-500">
              <button> <LifeBuoy size={20}></LifeBuoy></button>
            </div>

            <span className="font-semibold text-gray-700">
              Tầng {floorIndex + 1}
            </span>
          </div>

          {/* GRID */}
          <div className="flex flex-col gap-2">
            {floor.map((row, rowIndex) => (
              <div key={rowIndex} className="flex gap-2 justify-start">
                {row.map((seat, colIndex) => {
                //   const isSelected = selectedSeats.includes(seat);

                  return (
                    <div
                      key={colIndex}
                    //   onClick={() => toggleSeat(seat)}
                      className={`
                        w-10 h-10 flex items-center justify-center rounded-xl
                        transition-all duration-200 
                        ${
                          seat
                            ? "cursor-pointer bg-blue-100"
                            : "bg-transparent cursor-default"
                        }
                      `}
                    >
                      {seat ? (
                        <div className="flex flex-col items-center text-xs">
                          <Armchair size={16} />
                        </div>
                      ) : null}
                    </div>
                  );
                })}
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
};

export default SeatDiagram;

                        // ${
                        //   isSelected
                        //     ? "bg-blue-500 text-white shadow-md scale-105"
                        //     : "bg-gray-100 hover:bg-blue-100"
                        // }