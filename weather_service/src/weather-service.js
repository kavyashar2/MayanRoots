import ChirpsGefsService from './chirps-gefs-service.js';
import IriService from './iri-service.js';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class WeatherService {
    constructor() {
        this.chirpsGefs = new ChirpsGefsService();
        this.iri = new IriService();
        this.dataDir = path.join(__dirname, '../../assets/weather_data');
    }

    async getCurrentWeather(latitude, longitude) {
        try {
            // Try to get current weather from CHIRPS-GEFS
            const currentWeather = await this.chirpsGefs.getCurrentWeather(latitude, longitude);
            if (currentWeather) {
                return currentWeather;
            }

            // If CHIRPS-GEFS fails, try to get from local storage
            const localData = await this.getLocalCurrentWeather();
            if (localData) {
                return localData;
            }

            throw new Error('Unable to fetch current weather data');
        } catch (error) {
            console.error('Error getting current weather:', error.message);
            return null;
        }
    }

    async getForecast(latitude, longitude) {
        try {
            // Try to get forecast from CHIRPS-GEFS
            const forecast = await this.chirpsGefs.getForecast(latitude, longitude);
            if (forecast) {
                return forecast;
            }

            // If CHIRPS-GEFS fails, try to get from local storage
            const localData = await this.getLocalForecast();
            if (localData) {
                return localData;
            }

            throw new Error('Unable to fetch forecast data');
        } catch (error) {
            console.error('Error getting forecast:', error.message);
            return null;
        }
    }

    async getSeasonalForecast(latitude, longitude) {
        try {
            // Try to get seasonal forecast from IRI
            const seasonalForecast = await this.iri.getSeasonalForecast(latitude, longitude);
            if (seasonalForecast) {
                return seasonalForecast;
            }

            // If IRI fails, try to get from local storage
            const localData = await this.getLocalSeasonalForecast();
            if (localData) {
                return localData;
            }

            throw new Error('Unable to fetch seasonal forecast data');
        } catch (error) {
            console.error('Error getting seasonal forecast:', error.message);
            return null;
        }
    }

    async getLocalCurrentWeather() {
        try {
            const filePath = path.join(this.dataDir, 'current_weather.json');
            if (await fs.pathExists(filePath)) {
                return await fs.readJson(filePath);
            }
            return null;
        } catch (error) {
            console.error('Error reading local current weather:', error.message);
            return null;
        }
    }

    async getLocalForecast() {
        try {
            const filePath = path.join(this.dataDir, 'forecast.json');
            if (await fs.pathExists(filePath)) {
                return await fs.readJson(filePath);
            }
            return null;
        } catch (error) {
            console.error('Error reading local forecast:', error.message);
            return null;
        }
    }

    async getLocalSeasonalForecast() {
        try {
            const filePath = path.join(this.dataDir, 'seasonal_forecast.json');
            if (await fs.pathExists(filePath)) {
                return await fs.readJson(filePath);
            }
            return null;
        } catch (error) {
            console.error('Error reading local seasonal forecast:', error.message);
            return null;
        }
    }
}

export default WeatherService; 