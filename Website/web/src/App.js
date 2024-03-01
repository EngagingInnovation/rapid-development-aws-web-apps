import React, { useState } from 'react';
import './index.css';

function App() {
    const [dates, setDates] = useState([]);

    const handleButtonClick = () => {
        const now = new Date().toISOString();
        setDates([now, ...dates]);
    };

    const handleClearClick = () => {
        setDates([]); // Clear the list
    };

    return (
        <div className="min-h-screen bg-blue-900 text-white flex flex-col items-center pt-4">

            {/* Page Title */}
            <h1 className="text-3xl font-bold mb-4">WebApp Template</h1>

            {/* Buttons Container */}
            <div className="mb-4 flex items-center">
                <button
                    onClick={handleButtonClick}
                    className="flex items-center justify-center bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded focus:outline-none focus:shadow-outline border-2 border-blue-700 hover:border-blue-500 mr-2 leading-none"
                >
                    DateTime Button
                </button>

                <button
                    onClick={handleClearClick}
                    className="flex items-center justify-center bg-white hover:bg-gray-200 py-2 px-4 rounded focus:outline-none focus:shadow-outline border-2 border-red-200 hover:border-red-700 leading-none"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 text-red-500">
                        <path strokeLinecap="round" strokeLinejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                    </svg>
                </button>
            </div>


            {/* Content Below */}
            <div className="max-w-md mx-auto bg-blue-800 rounded-lg overflow-hidden">
                <ul>
                    {dates.map((date, index) => (
                        <li key={index} className="text-gray-300 text-base px-6 py-2 border-b border-blue-700">
                            {date}
                        </li>
                    ))}
                </ul>
            </div>
        </div>
    );
}

export default App;
