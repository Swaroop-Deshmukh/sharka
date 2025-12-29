// verifyWeek6-full.js
// Node.js script: REST API + WebSocket live updates for Week 6
// Run: node verifyWeek6-full.js

const axios = require('axios');
const { io } = require('socket.io-client');

const BASE_URL = 'http://localhost:3000';

// ======================
// 1️⃣ Connect to WebSocket
// ======================
const socket = io(BASE_URL, { transports: ['websocket'] });

socket.on('connect', () => {
  console.log('✅ Connected to Socket.IO, Socket ID:', socket.id);
});

socket.on('disconnect', () => {
  console.log('❌ Disconnected from server');
});

socket.on('connect_error', (err) => {
  console.error('⚠️ WebSocket Connection Error:', err.message);
});

// Listen to all relevant trip events
socket.on('trip_status', (data) => console.log('🚗 Trip Status Update:', data));
socket.on('tripAccepted', (data) => console.log('✅ Trip Accepted Event:', data));
socket.on('tripStarted', (data) => console.log('▶️ Trip Started Event:', data));
socket.on('tripCompleted', (data) => console.log('🏁 Trip Completed Event:', data));

// ======================
// 2️⃣ REST API Flow
// ======================
async function main() {
  try {
    // Step 1: Passenger requests a trip
    console.log('\n--- STEP 1: Passenger requests a trip ---');
    const requestTripRes = await axios.post(`${BASE_URL}/trips/request`, {
      passengerId: 'passenger1',
      startLat: 18.5167,
      startLng: 73.8567,
      endLat: 18.5204,
      endLng: 73.8567,
    });
    const trip = requestTripRes.data;
    console.log('Trip requested:', trip);

    const tripId = trip.id;

    // Join trip room for WebSocket updates
    socket.emit('join_trip', { tripId });
    console.log(`📡 Joined trip room for tripId ${tripId}`);

    // Step 2: Driver accepts the trip
    console.log('\n--- STEP 2: Driver accepts the trip ---');
    const acceptTripRes = await axios.patch(`${BASE_URL}/trips/${tripId}/accept`, {
      driverId: 'driver1',
    });
    console.log('Trip accepted:', acceptTripRes.data);

    // Step 3: Driver starts the trip
    console.log('\n--- STEP 3: Driver starts the trip ---');
    const startTripRes = await axios.patch(`${BASE_URL}/trips/${tripId}/start`, {
      driverId: 'driver1',
    });
    console.log('Trip started:', startTripRes.data);

    // Step 4: Driver ends the trip
    console.log('\n--- STEP 4: Driver ends the trip ---');
    const endTripRes = await axios.patch(`${BASE_URL}/trips/${tripId}/end`);
    console.log('Trip ended:', endTripRes.data);

    // Step 5: Get trips by passenger
    console.log('\n--- STEP 5: Get trips by passenger ---');
    const passengerTrips = await axios.get(`${BASE_URL}/trips/passenger/passenger1`);
    console.log('Passenger trips:', passengerTrips.data);

    // Step 6: Get trips by driver
    console.log('\n--- STEP 6: Get trips by driver ---');
    const driverTrips = await axios.get(`${BASE_URL}/trips/driver/driver1`);
    console.log('Driver trips:', driverTrips.data);

    // Step 7: Get all trips
    console.log('\n--- STEP 7: Get all trips ---');
    const allTrips = await axios.get(`${BASE_URL}/trips`);
    console.log('All trips:', allTrips.data);

    console.log('\n✅ Full Week 6 verification completed!');
  } catch (err) {
    if (err.response) {
      console.error('API Error:', err.response.status, err.response.data);
    } else {
      console.error('Error:', err.message);
    }
  }
}

main();
