// Luan Nguyen
// CSE335
// Phase II
//
//  WeatherService.swift
//  AnglerSpots
import Foundation
import CoreLocation

// WeatherData struct to hold the weather info we get from API
struct WeatherData {
    let temperature: Double?  // celsius
    let sunrise: String?
    let sunset: String?
}

// WeatherResponse struct matches the JSON structure from Open-Meteo API
struct WeatherResponse: Decodable {
    struct Current: Decodable {
        let temperature_2m: Double?  // temperature at 2m height
    }
    struct Daily: Decodable {
        let sunrise: [String]?  // array of sunrise times
        let sunset: [String]?  // array of sunset
    }
    let current: Current?
    let daily: Daily?
}

final class WeatherService {
    func fetchWeatherData(lat: Double, lon: Double) async throws -> WeatherData {
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m&daily=sunrise,sunset&timezone=auto"
        
        guard let url = URL(string: urlStr) else {
            return WeatherData(temperature: nil, sunrise: nil, sunset: nil)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // decode the JSON response using Swift's native JSONDecoder
        let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
        
        // extract the data we want from the decoded JSON
        let temp = decoded.current?.temperature_2m
        
        let sunrise = decoded.daily?.sunrise?.first  // get first sunrise (today)
        let sunset = decoded.daily?.sunset?.first  // get first sunset (today)
        
        return WeatherData(temperature: temp, sunrise: sunrise, sunset: sunset)
    }
    
    // old func
    func fetchCurrentTemp(lat: Double, lon: Double) async throws -> Double? {
        let weatherData = try await fetchWeatherData(lat: lat, lon: lon)
        return weatherData.temperature
    }
}
