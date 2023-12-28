//
//  AirportDetailModel.swift
//  New_Foreflight
//
//  Created by John Foster on 12/23/23.
//

import Foundation


class AirportDetailModel: ObservableObject{
    
    //airport optional for sheet. if we are nil we wont display the sheet.
    
    @Published var sheetlocation : Airport? = nil
    
    @Published var curr_metar : String? = nil
    
    
}



