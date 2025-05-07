import axios from 'axios';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import moment from 'moment';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class IriService {
    constructor() {
        // Base URL for IRI seasonal forecast data
        this.baseUrl = 'https://iridl.ldeo.columbia.edu/SOURCES/.IRI/.FD/.NMME/.MME';
        
        // Data directories
        this.dataDir = path.join(__dirname, '../../assets/weather_data');
        this.ensureDirectoryExists();
    }

    async ensureDirectoryExists() {
        await fs.ensureDir(this.dataDir);
    }

    async getSeasonalForecast(latitude, longitude) {
        try {
            const response = await axios.get(`${this.baseUrl}/.forecast`, {
                params: {
                    lat: latitude,
                    lon: longitude,
                    format: 'json',
                    months: 6
                }
            });

            if (response.data) {
                const processedData = this.processSeasonalForecast(response.data);
                await this.saveSeasonalForecast(processedData);
                return processedData;
            }

            throw new Error('No data received from IRI');
        } catch (error) {
            console.error('Error fetching seasonal forecast from IRI:', error.message);
            return null;
        }
    }

    processSeasonalForecast(data) {
        return {
            timestamp: moment().toISOString(),
            location: {
                latitude: data.latitude,
                longitude: data.longitude
            },
            seasonalForecast: data.forecast.map(month => ({
                month: month.month,
                year: month.year,
                temperature: {
                    min: month.temperature.min,
                    max: month.temperature.max,
                    anomaly: month.temperature.anomaly
                },
                precipitation: {
                    amount: month.precipitation.amount,
                    anomaly: month.precipitation.anomaly,
                    probability: month.precipitation.probability
                },
                confidence: month.confidence
            }))
        };
    }

    async saveSeasonalForecast(data) {
        try {
            const filePath = path.join(this.dataDir, 'seasonal_forecast.json');
            await fs.writeJson(filePath, data);
        } catch (error) {
            console.error('Error saving seasonal forecast:', error.message);
        }
    }
}

export default IriService; 