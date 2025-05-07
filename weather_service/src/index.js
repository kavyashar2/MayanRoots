const ChirpsGefsService = require('./chirps-gefs-service');

async function main() {
    try {
        console.log('🌤️ Starting CHIRPS-GEFS weather service...');
        const weatherService = new ChirpsGefsService();
        
        // Update weather data immediately
        await weatherService.updateWeatherData();
        
        // Update weather data every hour
        setInterval(async () => {
            console.log('🌤️ Updating weather data...');
            await weatherService.updateWeatherData();
        }, 60 * 60 * 1000); // 1 hour
        
    } catch (error) {
        console.error('🌧️ Error in weather service:', error.message);
        process.exit(1);
    }
}

main(); 