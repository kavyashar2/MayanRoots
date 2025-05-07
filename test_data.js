const admin = require('firebase-admin');

// Initialize admin SDK for emulator
admin.initializeApp({
  projectId: 'mayan-roots-43fe8'
});

// Connect to Firestore emulator
const db = admin.firestore();
db.settings({
  host: 'localhost:8083',
  ssl: false
});

async function populateTestData() {
  try {
    // Add short-term forecast
    await db.collection('weatherForecasts').doc('shortTermForecast').set({
      current: {
        temp_c: 28,
        humidity: 75,
        precip_mm: 2.5,
        wind_kph: 12,
        condition: 'Partly cloudy'
      },
      forecast: {
        next_24h: {
          precip_chance: 60,
          precip_mm: 15,
          confidence: 0.85
        },
        next_48h: {
          precip_chance: 40,
          precip_mm: 8,
          confidence: 0.75
        }
      },
      timestamp: new Date().toISOString()
    });

    // Add long-term forecast
    await db.collection('weatherForecasts').doc('longTermForecast').set({
      seasonal_outlook: {
        next_3_months: {
          precip_anomaly: 1.2,
          confidence: 0.7,
          trend: 'above_normal'
        }
      },
      drought_risk: {
        level: 'moderate',
        confidence: 0.65
      },
      timestamp: new Date().toISOString()
    });

    // Add latest forecast results
    await db.collection('forecast_results').doc('latest').set({
      status: 'success',
      data: {
        precipitation: {
          amount_mm: 25.4,
          probability: 0.75
        },
        temperature: {
          max_c: 32,
          min_c: 22
        },
        wind: {
          speed_kph: 15,
          direction: 'NE'
        }
      },
      timestamp: new Date().toISOString()
    });

    // Add seasonal forecast results
    await db.collection('forecast_results').doc('seasonal').set({
      status: 'success',
      data: {
        season: 'wet',
        outlook: {
          precipitation: 'above_normal',
          confidence: 0.8
        },
        agricultural_guidance: {
          planting_recommendation: 'favorable',
          risk_level: 'low'
        }
      },
      timestamp: new Date().toISOString()
    });

    console.log('✅ Test data populated successfully');
  } catch (error) {
    console.error('❌ Error populating test data:', error);
  }
}

populateTestData(); 