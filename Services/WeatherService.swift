// Luan Nguyen
// CSE335
// Phase I
//
//  WeatherService.swift
//  AnglerSpots


import Foundation
import CoreLocation

struct WeatherResponse: Decodable {
    struct Current: Decodable { let temperature_2m: Double? }
    let current: Current?
}

final class WeatherService {
    //  Minimal network client for current temperature via Open-Meteo.
    func fetchCurrentTemp(lat: Double, lon: Double) async throws -> Double? {
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m"
        
        guard let url = URL(string: urlStr) else {
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return decoded.current?.temperature_2m
    }
}
