import axios from 'axios';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import moment from 'moment';
import GeoTIFF from 'geotiff';
import { gdal } from 'gdal-async';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class ChirpsGefsService {
    constructor() {
        // Coordinates for Muchucux, Yucatán
        this.latitude = 20.6537;
        this.longitude = -88.4460;
        
        // Base URLs for CHIRPS-GEFS data
        this.baseUrl = 'https://iridl.ldeo.columbia.edu/SOURCES/.CHIRPS/.GEFS';
        
        // Data directories
        this.dataDir = path.join(__dirname, '../../assets/weather_data');
        this.ensureDirectoryExists();
    }

    async ensureDirectoryExists() {
        await fs.ensureDir(this.dataDir);
    }

    async getCurrentWeather(latitude, longitude) {
        try {
            const response = await axios.get(`${this.baseUrl}/.forecast`, {
                params: {
                    lat: latitude,
                    lon: longitude,
                    format: 'json'
                }
            });

            if (response.data) {
                const processedData = this.processCurrentWeather(response.data);
                await this.saveCurrentWeather(processedData);
                return processedData;
            }

            throw new Error('No data received from CHIRPS-GEFS');
        } catch (error) {
            console.error('Error fetching current weather from CHIRPS-GEFS:', error.message);
            return null;
        }
    }

    async getForecast(latitude, longitude) {
        try {
            const response = await axios.get(`${this.baseUrl}/.forecast`, {
                params: {
                    lat: latitude,
                    lon: longitude,
                    format: 'json',
                    days: 7
                }
            });

            if (response.data) {
                const processedData = this.processForecast(response.data);
                await this.saveForecast(processedData);
                return processedData;
            }

            throw new Error('No data received from CHIRPS-GEFS');
        } catch (error) {
            console.error('Error fetching forecast from CHIRPS-GEFS:', error.message);
            return null;
        }
    }

    processCurrentWeather(data) {
        return {
            timestamp: moment().toISOString(),
            location: {
                latitude: data.latitude,
                longitude: data.longitude
            },
            current: {
                temperature: data.temperature,
                precipitation: data.precipitation,
                humidity: data.humidity,
                windSpeed: data.windSpeed,
                windDirection: data.windDirection
            }
        };
    }

    processForecast(data) {
        return {
            timestamp: moment().toISOString(),
            location: {
                latitude: data.latitude,
                longitude: data.longitude
            },
            forecast: data.forecast.map(day => ({
                date: day.date,
                temperature: {
                    min: day.temperature.min,
                    max: day.temperature.max
                },
                precipitation: day.precipitation,
                humidity: day.humidity,
                windSpeed: day.windSpeed,
                windDirection: day.windDirection
            }))
        };
    }

    async saveCurrentWeather(data) {
        try {
            const filePath = path.join(this.dataDir, 'current_weather.json');
            await fs.writeJson(filePath, data);
        } catch (error) {
            console.error('Error saving current weather:', error.message);
        }
    }

    async saveForecast(data) {
        try {
            const filePath = path.join(this.dataDir, 'forecast.json');
            await fs.writeJson(filePath, data);
        } catch (error) {
            console.error('Error saving forecast:', error.message);
        }
    }

    async processRawData(rawData) {
        try {
            const precipitation = rawData.data[0].values[0];
            
            // Estimate temperature based on precipitation (simplified model)
            const baseTemp = 25.0; // Base temperature for Yucatan
            const tempC = baseTemp - (precipitation * 0.5);
            
            return {
                precipitation_mm: precipitation,
                temp_c: tempC,
                condition: this.getConditionFromPrecipitation(precipitation),
                humidity: this.estimateHumidity(precipitation)
            };
        } catch (error) {
            console.error('🌧️ Error processing raw data:', error.message);
            return null;
        }
    }

    getConditionFromPrecipitation(precipitation) {
        if (precipitation < 0.1) return 'Despejado';
        if (precipitation < 2.5) return 'Parcialmente nublado';
        if (precipitation < 7.5) return 'Nublado';
        return 'Lluvia';
    }

    estimateHumidity(precipitation) {
        // Simple humidity estimation based on precipitation
        const baseHumidity = 65; // Base humidity for Yucatan
        return Math.min(95, baseHumidity + (precipitation * 2));
    }

    async updateWeatherData() {
        try {
            // Fetch different forecast periods
            const forecasts = await Promise.all([
                this.fetchForecast(5),
                this.fetchForecast(15)
            ]);
            
            if (!forecasts[0] || !forecasts[1]) {
                throw new Error('Failed to fetch forecast data');
            }

            // Process current weather
            const currentWeather = await this.processRawData(forecasts[0]);
            if (!currentWeather) {
                throw new Error('Failed to process current weather data');
            }

            // Create weather data objects
            const current = {
                current: {
                    ...currentWeather,
                    last_updated: moment().format(),
                },
                location: {
                    name: 'Muchucux, Yucatán',
                    region: 'Yucatán',
                    country: 'Mexico',
                    lat: this.latitude,
                    lon: this.longitude
                },
                source: 'CHIRPS-GEFS',
                timestamp: moment().format()
            };

            // Process forecast data
            const forecastDays = [];
            for (let i = 0; i < 15; i++) {
                const dayData = await this.processRawData(forecasts[1]);
                if (dayData) {
                    forecastDays.push({
                        date: moment().add(i + 1, 'days').format('YYYY-MM-DD'),
                        day: {
                            maxtemp_c: dayData.temp_c + 5,
                            mintemp_c: dayData.temp_c - 5,
                            condition: {
                                text: dayData.condition
                            },
                            daily_chance_of_rain: dayData.precipitation_mm > 0.1 ? 100 : 0,
                            total_precipitation_mm: dayData.precipitation_mm
                        }
                    });
                }
            }

            const forecast = {
                forecast: {
                    forecastday: forecastDays
                },
                source: 'CHIRPS-GEFS',
                timestamp: moment().format()
            };

            // Save data to files
            await fs.writeJson(path.join(this.dataDir, 'current_weather.json'), current, { spaces: 2 });
            await fs.writeJson(path.join(this.dataDir, 'forecast.json'), forecast, { spaces: 2 });

            console.log('🌤️ Weather data updated successfully');
            return true;
        } catch (error) {
            console.error('🌧️ Error updating weather data:', error.message);
            return false;
        }
    }
}

export default ChirpsGefsService; 