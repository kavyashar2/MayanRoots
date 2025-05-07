const admin = require('firebase-admin');
const axios = require('axios');
const { NetCDFReader } = require('netcdfjs');

// Initialize Firebase Admin
const serviceAccount = require('./firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Constants
const LOCATION = {
  lat: 20.6537,
  lon: -88.4460,
  name: 'Tahcabo, Yucatán'
};

async function downloadFile(url) {
  try {
    const response = await axios({
      method: 'get',
      url: url,
      responseType: 'arraybuffer'
    });
    return response.data;
  } catch (error) {
    console.error('Error downloading file:', error);
    throw error;
  }
}

async function processChirpsData(data) {
  try {
    const reader = new NetCDFReader(data);
    const precipitation = reader.getDataVariable('precipitation');
    const probabilities = reader.getDataVariable('probability');
    
    // Process for our specific location
    const locationIndex = findClosestGridPoint(LOCATION.lat, LOCATION.lon, reader);
    
    return {
      current: {
        precipitation: precipitation[locationIndex],
        probability: probabilities[locationIndex],
        timestamp: new Date().toISOString(),
        location: LOCATION
      },
      forecast: Array.from({ length: 7 }, (_, i) => ({
        date: new Date(Date.now() + i * 24 * 60 * 60 * 1000).toISOString(),
        precipitation: precipitation[locationIndex + i],
        probability: probabilities[locationIndex + i]
      }))
    };
  } catch (error) {
    console.error('Error processing CHIRPS data:', error);
    throw error;
  }
}

async function processIriData(data) {
  try {
    const reader = new NetCDFReader(data);
    const precipitation = reader.getDataVariable('precipitation');
    const probabilities = reader.getDataVariable('probability');
    
    const locationIndex = findClosestGridPoint(LOCATION.lat, LOCATION.lon, reader);
    
    const now = new Date();
    return {
      months: Array.from({ length: 3 }, (_, i) => {
        const forecastDate = new Date(now.getFullYear(), now.getMonth() + i, 1);
        return {
          month: forecastDate.toISOString().slice(0, 7),
          precipitation: precipitation[locationIndex + i],
          probability: probabilities[locationIndex + i]
        };
      }),
      timestamp: now.toISOString(),
      location: LOCATION
    };
  } catch (error) {
    console.error('Error processing IRI data:', error);
    throw error;
  }
}

function findClosestGridPoint(lat, lon, reader) {
  const lats = reader.getDataVariable('latitude');
  const lons = reader.getDataVariable('longitude');
  
  let minDistance = Infinity;
  let closestIndex = 0;
  
  for (let i = 0; i < lats.length; i++) {
    const distance = Math.sqrt(
      Math.pow(lats[i] - lat, 2) + Math.pow(lons[i] - lon, 2)
    );
    if (distance < minDistance) {
      minDistance = distance;
      closestIndex = i;
    }
  }
  
  return closestIndex;
}

async function updateFirestore(shortTerm, longTerm) {
  try {
    const batch = db.batch();
    
    // Update short-term forecast
    batch.set(db.collection('weatherForecasts').doc('shortTermForecast'), {
      current: shortTerm.current,
      forecast: shortTerm.forecast,
      timestamp: new Date().toISOString()
    });
    
    // Update long-term forecast
    batch.set(db.collection('weatherForecasts').doc('longTermForecast'), longTerm);
    
    await batch.commit();
    console.log('Firestore updated successfully');
  } catch (error) {
    console.error('Error updating Firestore:', error);
    throw error;
  }
}

async function main() {
  try {
    // Download CHIRPS-GEFS data
    const chirpsData = await downloadFile(
      'https://iridl.ldeo.columbia.edu/SOURCES/.CHIRPS/.GEFS/.reforecast/.HINDCAST/.Precipitation/data.nc'
    );
    
    // Download IRI seasonal forecast data
    const iriData = await downloadFile(
      'https://iridl.ldeo.columbia.edu/SOURCES/.IRI/.FD/.Seasonal_Forecast/.Precipitation/data.nc'
    );
    
    // Process the data
    const shortTermForecast = await processChirpsData(chirpsData);
    const longTermForecast = await processIriData(iriData);
    
    // Update Firestore
    await updateFirestore(shortTermForecast, longTermForecast);
    
  } catch (error) {
    console.error('Error in main process:', error);
  }
}

// Run the processor every 6 hours
setInterval(main, 6 * 60 * 60 * 1000);
main(); // Initial run 