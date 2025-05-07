import { initializeApp } from 'firebase/app';
import { getFirestore, connectFirestoreEmulator, collection, doc, setDoc } from 'firebase/firestore';

// Initialize Firebase
const app = initializeApp({
  projectId: 'demo-project',
  apiKey: 'demo-api-key'
});

// Get Firestore instance and connect to emulator
const db = getFirestore(app);
connectFirestoreEmulator(db, 'localhost', 8082);

// Generate mock forecast data
const generateForecastData = () => {
  const now = new Date();
  const precipitation = (Math.random() * 10).toFixed(2);
  const probability = (Math.random() * 100).toFixed(1);
  
  return {
    data: {
      current: {
        precipitation: parseFloat(precipitation),
        window: `${now.toISOString().split('T')[0]} to ${new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]}`,
        probability: parseFloat(probability)
      }
    },
    updatedAt: now
  };
};

// Write forecast to Firestore
const writeForecastToFirestore = async () => {
  try {
    const forecastData = generateForecastData();
    const forecastRef = doc(collection(db, 'forecast_results'), 'latest');
    
    await setDoc(forecastRef, forecastData);
    
    console.log('✅ Wrote forecast to Firestore');
    console.log('Forecast data:', JSON.stringify(forecastData, null, 2));
    
    // Exit after successful write
    process.exit(0);
  } catch (error) {
    console.error('❌ Error writing forecast to Firestore:', error);
    process.exit(1);
  }
};

// Run the pipeline
writeForecastToFirestore(); 